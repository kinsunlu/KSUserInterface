//
//  KSDeviceInformation.h
//  KSFoundation
//
//  Created by Kinsun on 2020/12/7.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 当异步获取的值发生变化时会发送此通知，并在通知的UserInfo中使用KSDeviceInformationUpdateKey来确定是哪个值发生了变化，eg[KSDeviceInformationUpdate: @(KSDeviceInformationUpdate)]。
FOUNDATION_EXTERN NSNotificationName const KSDeviceInformationNeedUpdateNotification NS_SWIFT_NAME(KSDeviceInformation.NeedUpdateNotification);

FOUNDATION_EXTERN NSString * const KSDeviceInformationUpdateKey NS_SWIFT_NAME(KSDeviceInformation.UpdateKey);

typedef NS_ENUM(NSInteger, KSDeviceInformationUpdate) {
    KSDeviceInformationUpdateIDFA = 1,
    KSDeviceInformationUpdateLocation = 2,
    KSDeviceInformationUpdateUserAgent = 3
} NS_SWIFT_NAME(KSDeviceInformation.Update);

@interface KSDeviceInformation : KSBaseModel

@property (nonatomic, copy, readonly) NSString *imsi;
/// 设备浏览器的User-Agent字符串,启动时可能为空，启动后可以以通知形式立即回调
@property (nonatomic, copy, nullable, readonly) NSString *ua;
/// 设备型号
@property (nonatomic, copy, readonly) NSString *model;
/// 设备操作系统版本号
@property (nonatomic, copy, readonly) NSString *osv;
/// 苹果广告标识 id
@property (nonatomic, copy, nullable, readonly) NSString *idfa;
/// 本机安装目录名称
@property (nonatomic, copy, readonly) NSString *idfv;
/// 本地IP地址
@property (nonatomic, copy, readonly) NSString *ip;
/// ipv6
@property (nonatomic, copy, readonly) NSString *ipv6;
/// 自制唯一标识符，相同证书包名下重装应用会一直保持一致，可做唯一标识符
@property (nonatomic, copy, readonly) NSString *suuid;
/// 运营商  0未知 1移动 2联通 3电信
@property (nonatomic, assign, readonly) NSInteger carrier;
/// 设备联网方式 0:无网络，1:wifi，2:2G，3:3G，4:4G，5:5G
@property (nonatomic, assign, readonly) NSInteger connectionType;
/// 语言标识符
@property (nonatomic, copy, readonly) NSString *lang;
/// 1:竖屏 2:横屏
@property (nonatomic, assign, readonly) NSInteger orientation;
/// 设备屏幕分辨率（像素）
@property (nonatomic, assign, readonly) NSInteger screenWidth;
@property (nonatomic, assign, readonly) NSInteger screeHeight;
/// 屏幕密度值 1 为标清，2 为高清，3为超清
@property (nonatomic, assign, readonly) NSInteger pxratio;
/// 设备位置(精确到一公里)，启动时可能为空，启动后可以以通知形式立即回调
/// 需要应用申请过定位权限才能有值填充
@property (nonatomic, assign, readonly) double lat;
@property (nonatomic, assign, readonly) double lng;

@property (nonatomic, class, readonly) KSDeviceInformation *device;

@end

@interface KSApplicationInformation : KSBaseModel

/// app 名称
@property (nonatomic, copy, readonly) NSString *name;
/// app 包名
@property (nonatomic, copy, readonly) NSString *bundle;
/// app 版本号
@property (nonatomic, copy, readonly) NSString *version;
/// app build
@property (nonatomic, copy, readonly) NSString *build;

@property (nonatomic, class, readonly) KSApplicationInformation *application;

@end

NS_ASSUME_NONNULL_END
