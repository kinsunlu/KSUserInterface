//
//  KSUITools.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/1.
//

#import "KSUITools.h"

@implementation KSUITools

+ (CGRect)statusBarFrameFromView:(UIView *)view {
    CGRect statusBarFrame;
    if (@available(iOS 13, *)) {
        statusBarFrame = view.window.windowScene.statusBarManager.statusBarFrame;
    } else {
        statusBarFrame = UIApplication.sharedApplication.statusBarFrame;
    }
    return statusBarFrame;
}

+ (UIWindow *)keyWindow {
    if (@available(iOS 13, *)) {
        for (UIWindow *window in UIApplication.sharedApplication.windows) {
            if (window.isKeyWindow) {
                return window;
            }
        }
    } else {
        return UIApplication.sharedApplication.keyWindow;
    }
    return nil;
}

@end
