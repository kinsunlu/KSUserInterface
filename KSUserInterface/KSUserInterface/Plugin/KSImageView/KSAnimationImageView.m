//
//  KSAnimationImageView.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/5/6.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSAnimationImageView.h"
#import <CoreServices/CoreServices.h>

@interface KSImageView ()

+ (UIImage *)_imageFromData:(NSData *)data;

@end

@implementation KSAnimationImageView

+ (UIImage *)_imageFromData:(NSData *)data {
    if (data.length <= 0) return nil;
    CFStringRef keys[1] = {kCGImageSourceShouldCache};
    CFBooleanRef values[1] = {kCFBooleanFalse};
    CFDictionaryRef options = CFDictionaryCreate(kCFAllocatorDefault, (void*)keys, (void*)values, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, options);
    CFRelease(options);
    size_t count = CGImageSourceGetCount(source);
    UIImage *image = nil;
    if (count > 1) {
        CFStringRef imageSourceContainerType = CGImageSourceGetType(source);
        if (imageSourceContainerType == NULL) return nil;
        BOOL isGIFData = UTTypeConformsTo(imageSourceContainerType, kUTTypeGIF);
        CFRelease(imageSourceContainerType);
        
        float delayTime = 0.0;
        NSMutableArray <UIImage *> *images = [NSMutableArray arrayWithCapacity:count];
        for (size_t i = 0; i < count; i++) {
            CGImageRef cgimage = CGImageSourceCreateImageAtIndex(source, i, nil);
            if (cgimage != nil) {
                delayTime += isGIFData ? [KSAnimationImageView _gifFrameDurationAtIndex:i source:source] : [KSAnimationImageView _apngFrameDurationAtIndex:i source:source];
                UIImage *image = [UIImage imageWithCGImage:cgimage];
                [images addObject:image];
                CGImageRelease(cgimage);
            }
        }
        image = [UIImage animatedImageWithImages:images duration:delayTime];
    } else {
        image = [super _imageFromData:data];
    }
    CFRelease(source);
    return image;
}

+ (float)_gifFrameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *properties = CFDictionaryGetValue(cfFrameProperties, kCGImagePropertyGIFDictionary);
    NSNumber *delayTimeUnclampedProp = [properties objectForKey:(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp != nil) {
        frameDuration = delayTimeUnclampedProp.floatValue;
    } else {
        NSNumber *delayTimeProp = [properties objectForKey:(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp != nil) {
            frameDuration = delayTimeProp.floatValue;
        }
    }
    CFRelease(cfFrameProperties);
    return frameDuration;
}

+ (float)_apngFrameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *properties = CFDictionaryGetValue(cfFrameProperties, kCGImagePropertyPNGDictionary);
    NSNumber *delayTimeUnclampedProp = [properties objectForKey:(NSString *)kCGImagePropertyAPNGUnclampedDelayTime];
    if (delayTimeUnclampedProp != nil) {
        frameDuration = delayTimeUnclampedProp.floatValue;
    } else {
        NSNumber *delayTimeProp = [properties objectForKey:(NSString *)kCGImagePropertyAPNGDelayTime];
        if (delayTimeProp != nil) {
            frameDuration = delayTimeProp.floatValue;
        }
    }
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    CFRelease(cfFrameProperties);
    return frameDuration;
}

@end
