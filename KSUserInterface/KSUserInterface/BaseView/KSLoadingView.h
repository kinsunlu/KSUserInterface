//
//  KSLoadingView.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/11/30.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KSLoadingViewStatus) {
    KSLoadingViewStatusNone         = -1,
    KSLoadingViewStatusLoading      = 0,
    KSLoadingViewStatusEmptyData    = 1,
    KSLoadingViewStatusLoadFailure  = 2,
    KSLoadingViewStatusNoNetwork    = 3
} NS_SWIFT_NAME(KSLoadingView.Status);

NS_ASSUME_NONNULL_BEGIN

@protocol KSLoadingAnimationViewProtocol <NSObject>

@required
- (void)startAnimating;
- (void)stopAnimating;
- (CGSize)sizeThatFits:(CGSize)size;

@end

@interface KSLoadingView : UIControl

@property (nonatomic, weak, readonly) UIView<KSLoadingAnimationViewProtocol> *animationView;
@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, weak, readonly) UILabel *titleLabel;
@property (nonatomic, assign) KSLoadingViewStatus status;

- (void)setTitle:(NSString *_Nullable)title forStatus:(KSLoadingViewStatus)status UI_APPEARANCE_SELECTOR;

- (NSString *_Nullable)titleForStatus:(KSLoadingViewStatus)status;

- (void)setImage:(UIImage *_Nullable)image forStatus:(KSLoadingViewStatus)status UI_APPEARANCE_SELECTOR;

- (UIImage *_Nullable)imageForStatus:(KSLoadingViewStatus)status;

/// 默认 = KSLoadingAnimationNormalView.class
@property (nonatomic, class) Class animationViewClass;

@end

@interface KSLoadingAnimationNormalView<KSLoadingAnimationViewProtocol> : UIView

@end

NS_ASSUME_NONNULL_END
