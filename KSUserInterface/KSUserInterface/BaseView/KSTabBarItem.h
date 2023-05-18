//
//  KSTabBarItem.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/1.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSTabBarItem<__covariant View: UIView*> : UIControl

@property (nonatomic, weak, readonly) View contentView;
/// 默认={7.0, 7.0, 4.0, 7.0}
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, copy, nullable) NSString *badgeString;
@property (nonatomic, assign, getter=isShowPointTip) BOOL showPointTip;
@property (nonatomic, strong, nullable) __kindof UIViewController *controller;

- (instancetype)initWithFrame:(CGRect)frame contentView:(View)contentView;

@end

@interface KSTabBarLabelItem : KSTabBarItem<UILabel*>

@property (nonatomic, strong) UIColor *selectedTitleColor;
@property (nonatomic, strong) UIColor *normalTitleColor;
@property (nonatomic, strong) UIFont *selectedFont;
@property (nonatomic, strong) UIFont *normalFont;

@end

@interface KSTabBarImageItem : KSTabBarItem<UIImageView*>

@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImage *normalImage;

@end

@interface KSTabBarSystemItem : KSTabBarItem<UIView*>

@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic) CGFloat margin;
@property (nonatomic, strong) UIColor *selectedTitleColor;
@property (nonatomic, strong) UIColor *normalTitleColor;
@property (nonatomic, strong) UIFont *selectedFont;
@property (nonatomic, strong) UIFont *normalFont;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImage *normalImage;

@end

NS_ASSUME_NONNULL_END
