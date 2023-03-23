//
//  KSStackView.h
//  KSUserInterface
//
//  Created by Kinsun on 2022/8/18.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KSStackViewAxis) {
    KSStackViewAxisHorizontal   = 0,
    KSStackViewAxisVertical     = 1
} NS_SWIFT_NAME(KSStackView.Axis);

typedef NS_ENUM(NSUInteger, KSStackViewLayout) {
    KSStackViewLayoutCenter     = 0,
    KSStackViewLayoutFromStart  = 1,
    KSStackViewLayoutFromEnd    = 2,
    KSStackViewLayoutBothEnds   = 3
} NS_SWIFT_NAME(KSStackView.Layout);

NS_ASSUME_NONNULL_BEGIN

/// 便捷堆叠放置的view，可以按照设定的方式自动布局子视图（subviews）
/// 使用-addSubview: 及-insertSubview: index: 等方法来添加视图
/// 支持sizeThatFits:返回的推荐尺寸
@interface KSStackView : UIView

- (instancetype)initWithSubviews:(NSArray<UIView *> *)subviews;
- (instancetype)initWithSubview:(UIView *)subview;

/// 布局方向
@property (nonatomic, assign) KSStackViewAxis axis;
/// 对齐方式
/// axis = .horizontal 控制subview的x位置
/// axis = .vertical 控制subview的y位置
/// = .bothEnds 时spacing无效，但sizeThatFits:返回的推荐尺寸仍然会使用spacing的值
@property (nonatomic, assign) KSStackViewLayout stackLayout;
/// subview布局方式
/// 当 = .bothEnds
/// 又axis = .horizontal将改变subview的width
/// 或axis = .vertical将改变subview的height
@property (nonatomic, assign) KSStackViewLayout subviewLayout;
/// subview之间的间距
@property (nonatomic, assign) CGFloat spacing;
/// 内边距
@property (nonatomic, assign) UIEdgeInsets contentInset;

/// 移除一个subview，请不要调用subview的removeFromSuperView
/// @param subview 要移除的视图
- (void)removeSubview:(UIView *)subview;

/// 移除一个subview
/// @param index 移除的视图的index
- (UIView *_Nullable)removeSubviewAtIndex:(NSInteger)index;

@end

/// 可与KSStackView配套使用，也可与任意需要依托-sizeThatFits的视图一同使用
/// 将会在-sizeThatFits:返回设定的尺寸而不是根据视图计算
@interface KSStrutView : UIView

/// 便捷构造器，会将contentViewSize设定为contentView.bounds.size
/// @param contentView 嵌套的视图
- (instancetype)initWithContentView:(UIView *)contentView;

/// 嵌套的视图
@property (nonatomic, weak) UIView *contentView;
/// 想在-sizeThatFits:返回的尺寸
@property (nonatomic, assign) CGSize contentViewSize;

@end

/// 可与KSStackView配套使用，也可与任意需要依托-sizeThatFits的视图一同使用
/// 将会在-sizeThatFits:返回根据ContentView计算加上contentInset的size
@interface KSBoxLayoutView <__covariant ContentView: UIView *> : UIView

@property (nonatomic, weak) ContentView contentView;
@property (nonatomic, assign) UIEdgeInsets contentInset;

@end

NS_ASSUME_NONNULL_END
