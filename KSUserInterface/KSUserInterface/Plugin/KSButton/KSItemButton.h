//
//  KSItemButton.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/1.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSItemButton : UIControl

@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, weak, readonly) UILabel *titleLabel;

@property (nonatomic, assign) UIEdgeInsets imageViewInset;
@property (nonatomic, assign) UIEdgeInsets titleLabelInset;

@end

NS_ASSUME_NONNULL_END
