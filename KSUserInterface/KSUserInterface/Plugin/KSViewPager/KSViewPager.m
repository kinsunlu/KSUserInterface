//
//  KSViewPager.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/11/26.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSViewPager.h"

@interface _KSViewPagerHeaderView : UIView

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation _KSViewPagerHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _contentView.frame = self.bounds;
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView != nil) {
        [_contentView removeFromSuperview];
    }
    if (contentView != nil) {
        [self addSubview:contentView];
        _contentView = contentView;
    }
}

- (UIView *)superview {
    return _scrollView ?: super.superview;
}

@end

static NSString * const k_KSViewPagerKeyPathContentOffset = @"contentOffset";

@interface KSViewPager () <UIScrollViewDelegate>

@end

@implementation KSViewPager {
    __weak _KSViewPagerHeaderView *_headerContentView;
    __weak UIScrollView *_currentScrollView;
    __weak UIScrollView *_scrollView;
}

- (instancetype)initWithScrollViews:(NSArray <UIScrollView *> *)scrollViews {
    return [self initWithScrollViews:scrollViews mode:KSViewPagerHeaderChangeModeViewY];
}

- (instancetype)initWithScrollViews:(NSArray <UIScrollView *> *)scrollViews mode:(KSViewPagerHeaderChangeMode)mode {
    NSAssert(scrollViews != nil && scrollViews.count > 0, @"scrollViews is nil or not has element");
    if (self = [super initWithFrame:CGRectZero]) {
        _scrollViews = scrollViews;
        _mode = mode;
        _headerHeight = 210.f;
        _headerTabHeight = 44.f;
        
        UIColor *clearColor = UIColor.clearColor;
        self.backgroundColor = clearColor;
        
        UIScrollView *scrollView = UIScrollView.alloc.init;
        scrollView.backgroundColor = clearColor;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.bounces = NO;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        _scrollView = scrollView;
        
        _KSViewPagerHeaderView *headerContentView = _KSViewPagerHeaderView.alloc.init;
        [self addSubview:headerContentView];
        _headerContentView = headerContentView;
        
        _currentScrollView = scrollViews.firstObject;
        _headerContentView.scrollView = _currentScrollView;
        for (UIScrollView *k_scrollView in scrollViews) {
            [self _addObserversForScrollView:k_scrollView];
            [scrollView addSubview:k_scrollView];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    _scrollView.frame = bounds;
    
    CGFloat viewY;
    CGFloat viewH;
    if (_mode == KSViewPagerHeaderChangeModeViewY) {
        viewY = _navHeight;
        viewH = _headerHeight;
    } else {
        viewY = 0.0;
        CGFloat height = _headerContentView.bounds.size.height;
        if (height == 0.f) {
            viewH = _headerHeight;
        } else {
            viewH = height;
        }
    }
    _headerContentView.frame = (CGRect){0.0, viewY, bounds.size.width, viewH};
    
    [self _layoutScrollViews];
}

- (void)_layoutScrollViews {
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat viewX = 0.0;
    UIEdgeInsets inset = _contentInset;
    inset.top = _headerHeight+_navHeight;
    NSUInteger count = _scrollViews.count;
    for (NSUInteger i = 0; i < count; i++) {
        UIScrollView *scrollView = [_scrollViews objectAtIndex:i];
        viewX = windowWidth*i;
        scrollView.contentInset = inset;
        scrollView.scrollIndicatorInsets = inset;
        scrollView.frame = (CGRect){viewX, 0.0, windowSize};
    }
    _scrollView.contentSize = (CGSize){windowWidth*count, 0.0};
}

- (void)_addObserversForScrollView:(UIScrollView *)scrollView {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [scrollView addObserver:self forKeyPath:k_KSViewPagerKeyPathContentOffset options:options context:nil];
}

- (void)_removeObserversForScrollView:(UIScrollView *)scrollView {
    [scrollView removeObserver:self forKeyPath:k_KSViewPagerKeyPathContentOffset];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIScrollView *)object change:(NSDictionary *)change context:(void *)context {
    // 遇到这些情况就直接返回
    if (!self.userInteractionEnabled || self.hidden) return;
    if ([keyPath isEqualToString:k_KSViewPagerKeyPathContentOffset]) {
        [self _scrollView:object didChangeContentOffset:object.contentOffset];
    }
}

- (void)_scrollView:(UIScrollView *)scrollView didChangeContentOffset:(CGPoint)contentOffset {
    if (scrollView == _currentScrollView) {
        CGFloat offsetY = scrollView.contentOffset.y;//当前屏幕顶部距离header底部距离+navHeight
        UIView *headerView = _headerContentView;
        CGFloat headerHeight = _headerHeight, navHeight = _navHeight, headerTabHeight = _headerTabHeight;
        if (_mode == KSViewPagerHeaderChangeModeViewY) {
            CGFloat y = -offsetY-headerHeight;//-ky+navHeight
            CGFloat limitY = -(headerHeight-headerTabHeight-navHeight);
//        CGFloat inTop = scrollView.contentInset.top;
//        CGFloat ky = offsetY+inTop;
            if (y < limitY) {//进入悬浮tabbar//offsetY+_headerTabHeight+navHeight
                y = limitY;
            } else if (y > navHeight){//进入停留header
                y = navHeight;
            }
            CGRect frame = headerView.frame;
            frame.origin.y = y;
            headerView.frame = frame;
        } else {
            CGFloat h = -offsetY;
            CGFloat minH = navHeight+headerTabHeight;
            if (h < minH) {
                h = minH;
            }
            CGRect frame = headerView.frame;
            frame.size.height = h;
            headerView.frame = frame;
        }
    }
}

- (void)updateScrollView:(UIScrollView *)scrollView targetContentOffset:(CGPoint)targetContentOffset {
    if (scrollView == _currentScrollView) {
        CGPoint contentOffset = targetContentOffset;
        CGFloat offsetY = contentOffset.y;
        CGFloat limitY = _navHeight+_headerTabHeight;
        if (-offsetY > limitY) {
            for (UIScrollView *k_scrollView in _scrollViews) {
                if (k_scrollView != scrollView) {
                    if (-k_scrollView.contentOffset.y >= limitY) {
                        k_scrollView.contentOffset = contentOffset;
                    }
                }
            }
        } else {
            contentOffset.y = -limitY;
            for (UIScrollView *k_scrollView in _scrollViews) {
                if (k_scrollView != scrollView) {
                    if (-k_scrollView.contentOffset.y > limitY) {
                        k_scrollView.contentOffset = contentOffset;
                    }
                }
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat width = scrollView.bounds.size.width;
    NSInteger page = ceil((offsetX-width*0.5f)/width);
    [self _updateCurrentPage:page];
    if (_delegate != nil && [_delegate respondsToSelector:@selector(viewPager:scrollViewDidScroll:)]) {
        [_delegate viewPager:self scrollViewDidScroll:scrollView];
    }
}

- (void)setHeaderView:(UIView *)headerView {
    _headerContentView.contentView = headerView;
}

- (UIView *)headerView {
    return _headerContentView.contentView;
}

- (BOOL)_updateCurrentPage:(NSUInteger)currentPage {
    BOOL isValid = [self _validIndex:currentPage];
    if (isValid) {
        _currentPage = currentPage;
        _currentScrollView = [_scrollViews objectAtIndex:currentPage];
        _headerContentView.scrollView = _currentScrollView;
        if (_delegate != nil && [_delegate respondsToSelector:@selector(viewPager:currentPageDidChange:)]) {
            [_delegate viewPager:self currentPageDidChange:currentPage];
        }
    }
    return isValid;
}

- (BOOL)_validIndex:(NSUInteger)page {
    return page != _currentPage && page >= 0 && page < _scrollViews.count;
}

- (void)setCurrentPage:(NSUInteger)currentPage {
    [self setCurrentPage:currentPage animated:YES];
}

- (void)setCurrentPage:(NSUInteger)currentPage animated:(BOOL)animated {
    if ([self _validIndex:currentPage]) {
        _currentPage = currentPage;
        [_scrollView setContentOffset:(CGPoint){_scrollView.bounds.size.width*currentPage} animated:animated];
    }
}

- (void)dealloc {
    for (UIScrollView *scrollView in _scrollViews) {
        [self _removeObserversForScrollView:scrollView];
    }
}

@end
