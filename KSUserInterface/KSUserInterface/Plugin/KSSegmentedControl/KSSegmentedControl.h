//
//  KSSegmentedControl.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/11/25.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSSegmentedControl : UIView

@property (nonatomic, strong, readonly) NSArray <NSString *> *items;
@property (nonatomic, assign) CGFloat egdeMargin;

@property (nonatomic, strong, readonly) UIFont *normalFont;
@property (nonatomic, strong, readonly) UIFont *selectedFont;
- (void)setNormalFont:(UIFont *)normalFont selectedFont:(UIFont *_Nullable)selectedFont;

@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, assign) NSUInteger selectedSegmentIndex;
@property (nonatomic, copy, nullable) void (^didClickItem)(KSSegmentedControl *segmentedControl, NSUInteger index);

@property (nonatomic, assign, getter=isShowIndicator) BOOL showIndicator;
@property (nonatomic, strong) UIColor *indndicatorColor;
@property (nonatomic, assign) CGFloat indicatorHeight;
@property (nonatomic, assign) CGFloat indicatorBottomMargin;

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray <NSString *> *)items;
- (void)updateIndicatorProportion:(CGFloat)proportion;

@end

NS_ASSUME_NONNULL_END
