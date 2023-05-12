//
//  KSImageView.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/10/15.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSImageView.h"

@interface _KSImageViewTask : NSObject

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) KSImageViewCallback finished;

@end

@implementation _KSImageViewTask

@end

#import <CommonCrypto/CommonDigest.h>
#import <KSFoundation/KSDeviceTools.h>
#import <KSFoundation/KSNetworking.h>
#import <KSFoundation/KSURLRequest.h>
#import <objc/runtime.h>

NSErrorDomain const _KSWebImageURLErrorDomain = @"_KSWebImageURLErrorDomain";
const NSInteger _KSWebImageURLErrorCode = -999;

@interface KSImageView ()

@property (nonatomic, readonly, class) KSNetworking <NSData *> *_ks__sharedNetworking__;
@property (nonatomic, readonly, class) NSString *_ks__cachePath__;
@property (nonatomic, readonly, class) NSCache <NSString *, UIImage *> *_ks__imageCache__;
@property (nonatomic, readonly, strong) _KSImageViewTask *_ks__task__;

@end

@implementation KSImageView {
    NSString *_currentKey;
}

+ (KSNetworking <NSData *> *)_ks__sharedNetworking__ {
    static KSNetworking <NSData *> *k_sharedNetworking = nil;
    if (k_sharedNetworking == nil) {
        @synchronized (self) {
            if (k_sharedNetworking == nil) {
                NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
                configuration.timeoutIntervalForRequest = 8.0;
                NSOperationQueue *queue = NSOperationQueue.alloc.init;
                queue.name = @"com.kinsun.webimage.queue";
                queue.maxConcurrentOperationCount = 5;
                queue.qualityOfService = NSQualityOfServiceUtility;
                k_sharedNetworking = [KSNetworking.alloc initWithConfiguration:configuration queue:queue];
            }
        }
    }
    return k_sharedNetworking;
}

+ (NSString *)_ks__cachePath__ {
    static NSString *k_cachePath = nil;
    if (k_cachePath == nil) {
        k_cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"KSImageCache"];
    }
    return k_cachePath;
}

+ (NSCache <NSString *, UIImage *>*)_ks__imageCache__ {
    static NSCache <NSString*, UIImage*> *k_imageCache = nil;
    if (k_imageCache == nil) {
        @synchronized (self) {
            if (k_imageCache == nil) {
                NSCache<NSString *, UIImage *> *imageCache = NSCache.alloc.init;
                imageCache.name = @"KSWebImageCache";
                k_imageCache = imageCache;
            }
        }
    }
    return k_imageCache;
}

+ (UIImage *)_imageWithKey:(NSString *)key path:(NSString **)path {
    if (key == nil || key.length <= 0) return nil;
    NSCache <NSString *, UIImage *> *imageCache = self._ks__imageCache__;
    UIImage *image = [imageCache objectForKey:key];
    if (image == nil) {
        NSString *k_path = [self._ks__cachePath__ stringByAppendingPathComponent:key];
        if (path != NULL) {
            *path = k_path;
        }
        NSFileManager *fm = NSFileManager.defaultManager;
        if ([fm fileExistsAtPath:k_path]) {
            NSData *imageData = [NSData dataWithContentsOfFile:k_path];
            image = [self _imageFromData:imageData];
            if (image != nil) {
                [imageCache setObject:image forKey:key];
            }
        }
    }
    return image;
}

+ (UIImage *)imageWithURLString:(NSString *)urlString {
    if (urlString == nil || urlString.length <= 0) return nil;
    return [self _imageWithKey:_ks_md5(urlString) path:nil];
}

+ (UIImage *)imageWithURL:(NSURL *)url {
    return [self imageWithURLString:url.absoluteString];
}

- (void)_performImageTask {
    _KSImageViewTask *task = __ks__task__;
    if (task == nil) return;
    __ks__task__ = nil;
    [self _setImageURL:task.url key:task.key finished:task.finished];
}

- (void)setImageURL:(NSURL *)url placeholder:(UIImage *)placeholder finished:(KSImageViewCallback)finished {
    if (url == nil) {
        _currentKey = nil;
        if (_deferredTask) __ks__task__ = nil;
        self.image = placeholder;
        return;
    }
    Class class = self.class;
    NSString *key = _ks_md5(url.absoluteString);
    NSString *path = nil;
    UIImage *image = [class _imageWithKey:key path:&path];
    if (image != nil) {
        _currentKey = nil;
        if (_deferredTask) __ks__task__ = nil;
        self.image = image;
        if (finished != nil) {
            finished(self, image, path, nil);
        }
        return;
    }
    self.image = placeholder;
    _currentKey = key;
    if (_deferredTask) {
        if (__ks__task__ == nil) {
            _KSImageViewTask *task = _KSImageViewTask.alloc.init;
            task.key = key;
            task.url = url;
            task.finished = finished;
            __ks__task__ = task;
            [self performSelector:@selector(_performImageTask) withObject:nil afterDelay:0.0 inModes:@[NSDefaultRunLoopMode]];
        } else {
            __ks__task__.key = key;
            __ks__task__.url = url;
            __ks__task__.finished = finished;
        }
    } else {
        [self _setImageURL:url key:key finished:finished];
    }
}

- (void)_setImageURL:(NSURL *)url key:(NSString *)key finished:(KSImageViewCallback)finished {
    KSNetworking <NSData *> *networking = [self.class _ks__sharedNetworking__];
    KSURLRequest *request = [KSURLRequest.alloc initWithURL:url method:KSURLRequestMethodGET contentType:KSURLRequestContentTypeTextPlain query:nil body:nil];
    __weak KSImageView *weakSelf = self;
    [networking requestDataWithRequest:request callback:^(NSData *data, NSError *error) {
        [weakSelf _requestAfterWithData:data error:error key:key finished:finished];
    }];
}

- (void)_requestAfterWithData:(NSData *)data error:(NSError *)error key:(NSString *)key finished:(KSImageViewCallback)finished {
    UIImage *image = nil;
    NSString *p = nil;
    if (error == nil && data != nil) {
        Class class = self.class;
        image = [class _imageFromData:data];
        if (image != nil) {
            NSCache <NSString *, UIImage *> *imageCache = [class _ks__imageCache__];
            [imageCache setObject:image forKey:key];
            NSString *folderPath = [class _ks__cachePath__];
            NSFileManager *fm = NSFileManager.defaultManager;
            if (![fm fileExistsAtPath:folderPath]) {
                [fm createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            NSString *path = [folderPath stringByAppendingPathComponent:key];
            if ([fm fileExistsAtPath:path]) {
                [fm removeItemAtPath:path error:nil];
            }
            [data writeToFile:path atomically:YES];
            p = path;
        }
    }
    if (_currentKey == nil || ![_currentKey isEqualToString:key]) return;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf == nil) return;
        if (image != nil) {
            weakSelf.image = image;
        }
        if (finished != nil) {
            finished(weakSelf, image, p, error);
        }
    });
}

- (void)setImage:(UIImage *)image {
    if (_renderingMode == UIImageRenderingModeAlwaysTemplate) {
        [super setImage:[image imageWithRenderingMode:_renderingMode]];
    } else {
        [super setImage:image];
    }
}

+ (UIImage *)_imageFromData:(NSData *)data {
    return [UIImage imageWithData:data];
}

- (void)setImageURL:(NSURL *)url placeholder:(UIImage *)placeholder {
    [self setImageURL:url placeholder:placeholder finished:nil];
}

- (void)setImageURL:(NSURL *)url {
    [self setImageURL:url placeholder:nil finished:nil];
}

- (void)setImageURLString:(NSString *)urlString placeholder:(UIImage *)placeholder finished:(KSImageViewCallback)finished {
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        self.image = placeholder;
        if (finished != nil) {
            NSError *error = [NSError errorWithDomain:_KSWebImageURLErrorDomain code:_KSWebImageURLErrorCode userInfo:nil];
            finished(self, nil, nil, error);
        }
    } else {
        [self setImageURL:url placeholder:placeholder finished:finished];
    }
}

- (void)setImageURLString:(NSString *)urlString placeholder:(UIImage *)placeholder {
    [self setImageURLString:urlString placeholder:placeholder finished:nil];
}

- (void)setImageURLString:(NSString *)urlString {
    [self setImageURLString:urlString placeholder:nil finished:nil];
}

@end

@interface KSImageView (ImageCache)

@property (nonatomic, readonly, class) dispatch_queue_t _ks__ioQueue__;

@end

@implementation KSImageView (ImageCache)

+ (dispatch_queue_t)_ks__ioQueue__ {
    static dispatch_queue_t k_ioQueue = NULL;
    if (k_ioQueue == NULL) {
        @synchronized (self) {
            if (k_ioQueue == NULL) {
                k_ioQueue = dispatch_queue_create("com.kinsun.webimage.io.queue", DISPATCH_QUEUE_SERIAL);
            }
        }
    }
    return k_ioQueue;
}

+ (unsigned long long)totalDiskSize {
    __block unsigned long long k_size = 0;
    dispatch_async(self._ks__ioQueue__, ^{
        NSFileManager *fm = NSFileManager.defaultManager;
        NSString *path = self._ks__cachePath__;
        unsigned long long size = 0;
        NSDirectoryEnumerator *fileEnumerator = [fm enumeratorAtPath:path];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            NSDictionary<NSString *, id> *attrs = [fm attributesOfItemAtPath:filePath error:nil];
            size += attrs.fileSize;
        }
        k_size = size;
    });
    return k_size;
}

+ (NSUInteger)totalDiskCount {
    __block NSUInteger count = 0;
    dispatch_async(self._ks__ioQueue__, ^{
        NSDirectoryEnumerator *fileEnumerator = [NSFileManager.defaultManager enumeratorAtPath:self._ks__cachePath__];
        count = fileEnumerator.allObjects.count;
    });
    return count;
}

+ (void)calculateSizeWithCompletion:(void (^)(NSUInteger, unsigned long long))completionBlock {
    if (completionBlock != nil) dispatch_async(self._ks__ioQueue__, ^{
        unsigned long long size = 0;
        NSUInteger fileCount = 0;
        NSFileManager *fm = NSFileManager.defaultManager;
        NSString *path = self._ks__cachePath__;
        NSDirectoryEnumerator *fileEnumerator = [fm enumeratorAtPath:path];
        for (NSString *fileName in fileEnumerator) {
            fileCount ++;
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            NSDictionary<NSString *, id> *attrs = [fm attributesOfItemAtPath:filePath error:nil];
            size += attrs.fileSize;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(fileCount, size);
        });
    });
}

+ (void)clearMemory {
    [self._ks__imageCache__ removeAllObjects];
}

+ (void)clearDisk {
    [NSFileManager.defaultManager removeItemAtPath:self._ks__cachePath__ error:nil];
}

+ (void)clearDiskOnCompletion:(void (^)(void))completion {
    dispatch_async(self._ks__ioQueue__, ^{
        [self clearDisk];
        if (completion != nil) dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

+ (NSString *)stringWithSize:(unsigned long long)size {
    if (size < 1024) {
        return [NSString stringWithFormat:@"%lluB", size];
    }
    double p_1024_2 = pow(1024.0, 2.0);
    if (size >= 1024 && size < p_1024_2) {
        return [NSString stringWithFormat:@"%.2fKB", size/1024.0];
    }
    double p_1024_3 = pow(1024.0, 3.0);
    if (size >= p_1024_2 && size < p_1024_3) {
        return [NSString stringWithFormat:@"%.2fMB", size/p_1024_2];
    }
    return [NSString stringWithFormat:@"%.2fGB", size/p_1024_3];
}

@end
