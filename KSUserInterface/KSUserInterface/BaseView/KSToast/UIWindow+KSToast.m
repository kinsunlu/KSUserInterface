//
//  UIWindow+KSToast.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/30.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "UIWindow+KSToast.h"
#import "KSToast.h"
#import "KSUITools.h"

void KSToastShowMessage(id msg) {
    [KSUITools.keyWindow showToastWithMessage:msg];
}

@implementation UIWindow (KSToast)

static NSInteger k_KSToastInWindowTag = NSIntegerMax-10;

- (KSToastContentView *)toastView {
    return [self viewWithTag:k_KSToastInWindowTag];
}

- (void)showToastWithMessage:(id)message {
    KSToastContentView *toast = self.toastView;
    if (toast != nil) {
        [toast removeFromSuperview];
    }
    toast = [[KSToastContentView alloc] initWithFrame:self.bounds style:KSToastStyleMessage];
    toast.tag = k_KSToastInWindowTag;
    toast.userInteractionEnabled = NO;
    toast.toast.message = message;
    [self addSubview:toast];
    [toast.toast showToastWithCompletion:^(KSToast *k_toast) {
        [k_toast.superview removeFromSuperview];
    }];
}

@end
