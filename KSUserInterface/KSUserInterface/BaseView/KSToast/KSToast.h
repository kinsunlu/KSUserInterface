//
//  KSToast.h
//  
//
//  Created by Kinsun on 2018/12/20.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIWindow+KSToast.h"

typedef NS_ENUM(NSInteger, KSToastStyle) {
    KSToastStyleMessage = 0,
    KSToastStyleProgress,
    KSToastStyleLoading
} NS_SWIFT_NAME(KSToast.Style);

NS_ASSUME_NONNULL_BEGIN

@protocol KSToastLoadingViewProtocol <NSObject>

@required
- (void)startAnimating;
- (void)stopAnimating;
- (CGSize)sizeThatFits:(CGSize)size;

@end

@interface KSToast : UIView

@property (nonatomic, assign, readonly) KSToastStyle style;

/// KSToastStyleLoading type only
@property (nonatomic, weak, readonly) UIView<KSToastLoadingViewProtocol> *loadingView;

/// KSToastStyleProgress type only
@property (nonatomic) float progress;

/// KSToastStyleMessage type only support NSString or NSAttributedString
@property (nonatomic, nullable) id message;

- (instancetype)initWithStyle:(KSToastStyle)style;
- (instancetype)initWithFrame:(CGRect)frame style:(KSToastStyle)style;

- (void)showToast;
- (void)showToastWithCompletion:(void (^ __nullable)(KSToast *toast))completion;

- (void)dismissToast;
- (void)dismissToastWithCompletion:(void (^ __nullable)(KSToast *toast))completion;

/// 默认 = KSToastLoadingNormalView.class
@property (nonatomic, class) Class loadingViewClass;

@end

@interface KSToastContentView : UIView

@property (nonatomic, weak, readonly) KSToast *toast;

- (instancetype)initWithStyle:(KSToastStyle)style;
- (instancetype)initWithFrame:(CGRect)frame style:(KSToastStyle)style;

@end

@interface KSToastLoadingNormalView<KSToastLoadingViewProtocol> : UIActivityIndicatorView

@end

NS_ASSUME_NONNULL_END
