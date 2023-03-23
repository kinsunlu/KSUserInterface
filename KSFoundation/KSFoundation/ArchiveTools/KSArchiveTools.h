//
//  KSArchiveTools.h
//  KSFoundation
//
//  Created by Kinsun on 2020/12/7.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSModelsProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KSArchiveModelProtocol <KSEnModelsProtocol, KSDeModelsProtocol>

@end

/// NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
/// path = [path stringByAppendingPathComponent:KSArchiveToolsFilePath];
FOUNDATION_EXTERN NSString * const KSArchiveToolsFilePath NS_SWIFT_NAME(KSArchiveTools.filePath);
FOUNDATION_EXTERN NSNotificationName const KSArchiveToolsWillAutoSynchronizeNotification NS_SWIFT_NAME(KSArchiveTools.willAutoSynchronizeNotification);

@interface KSArchiveTools : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, readonly, getter=isSupportArchiveModel) BOOL supportArchiveModel;
@property (nonatomic, assign, getter=isRealtimeDataSave) BOOL realtimeDataSave;
@property (nonatomic, readonly) NSArray <NSString *> *allKeys;
@property (nonatomic, readonly) NSArray *allObjects;
@property (nonatomic, readonly) NSUInteger count;

/// 构造一个对象
/// @param identifier 唯一标识符，也将会是文件名，所以请勿使用“/”等文件名不允许使用的字符
- (instancetype)initWithIdentifier:(NSString *)identifier;

/// 构造一个对象
/// @param identifier 唯一标识符，也将会是文件名，所以请勿使用“/”等文件名不允许使用的字符
/// @param isSupportArchiveModel 是否打开对KSArchiveModelProtocol的对象的支持
- (instancetype)initWithIdentifier:(NSString *)identifier supportArchiveModel:(BOOL)isSupportArchiveModel;

/// 将序列化的值 NSDictionary，NSArray，NSString，KSArchiveModelProtocol的对象放进表内
/// @param object NSDictionary，NSArray，NSString，KSArchiveModelProtocol类型的对象
/// @param key 键
- (void)setObject:(id)object forKey:(NSString *)key;
/// 得到一个被序列化的对象
/// @param key 键
- (id _Nullable)objectForKey:(NSString *)key;
/// 移除一个被序列化的对象
/// @param key 键
- (void)removeObjectForKey:(NSString *)key;

/// 将序列化的值 NSDictionary，NSArray，NSString，KSArchiveModelProtocol的对象透过dictionary打包放进表内
/// @param dictionary 批量插入的键值对
- (void)setObjectsAndKeysFromDictionary:(NSDictionary <NSString *, id> *)dictionary;
/// 批量获得序列化的值
/// @param keys 键集合
/// @param isFillNull 是否使用NSNull填充不存在的index，
/// 如果等于YES返回的结果中如果Key没有对应的Value将使用NSNull填充。等于NO则不填充
- (NSArray <id>*_Nullable)objectsForKeys:(NSArray <NSString *> *)keys isFillNull:(BOOL)isFillNull;
/// 批量移除被序列化的对象
/// @param keys 键集合
- (void)removeObjectsForKeys:(NSArray <NSString *> *)keys;

/// 重置存储空间
- (void)reinit;
/// 立即保存数据到沙盒
- (void)synchronize;

@property (nonatomic, class, readonly) KSArchiveTools *globalArchiveTools;

@end

NS_ASSUME_NONNULL_END
