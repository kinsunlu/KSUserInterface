//
//  KSBaseModel.m
//  KSFoundation
//
//  Created by Kinsun on 2021/4/14.
//  Copyright © 2021 Kinsun. All rights reserved.
//

#import "KSBaseModel.h"
#import <objc/runtime.h>

@implementation KSBaseModel
@synthesize toDictionaryValue = _toDictionaryValue;

- (NSMutableDictionary<NSString *, id> *)toDictionaryValue {
    if (_toDictionaryValue == nil) {
        NSMutableDictionary <NSString *, id> *props = [NSMutableDictionary dictionary];
        [self _getPropertiesFromClass:self.class ofDictionary:props];
        NSArray <NSString *> *blackList = self.class.blackList;
        if (blackList != nil && blackList.count > 0) {
            [props removeObjectsForKeys:blackList];
        }
        _toDictionaryValue = props;
    }
    return _toDictionaryValue;
}

- (void)_getPropertiesFromClass:(Class)class ofDictionary:(NSMutableDictionary *)dictionary {
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *char_f = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:propertyName];
        if ([self _chackValue:propertyValue]) {
            [dictionary setObject:propertyValue forKey:propertyName];
        }
     }
    free(properties);
    Class superClass = [class superclass];
    if (superClass == nil || superClass == KSBaseModel.class) {
        return;
    } else {
        [self _getPropertiesFromClass:superClass ofDictionary:dictionary];
    }
}

- (BOOL)_chackValue:(id)value {
    return value != nil && [value conformsToProtocol:@protocol(NSCopying)];
}

- (void)resetToDictionaryValueCache {
    _toDictionaryValue = nil;
}

static NSArray <NSString *> *_ks_blackList = nil;

+ (void)load {
    _ks_blackList = @[@"description", @"debugDescription", @"hash", @"superclass"];
}

+ (NSArray<NSString *> *)blackList {
    return _ks_blackList;
}

@end
