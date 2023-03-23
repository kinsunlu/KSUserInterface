//
//  KSPageSlideSegmented.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/13.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSPageSlideSegmented : UIScrollView

@property (nonatomic, copy) NSArray <NSString *> *items;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, assign) NSUInteger selectedSegmentIndex;
@property (nonatomic, copy, nullable) void (^didClickItemCallback)(KSPageSlideSegmented *segmentedControl, NSInteger index);

@end

NS_ASSUME_NONNULL_END
