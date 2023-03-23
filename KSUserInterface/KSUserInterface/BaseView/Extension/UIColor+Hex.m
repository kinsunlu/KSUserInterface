//
//  UIColor+Hex.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/11/30.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (NSCache <NSNumber *, UIColor *>*)_cacheColorTable {
    static NSCache <NSNumber *, UIColor *>*k_cacheColorTable = nil;
    if (k_cacheColorTable == nil) {
        @synchronized (self) {
            if (k_cacheColorTable == nil) {
                k_cacheColorTable = NSCache.alloc.init;
            }
        }
    }
    return k_cacheColorTable;
}

+ (instancetype)colorWithAlphaHex:(unsigned long)hex {
    NSNumber *key = [NSNumber numberWithUnsignedLong:hex];
    NSCache *cacheColorTable = self._cacheColorTable;
    UIColor *color = [cacheColorTable objectForKey:key];
    if (color == nil) {
        CGFloat alpha = ((hex & 0xFF000000) >> 24)/255.0;
        CGFloat red = ((hex & 0xFF0000) >> 16)/255.0;
        CGFloat green = ((hex & 0xFF00) >> 8)/255.0;
        CGFloat blue = (hex & 0xFF)/255.0;
        color = [self colorWithRed:red green:green blue:blue alpha:alpha];
        [cacheColorTable setObject:color forKey:key];
    }
    return color;
}

+ (instancetype)colorWithHex:(unsigned long)hex alpha:(double)alpha {
    unsigned long hexAlpha = ((unsigned long)(alpha*255.0)) << 24;
    return [self colorWithAlphaHex:hexAlpha+hex];
}

+ (instancetype)colorWithHex:(unsigned long)hex {
    return [self colorWithHex:hex alpha:1.0];
}

+ (instancetype)colorWithHexString:(NSString *)hexString alpha:(double)alpha {
    unsigned long hex = [self _hexFromString:hexString];
    return [self colorWithHex:hex alpha:alpha];
}

+ (instancetype)colorWithHexString:(NSString *)hexString {
    unsigned long hex = [self _hexFromString:hexString];
    if (hexString.length == 8) hex += 255 << 24;
    return [self colorWithAlphaHex:hex];
}

+ (unsigned long)_hexFromString:(NSString *)string {
    if (string != nil) {
        unsigned long hex = 0;
        const char *str = [string cStringUsingEncoding:NSUTF8StringEncoding];
        sscanf(str, "%lx", &hex);
        return hex;
    }
    return 0;
}

@end

@implementation UIColor (HexColor)

static UIColor *__ks__red = nil;
static UIColor *__ks__lightRed = nil;
static UIColor *__ks__lightRed1 = nil;
static UIColor *__ks__white = nil;
static UIColor *__ks__black = nil;
static UIColor *__ks__lightBlack = nil;
static UIColor *__ks__gray = nil;
static UIColor *__ks__lightGray = nil;
static UIColor *__ks__lightGray1 = nil;
static UIColor *__ks__lightGray2 = nil;
static UIColor *__ks__lightGray6 = nil;
static UIColor *__ks__lightGray7 = nil;
static UIColor *__ks__background = nil;
static UIColor *__ks__main = nil;
static UIColor *__ks__lightMain = nil;
static UIColor *__ks__title = nil;
static UIColor *__ks__lightTitle = nil;

+ (void)load {
    __ks__red = [self colorWithHex:0xFF585C];
    __ks__lightRed = [self colorWithAlphaHex:0x80FF0000];
    __ks__lightRed1 = [self colorWithHex:0xFF3F3F];
    __ks__white = [self colorWithHex:0xFFFFFF];
    __ks__black = [self colorWithHex:0x000000];
    __ks__lightBlack = [self colorWithAlphaHex:0x80000000];
    __ks__gray = [self colorWithHex:0x686868];
    __ks__lightGray = [self colorWithHex:0xEAEAEA];
    __ks__lightGray1 = [self colorWithHex:0xAEAEAE];
    __ks__lightGray2 = [self colorWithHex:0x878787];
    __ks__lightGray6 = [self colorWithHex:0xF5F2F2];
    __ks__lightGray7 = [self colorWithHex:0x9894A5];
    __ks__background = [self colorWithHex:0xF8F8F8];
    __ks__main = [self colorWithHex:0x1E90FF];
    __ks__lightMain = [self colorWithHex:0xB0E0E6];
    __ks__title = [self colorWithHex:0x000000];
    __ks__lightTitle = [self colorWithHex:0x333333];
}

+ (UIColor *)ks_red { return __ks__red; }
+ (UIColor *)ks_lightRed { return __ks__lightRed; }
+ (UIColor *)ks_lightRed1 { return __ks__lightRed1; }
+ (UIColor *)ks_white { return __ks__white; }
+ (UIColor *)ks_black { return __ks__black; }
+ (UIColor *)ks_lightBlack { return __ks__lightBlack; }
+ (UIColor *)ks_gray { return __ks__gray; }
+ (UIColor *)ks_lightGray { return __ks__lightGray; }
+ (UIColor *)ks_lightGray1 { return __ks__lightGray1; }
+ (UIColor *)ks_lightGray2 { return __ks__lightGray2; }
+ (UIColor *)ks_lightGray6 { return __ks__lightGray6; }
+ (UIColor *)ks_lightGray7 { return __ks__lightGray7; }
+ (UIColor *)ks_background { return __ks__background; }
+ (void)setKs_background:(UIColor *)ks_background { __ks__background = ks_background; }
+ (UIColor *)ks_main { return __ks__main; }
+ (void)setKs_main:(UIColor *)ks_main { __ks__main = ks_main; }
+ (UIColor *)ks_lightMain { return __ks__lightMain; }
+ (void)setKs_lightMain:(UIColor *)ks_lightMain { __ks__lightMain = ks_lightMain; }
+ (UIColor *)ks_title { return __ks__title; }
+ (void)setKs_title:(UIColor *)ks_title { __ks__title = ks_title; }
+ (UIColor *)ks_lightTitle { return __ks__lightTitle; }
+ (void)setKs_lightTitle:(UIColor *)ks_lightTitle { __ks__lightTitle = ks_lightTitle; }

@end
