//
//  KSKeyChainTool.m
//  KSFoundation
//
//  Created by Kinsun on 2020/6/23.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSKeyChainTool.h"

@implementation KSKeyChainTool

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)key forAccessGroup:(NSString *)accessGroup {
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
                                  key, (__bridge id)kSecAttrService, key, (__bridge id)kSecAttrAccount,
                                  (__bridge id)kSecAttrAccessibleAfterFirstUnlock, (__bridge id)kSecAttrAccessible, nil];

    if (accessGroup != nil && accessGroup.length > 0) {
        NSString *fullAccessGroup = [self getFullAccessGroup:accessGroup];
        if (fullAccessGroup != nil) {
            [query setObject:fullAccessGroup forKey:(__bridge id)kSecAttrAccessGroup];
        }
    }
    return query;
}

+ (NSString *)getFullAccessGroup:(NSString *)accessGroup {
    NSString *group = nil;
    NSString *bundleSeedIdentifier = [self getBundleSeedIdentifier];
    if (bundleSeedIdentifier != nil && [accessGroup rangeOfString:bundleSeedIdentifier].location == NSNotFound) {
        group = [NSString stringWithFormat:@"%@.%@", bundleSeedIdentifier, accessGroup];
    }
    return group;
}

+ (NSString *)getBundleSeedIdentifier {
    static __strong NSString *bundleSeedIdentifier = nil;
    if (bundleSeedIdentifier == nil) {
        @synchronized(self) {
            if (bundleSeedIdentifier == nil) {
                NSString *_bundleSeedIdentifier = nil;
                NSDictionary *query = @{(__bridge id)kSecClass: (__bridge NSString *)kSecClassGenericPassword,
                                        (__bridge id)kSecAttrAccount: @"bundleSeedID",
                                        (__bridge id)kSecAttrService: @"",
                                        (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue};
                CFDictionaryRef result = nil;
                OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
                if (status == errSecItemNotFound) {
                    status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
                }
                if (status == errSecSuccess) {
                    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];
                    NSArray *components = [accessGroup componentsSeparatedByString:@"."];
                    _bundleSeedIdentifier = components.firstObject;
                    CFRelease(result);
                }
                if (_bundleSeedIdentifier != nil) {
                    bundleSeedIdentifier = [_bundleSeedIdentifier copy];
                }
            }
        }
    }
    return bundleSeedIdentifier;
}

+ (BOOL)setValue:(id)value forKey:(NSString *)key {
    return [self setValue:value forKey:key forAccessGroup:nil];
}

+ (BOOL)setValue:(id)value forKey:(NSString *)key forAccessGroup:(NSString *)accessGroup {
    NSMutableDictionary *query = [self getKeychainQuery:key forAccessGroup:accessGroup];
    [self deleteValueForKey:key forAccessGroup:accessGroup];
    NSData *data = nil;
    @try {
        data = [NSKeyedArchiver archivedDataWithRootObject:value];
    } @catch (NSException *exception) {
        return NO;
    }
    [query setObject:data forKey:(__bridge id)kSecValueData];
    OSStatus result = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    return result == errSecSuccess;
}

+ (BOOL)deleteValueForKey:(NSString *)key {
    return [self deleteValueForKey:key forAccessGroup:nil];
}

+ (BOOL)deleteValueForKey:(NSString *)key forAccessGroup:(NSString *)accessGroup {
    NSMutableDictionary *query = [self getKeychainQuery:key forAccessGroup:accessGroup];
    OSStatus result = SecItemDelete((__bridge CFDictionaryRef)query);
    return result == errSecSuccess;
}

+ (id)valueForKey:(NSString *)key {
    return [self valueForKey:key forAccessGroup:nil];
}

+ (id)valueForKey:(NSString *)key forAccessGroup:(NSString *)accessGroup {
    id value = nil;
    NSMutableDictionary *query = [self getKeychainQuery:key forAccessGroup:accessGroup];
    CFDataRef keyData = NULL;
    [query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    if (SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&keyData) == errSecSuccess) {
        @try {
            value = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        @catch (NSException *e) {
            value = nil;
        }
    }
    if (keyData) {
        CFRelease(keyData);
    }
    return value;
}

@end
