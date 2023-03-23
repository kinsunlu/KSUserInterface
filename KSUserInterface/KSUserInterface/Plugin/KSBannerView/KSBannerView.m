//
//  KSBannerView.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/2.
//  Copyright © 2020年 Kinsun. All rights reserved.
//

#import "KSBannerView.h"

@interface UIScrollView ()

- (void)_notifyDidScroll;
- (void)_scrollViewWillBeginDragging;
- (void)_scrollViewDidEndDraggingForDelegateWithDeceleration:(BOOL)deceleration;
- (void)_delegateScrollViewAnimationEnded;

@end

@implementation KSBannerView {
    NSArray <UIView *> *_views;
    NSInteger _visibleCount;
    NSInteger _numbers;
    NSInteger _currentIndex;
    BOOL _isAnimating;
    
    NSTimer *_timer;
}
@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.bounces = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.clipsToBounds = YES;
        self.scrollsToTop = NO;
        self.backgroundColor = UIColor.whiteColor;
        _isAnimating = NO;
        _itemMargin = 0.0;
        _visibleCount = 3;
        _currentIndex = 0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isDragging || self.isDecelerating || self.isTracking || _isAnimating ) return;
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat viewY = 0.0;
    CGFloat viewX = _visibleCount == 5 ? -(windowWidth-_itemMargin*0.5) : viewY;
    CGFloat viewW = windowWidth-_itemMargin;
    CGFloat viewH = windowSize.height;
    
    for (NSInteger i = 0; i < _views.count; i++) {
        UIView *view = [_views objectAtIndex:i];
        CGRect frame = (CGRect){viewX, viewY, viewW, viewH};
        view.frame = frame;
        viewX = CGRectGetMaxX(frame)+_itemMargin;
    }
    self.contentSize = (CGSize){windowWidth*3.0, 0.0};
    self.contentOffset = (CGPoint){windowWidth, 0.0};
}

- (void)setDelegate:(id<KSBannerViewDelegate>)delegate {
    [super setDelegate:delegate];
    if (delegate != nil) {
        [self reloadData];
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    NSAssert(NO, @"请不要给KSBannerView设置内边距。");
}

- (void)setItemMargin:(CGFloat)itemMargin {
    _itemMargin = itemMargin;
    NSInteger visibleCount = itemMargin == 0.0 ? 3 : 5;
    if (_visibleCount != visibleCount) {
        _visibleCount = visibleCount;
        if (self.delegate != nil) {
            [self reloadData];
        }
    }
}

- (void)reloadData {
    if (_views != nil && _views.count > 0) {
        for (UIView *view in _views) {
            [view removeFromSuperview];
        }
    }
    id <KSBannerViewDelegate> delegate = self.delegate;
    _numbers = [delegate numberInBannerView:self];
    switch (_numbers) {
        case 0:
            return;
        case 1:
            self.scrollEnabled = NO;
            break;
        default:
            self.scrollEnabled = YES;
            break;
    }
    _currentIndex = 0;
    NSMutableArray <UIView *> *views = [NSMutableArray arrayWithCapacity:_visibleCount];
    NSInteger def = floor(_visibleCount/2.0);
    for (NSInteger i = 0; i < _visibleCount; i++) {
        NSInteger index = [self _indexFromIndex:i-def];
        UIView *view = [delegate itemInBannerView:self];
        [delegate bannerView:self configurationItem:view atIndex:index];
        [views addObject:view];
        [self addSubview:view];
    }
    _views = views;
    self.contentOffset = (CGPoint){self.bounds.size.width, 0.0};
}

- (NSInteger)_indexFromIndex:(NSInteger)index {
    if (index < 0) {
        return [self _indexFromIndex:_numbers+index];
    } else if (index >= _numbers) {
        return [self _indexFromIndex:_numbers-index];
    }
    return index;
}

- (void)_updateVisibleViews {
    id <KSBannerViewDelegate> delegate = self.delegate;
    NSInteger def = floor(_visibleCount/2.0);
    for (NSInteger i = 0; i < _views.count; i++) {
        UIView *view = [_views objectAtIndex:i];
        [delegate bannerView:self configurationItem:view atIndex:[self _indexFromIndex:i+_currentIndex-def]];
    }
    self.contentOffset = (CGPoint){self.bounds.size.width, 0.0};
    if ([delegate respondsToSelector:@selector(bannerView:didChangeCurrentItemAtIndex:)]) {
        [delegate bannerView:self didChangeCurrentItemAtIndex:_currentIndex];
    }
}

- (void)_updateBannerIndex {
    CGFloat windowWidth = self.bounds.size.width;
    CGFloat offsetX = self.contentOffset.x;
    BOOL isScrollToBefor = offsetX == 0.0;
    BOOL isScrollToAfter = floor(offsetX) == floor(windowWidth*2.0);
    if (isScrollToBefor) {
        _currentIndex = [self _indexFromIndex:_currentIndex-1];
    } else if (isScrollToAfter) {
        _currentIndex = [self _indexFromIndex:_currentIndex+1];
    } else { return; }
    [self _updateVisibleViews];
}

- (void)_nextPage {
    _isAnimating = YES;
    [self setContentOffset:(CGPoint){self.bounds.size.width*2.0, 0.0} animated:YES];
}

- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
    if (_autoScroll) {
        [self _addTimer];
    } else {
        [self _removeTimer];
    }
}

- (void)_addTimer {
    if (_timer == nil) {
        __weak typeof(self) weakSelf = self;
        _timer = [NSTimer scheduledTimerWithTimeInterval:3.5 repeats:YES block:^(NSTimer *timer) {
            [weakSelf _nextPage];
        }];
    }
}

- (void)_removeTimer {
    if (_timer != nil) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)_notifyDidScroll {
    [super _notifyDidScroll];
    [self _updateBannerIndex];
}

- (void)_scrollViewWillBeginDragging {
    [super _scrollViewWillBeginDragging];
    if (_autoScroll) {
        [self _removeTimer];
    }
}

- (void)_scrollViewDidEndDraggingForDelegateWithDeceleration:(BOOL)deceleration {
    [super _scrollViewDidEndDraggingForDelegateWithDeceleration:deceleration];
    if (_autoScroll) {
        [self _addTimer];
    }
}

- (void)_delegateScrollViewAnimationEnded {
    [super _delegateScrollViewAnimationEnded];
    _isAnimating = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    id <KSBannerViewDelegate> delegate = self.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(bannerView:didClikeItemAtIndex:)]) {
        CGPoint location = [touches.anyObject locationInView:self];
        if (CGRectContainsPoint(self.bounds, location)) {
            [delegate bannerView:self didClikeItemAtIndex:_currentIndex];
            return;
        }
    }
    [super touchesEnded:touches withEvent:event];
}

- (void)dealloc {
    [self _removeTimer];
}

@end
