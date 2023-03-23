//
//  KSButton.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/10/29.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSButton : UIButton

/// 设置依托高度的圆角，便捷方法本质为设置layer，默认=NO。请注意，变更其值将会变更layer的masksToBounds。
@property (nonatomic, assign, getter=isRoundedCorners) BOOL roundedCorners;

- (void)setBackgroundColor:(UIColor *_Nullable)backgroundColor forState:(UIControlState)state;
- (UIColor *_Nullable)backgroundColorForState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
