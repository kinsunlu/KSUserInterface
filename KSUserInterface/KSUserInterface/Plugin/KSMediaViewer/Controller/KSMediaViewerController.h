//
//  KSMediaViewerController.h
//  KSUserInterface
//
//  Created by Kinsun on 2017/5/16.
//  Copyright © 2017年 Kinsun. All rights reserved.
//

#import "KSBaseViewController.h"
#import "KSMediaViewerView.h"
#import "KSMediaViewerCell.h"

NS_ASSUME_NONNULL_BEGIN

/// 带转场动画的媒体浏览器范型类，不可以直接使用必须继承使用
@interface KSMediaViewerController <__covariant Data, View: KSMediaViewerView*, Cell: KSMediaViewerCell*> : KSSecondaryViewController <UICollectionViewDelegate>

@property (nonatomic, strong) View view;

/// 此方法不应该被调用，自定义控制器主view， 类型必须为KSMediaViewerView或其子类
/// 自定义的cell也应该在此方法中注册使用view.collectionView 进行注册
- (View)loadMediaViewerView;

/// 当前页面的index
@property (nonatomic, assign) NSInteger currentIndex;

/// 继承后 可更改为转场动画时的过渡动画画面中的图片内容
@property (nonatomic, readonly, nullable) UIImage *currentThumb;

/// 实时获取关闭位置，此操作是为了左右滑动时滑动到不同的item，关闭时要定位到所展示的item位置
@property (nonatomic, copy) CGRect (^itemFrameAtIndex)(NSUInteger index);

@property (nonatomic, copy) void (^willBeginCloseAnimation)(NSUInteger index);

- (instancetype)initWithTransitionAnimation:(BOOL)transitionAnimation;

/// 主数据源，继承后自行处理其内容
@property (nonatomic, strong, readonly) NSArray <Data>*dataArray;

/// 设置数据源，可重写此方法达到个性化需求
/// @param dataArray 设置初始化时主数据源
/// @param currentIndex 画面默认要展示第几条
- (void)setDataArray:(NSArray <Data>*)dataArray currentIndex:(NSInteger)currentIndex;

@property (nonatomic, readonly) Cell currentCell;

/// 当前的index变化时会调用此方法
/// @param currentIndex 当前改变后的index
- (void)currentIndexDidChanged:(NSInteger)currentIndex;

/// 点击画面中的条目后会回调此方法
- (void)didClickViewCurrentItem;

/// 将要给collectionView返回cell时会调用此方法
/// @param indexPath 返回cell所在的indexPath
/// @param data 数据源中的对应数据
/// @param collectionView 当前主collectionView
- (Cell)mediaViewerCellAtIndexPath:(NSIndexPath *)indexPath data:(Data)data ofCollectionView:(UICollectionView *)collectionView;

- (void)mediaViewerCellWillBeganPan;
- (void)mediaViewerCellDidSwipe;
- (void)mediaViewerCellScrollViewDidZoom:(UIScrollView *)scrollView;

@end

@interface KSMediaViewerController (FrameTools)

+ (CGRect)transitionThumbViewFrameInSuperView:(UIView *)superView atImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
