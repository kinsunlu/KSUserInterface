//
//  KSTabBarItem.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/1.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSTabBarItem : UIControl

@property (nonatomic, copy, nullable) NSString *badgeString;
@property (nonatomic, assign, getter=isShowPointTip) BOOL showPointTip;
@property (nonatomic, strong, nullable) __kindof UIViewController *controller;

@end

@interface KSTabBarLabelItem : KSTabBarItem

@property (nonatomic, weak, readonly) UILabel *titleLabel;
@property (nonatomic, strong) UIColor *selectedTitleColor;
@property (nonatomic, strong) UIColor *normalTitleColor;
@property (nonatomic, strong) UIFont *selectedFont;
@property (nonatomic, strong) UIFont *normalFont;

@end

@interface KSTabBarImageItem : KSTabBarItem

@property (nonatomic, weak, readonly) UIImageView *icon;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) UIImage *normalImage;

@end

@interface KSTabBarSystemItem : KSTabBarImageItem

@property (nonatomic, weak, readonly) UILabel *titleLabel;
@property (nonatomic, strong) UIColor *selectedTitleColor;
@property (nonatomic, strong) UIColor *normalTitleColor;

@end

NS_ASSUME_NONNULL_END
