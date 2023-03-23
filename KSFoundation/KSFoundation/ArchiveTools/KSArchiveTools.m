//
//  KSArchiveTools.m
//  KSFoundation
//
//  Created by Kinsun on 2020/12/7.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSArchiveTools.h"
#import <UIKit/UIKit.h>
#import <pthread/pthread.h>

@interface KSArchiveTools ()

@property (nonatomic, class, readonly) NSMapTable <NSString *, KSArchiveTools *> *k_Catalog;

@end

NSString * const KSArchiveToolsFilePath = @"KSGlobalArchive";
static NSString * const k_KSGlobalArchiveFileName = @"__global__.cache";

NSNotificationName const KSArchiveToolsWillAutoSynchronizeNotification = @"KSArchiveToolsWillAutoSynchronizeNotification";

@implementation KSArchiveTools {
    NSString *_fliePath;
    NSMapTable <NSString *, id>*_cacheTable;
    NSLock *_cacheLock;
    BOOL _hasChange;
    
    UIBackgroundTaskIdentifier _backgroundTaskIdentifier;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    return [self initWithIdentifier:identifier supportArchiveModel:NO];
}

- (instancetype)initWithIdentifier:(NSString *)identifier supportArchiveModel:(BOOL)supportArchiveModel {
    NSMapTable <NSString *, KSArchiveTools *> *catalog = [self.class k_Catalog];
    KSArchiveTools *obj = [catalog objectForKey:identifier];
    if (obj != nil) {
        NSAssert(supportArchiveModel == obj.isSupportArchiveModel, @"KSArchiveTools：在内存中已经存在identifier=%@的对象，但是supportArchiveModel却不相同，这是不被支持的，请统一相同identifier对于supportArchiveModel的设定。内存中的设定=%d，你的设定=%d", identifier, obj.isSupportArchiveModel, supportArchiveModel);
        return obj;
    }
    if (self = [super init]) {
        _hasChange = NO;
        _realtimeDataSave = NO;
        _identifier = identifier.copy;
        _supportArchiveModel = supportArchiveModel;
        
        _cacheLock = NSLock.alloc.init;
        _cacheLock.name = _identifier;
        
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        path = [path stringByAppendingPathComponent:KSArchiveToolsFilePath];
        NSFileManager *mgr = NSFileManager.defaultManager;
        if (![mgr fileExistsAtPath:path]) {
            [mgr createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _fliePath = [path stringByAppendingPathComponent:identifier];
        _cacheTable = NSMapTable.strongToStrongObjectsMapTable;
        NSDictionary <NSString *, id>*dict = [NSDictionary dictionaryWithContentsOfFile:_fliePath];
        if (dict != nil) {
            NSDictionary *k_dict = supportArchiveModel ? [self.class _unserializations:dict] : dict;
            for (NSString *key in k_dict.keyEnumerator) {
                id obj = [k_dict objectForKey:key];
                [_cacheTable setObject:obj forKey:key];
            }
        }
        [self _registerNotification];
        
        __weak typeof(self) weakSelf = self;
        // 实现如下代码，才能使程序处于后台时被杀死，调用applicationWillTerminate:方法
        _backgroundTaskIdentifier = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^(){
            __strong typeof(weakSelf) self = weakSelf;
            [self _endBackgroundTask];
        }];
    }
    [catalog setObject:self forKey:identifier];
    return self;
}

- (void)setObject:(id)object forKey:(NSString *)key {
    [_cacheLock lock];
    _hasChange = YES;
    [_cacheTable setObject:object forKey:key];
    [_cacheLock unlock];
}

- (id)objectForKey:(NSString *)key {
    return [_cacheTable objectForKey:key];
}

- (void)removeObjectForKey:(NSString *)key {
    if ([_cacheTable objectForKey:key] != nil) {
        [_cacheLock lock];
        _hasChange = YES;
        [_cacheTable removeObjectForKey:key];
        [_cacheLock unlock];
    }
}

- (void)setObjectsAndKeysFromDictionary:(NSDictionary <NSString *, id> *)dictionary {
    if (dictionary != nil && dictionary.count > 0) {
        [_cacheLock lock];
        _hasChange = YES;
        [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id map, BOOL *stop) {
            [_cacheTable setObject:map forKey:key];
        }];
        [_cacheLock unlock];
    }
}

- (NSArray *)objectsForKeys:(NSArray <NSString *> *)keys isFillNull:(BOOL)isFillNull {
    if (keys != nil && keys.count > 0) {
        NSMutableArray *maps = [NSMutableArray arrayWithCapacity:keys.count];
        for (NSString *key in keys) {
            id map = [_cacheTable objectForKey:key];
            if (map != nil) {
                [maps addObject:map];
            } else if (isFillNull) {
                [maps addObject:NSNull.null];
            }
        }
        return maps.copy;
    }
    return nil;
}

- (void)removeObjectsForKeys:(NSArray <NSString *> *)keys {
    if (keys != nil && keys.count > 0) {
        [_cacheLock lock];
        _hasChange = YES;
        for (NSString *key in keys) {
            [_cacheTable removeObjectForKey:key];
        }
        [_cacheLock unlock];
    }
}

- (NSArray<NSString *> *)allKeys {
    return NSAllMapTableKeys(_cacheTable);
}

- (NSArray *)allObjects {
    return NSAllMapTableValues(_cacheTable);
}

- (NSUInteger)count {
    return NSCountMapTable(_cacheTable);
}

+ (id)_serializations:(id)obj {
    if ([obj conformsToProtocol:@protocol(NSSecureCoding)]) {
        if ([obj isKindOfClass:NSDictionary.class]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[obj count]];
            [obj enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
                id value = [self _serializations:obj];
                if (value != nil) [dict setObject:value forKey:key];
            }];
            return dict;
        } else if ([obj isKindOfClass:NSArray.class]) {
            NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[obj count]];
            [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                id value = [self _serializations:obj];
                if (value != nil) [arr addObject:value];
            }];
            return arr;
        }
        return obj;
    } else if ([obj conformsToProtocol:@protocol(KSArchiveModelProtocol)]) {
        id <KSArchiveModelProtocol> k_obj = obj;
        NSMutableDictionary *dict = k_obj.toDictionaryValue.mutableCopy;
        if (dict != nil) {
            [dict setObject:NSStringFromClass(k_obj.class) forKey:@"__________fileToolFlag__________"];
        }
        return dict;
    }
    return nil;
}

+ (id)_unserializations:(id)obj {
    if ([obj isKindOfClass:NSDictionary.class]) {
        NSString *classString = [obj objectForKey:@"__________fileToolFlag__________"];
        if (classString != nil) {
            Class class = NSClassFromString(classString);
            if (class != nil && [class conformsToProtocol:@protocol(KSArchiveModelProtocol) ]) {
                id <KSArchiveModelProtocol> value = [[class alloc] initWithDictionary:obj];
                return value;
            }
        }
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[obj count]];
        [obj enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            [dict setObject:[self _unserializations:obj] forKey:key];
        }];
        return dict;
    } else if ([obj isKindOfClass:NSArray.class]) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[obj count]];
        [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [arr addObject:[self _unserializations:obj]];
        }];
        return arr;
    }
    return obj;
}

- (void)_saveDataToSandbox {
    [NSNotificationCenter.defaultCenter postNotificationName:KSArchiveToolsWillAutoSynchronizeNotification object:self];
    if (_hasChange || _realtimeDataSave) {
        [self synchronize];
    }
}

- (void)synchronize {
    [_cacheLock lock];
    if (_cacheTable != nil && _cacheTable.count > 0) {
        NSDictionary *k_dict = _cacheTable.dictionaryRepresentation;
        NSMutableDictionary *dict = _supportArchiveModel ? [self.class _serializations:k_dict] : k_dict.mutableCopy;
        [dict writeToFile:_fliePath atomically:YES];
    }
    _hasChange = NO;
    [_cacheLock unlock];
}

- (void)reinit {
    [_cacheLock lock];
    if (_cacheTable != nil && _cacheTable.count > 0) {
        [_cacheTable removeAllObjects];
        NSFileManager *mgr = NSFileManager.defaultManager;
        if ([mgr fileExistsAtPath:_fliePath]) {
            [mgr removeItemAtPath:_fliePath error:nil];
        }
    }
    _hasChange = NO;
    [_cacheLock unlock];
}

- (void)_endBackgroundTask {
    [self _saveDataToSandbox];
    [UIApplication.sharedApplication endBackgroundTask:_backgroundTaskIdentifier];
    _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
}

- (void)_registerNotification {
    SEL selector = @selector(_saveDataToSandbox);
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center addObserver:self selector:selector name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:selector name:UIApplicationWillTerminateNotification object:nil];
}

- (void)dealloc {
    [self _saveDataToSandbox];
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    [center removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

+ (KSArchiveTools *)globalArchiveTools {
    static KSArchiveTools *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] initWithIdentifier:k_KSGlobalArchiveFileName];
    });
    return _instance;
}
    
+ (NSMapTable <NSString *, KSArchiveTools *> *)k_Catalog {
    static NSMapTable <NSString *, KSArchiveTools *> * _k_Catalog = nil;
    if (_k_Catalog == nil) {
        _k_Catalog = NSMapTable.weakToWeakObjectsMapTable;
    }
    return _k_Catalog;
}
    
@end
