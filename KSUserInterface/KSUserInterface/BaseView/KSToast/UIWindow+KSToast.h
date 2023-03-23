//
//  UIWindow+KSToast.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/30.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// only support NSString or NSAttributedString
FOUNDATION_EXTERN void KSToastShowMessage(id);

@class KSToastContentView;
@interface UIWindow (KSToast)

@property (nonatomic, weak, readonly) KSToastContentView *toastView;

/// only support NSString or NSAttributedString
- (void)showToastWithMessage:(id)message;

@end

NS_ASSUME_NONNULL_END
