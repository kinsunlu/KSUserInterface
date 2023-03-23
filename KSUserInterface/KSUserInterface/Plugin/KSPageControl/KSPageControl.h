//
//  KSPageControl.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/2.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSPageControl : UIView

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;
/// 如果大小已经不能容纳下numberOfPages个数，将会进入toMuch模式 toMuchEgdeMargin为其边距
@property (nonatomic, assign) CGFloat toMuchEgdeMargin;

/// call in UIScrollView delegate -scrollviewDidScroll:
/// - Parameter scrollView: <#scrollView description#>
- (void)updatePageControlWithScrollView:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
