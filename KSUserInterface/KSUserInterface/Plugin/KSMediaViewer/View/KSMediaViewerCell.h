//
//  KSMediaViewerCell.h
//  KSUserInterface
//
//  Created by Kinsun on 2017/5/16.
//  Copyright © 2017年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSMediaViewerCell : UICollectionViewCell

@property (nonatomic, weak, readonly) UIScrollView *scrollView;
/// 想要控制的主view，例如imageView
@property (nonatomic, weak) UIView *mainView;
/// 主数据源 继承后可随意更改为子数据类型
@property (nonatomic, strong, nullable) id data;

@property (nonatomic, readonly) CGRect mainViewFrameInSuperView;

- (void)chengeImageScaleToMaxOrMin;

@end

NS_ASSUME_NONNULL_END
