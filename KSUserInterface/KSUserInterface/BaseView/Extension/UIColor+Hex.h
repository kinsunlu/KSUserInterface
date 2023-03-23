//
//  UIColor+Hex.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/11/30.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Hex)

/// 通过16进制整型得到一个UIColor对象（ARGB）， 例如：0xFFFF3322,
/// @param hex 16进制整型
+ (instancetype)colorWithAlphaHex:(unsigned long)hex;
/// 通过16进制整型得到一个UIColor对象（RGB）， 例如：0xFF3322
/// @param hex 16进制整型
/// @param alpha 颜色透明度
+ (instancetype)colorWithHex:(unsigned long)hex alpha:(double)alpha;
/// 通过16进制整型得到一个UIColor对象（RGB），透明度为100%
/// @param hex 16进制整型
+ (instancetype)colorWithHex:(unsigned long)hex;

/// 通过16进制整型字符串得到一个UIColor对象（RGB）， 例如："0xFF3322"
/// @param hexString 16进制整型字符串
/// @param alpha 颜色透明度
+ (instancetype)colorWithHexString:(NSString *)hexString alpha:(double)alpha;
/// 通过16进制整型字符串得到一个UIColor对象（RGB）， 例如："0xFF3322"或"0xFFFF3322"，如果字符串长度等于8颜色透明度将等于100%
/// @param hexString 16进制整型字符串
+ (instancetype)colorWithHexString:(NSString *)hexString;

@end

@interface UIColor (HexColor)

/// 0xFF0000
@property (nonatomic, readonly, class) UIColor *ks_red;
/// 0x80FF0000
@property (nonatomic, readonly, class) UIColor *ks_lightRed;
/// 0xFF3F3F
@property (nonatomic, readonly, class) UIColor *ks_lightRed1;
/// 0xFFFFFF
@property (nonatomic, readonly, class) UIColor *ks_white;
/// 0x000000
@property (nonatomic, readonly, class) UIColor *ks_black;
/// 0x80000000
@property (nonatomic, readonly, class) UIColor *ks_lightBlack;
/// 0x686868
@property (nonatomic, readonly, class) UIColor *ks_gray;
/// 0xEAEAEA
@property (nonatomic, readonly, class) UIColor *ks_lightGray;
/// 0xAEAEAE
@property (nonatomic, readonly, class) UIColor *ks_lightGray1;
/// 0x878787
@property (nonatomic, readonly, class) UIColor *ks_lightGray2;
/// 0xF5F2F2
@property (nonatomic, readonly, class) UIColor *ks_lightGray6;
/// 0x999999
@property (nonatomic, readonly, class) UIColor *ks_lightGray7;

/// 默认=0xF8F8F8
@property (nonatomic, class) UIColor *ks_background;
@property (nonatomic, class) UIColor *ks_main;
@property (nonatomic, class) UIColor *ks_lightMain;
@property (nonatomic, class) UIColor *ks_title;
@property (nonatomic, class) UIColor *ks_lightTitle;

@end

NS_ASSUME_NONNULL_END
