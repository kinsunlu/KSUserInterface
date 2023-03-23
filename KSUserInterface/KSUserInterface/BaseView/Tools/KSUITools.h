//
//  KSUITools.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSUITools : NSObject

@property (nonatomic, readonly, class, nullable) UIWindow *keyWindow;

+ (CGRect)statusBarFrameFromView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
