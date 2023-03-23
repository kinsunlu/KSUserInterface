//
//  KSDeviceTools.h
//  KSFoundation
//
//  Created by Kinsun on 2020/12/7.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * _Nonnull _ks_getIMSI(void);
FOUNDATION_EXTERN void _ks_getMCC_MNC(NSString *_Nonnull*_Nonnull mcc, NSString *_Nonnull*_Nonnull mnc);

FOUNDATION_EXTERN void _ks_getIDFA(void (^_Nonnull)(BOOL, NSString *_Nullable));
FOUNDATION_EXTERN NSString * _Nonnull _ks_getUUID(void);
FOUNDATION_EXTERN BOOL _ks_resetUUID(void);
FOUNDATION_EXTERN NSString * _Nonnull _ks_getDeviceModel(void);
FOUNDATION_EXTERN NSString * _Nonnull _ks_getCarrierCode(void);
/// 0:无网络，1:联通，2:移动，3:电信，4:其他
FOUNDATION_EXTERN NSInteger _ks_getCarrier(void);
FOUNDATION_EXTERN NSString * _Nonnull _ks_getDeviceIPAddress(void);
FOUNDATION_EXTERN NSString * _Nonnull _ks_getNetworkIPAddress(bool isIPv4);
FOUNDATION_EXTERN BOOL _ks_getVPNStatus(void);
FOUNDATION_EXTERN BOOL _ks_getProxyStatus(void);
/// 0:无网络，1:wifi，2:2G，3:3G，4:4G，5:5G
FOUNDATION_EXTERN NSInteger _ks_GetNetworkType(void);

FOUNDATION_EXTERN NSString * _ks_getCurrentLanguages(void);

FOUNDATION_EXTERN float _ks_device_battery(void);
FOUNDATION_EXTERN double _ks_availableMemory(void);
FOUNDATION_EXTERN unsigned long long _ks_totalMemory(void);
FOUNDATION_EXTERN unsigned long long _ks_totalDiskSize(void);
FOUNDATION_EXTERN unsigned long long _ks_availableDiskSize(void);

FOUNDATION_EXTERN NSTimeInterval _ks_timeStampForNow(void);

FOUNDATION_EXTERN NSString * _Nonnull _ks_charToString(unsigned char * _Nonnull digest, NSUInteger length);

FOUNDATION_EXTERN NSString * _Nonnull _ks_md5(NSString *_Nonnull string);

FOUNDATION_EXTERN NSString * _Nullable _ks_sha1OfData(NSData * _Nonnull data);

FOUNDATION_EXTERN NSString * _Nullable _ks_sha1OfPath(NSString * _Nonnull path);

/// str1 >= str2 运算
FOUNDATION_EXTERN BOOL _ks_versionCompare(NSString * _Nonnull str1, NSString * _Nonnull str2);

/// RSA加密/解密
/// @param data 加密/解密数据
/// @param mode 是加密还是解密
/// @param key 密钥
/// @param iv 偏移量
FOUNDATION_EXTERN NSData * _Nullable _ks_AESWithData(NSData * _Nonnull data, CCOperation mode, NSString * _Nonnull key, NSString * _Nonnull iv);

/// RSA加密
FOUNDATION_EXTERN NSData * _Nullable _ks_RSAEncrypt(NSData * _Nonnull data, NSString * _Nonnull key);

NS_ASSUME_NONNULL_END
