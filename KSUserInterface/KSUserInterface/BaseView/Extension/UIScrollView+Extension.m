//
//  UIScrollView+Extension.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/3.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "UIScrollView+Extension.h"
#import <objc/runtime.h>
#import <MJRefresh/MJRefresh.h>

@interface UIScrollView ()

- (void)_notifyDidScroll;
- (void)_scrollViewDidEndDeceleratingForDelegate;
- (void)_scrollViewDidEndDraggingForDelegateWithDeceleration:(BOOL)deceleration;
- (void)_performScrollViewWillEndDraggingInvocationsWithVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset unclampedOriginalTarget:(CGPoint)originalTarget;

@end

@implementation UIScrollView (KSUserInterface)
@dynamic delegate, refreshHeaderClass, loadMoreFooterClass;

+ (void)load {
    {
        static IMP oldImp = NULL;
        static SEL selector = NULL;
        NSString *a = [NSString stringWithFormat:@"_scrollView%@End%@For%@", @"Did", @"Decelerating", @"Delegate"];
        selector = NSSelectorFromString(a);
        Method method = class_getInstanceMethod(self, selector);
        oldImp = method_getImplementation(method);
        method_setImplementation(method, imp_implementationWithBlock(^(UIScrollView *self) {
            ((void (*)(UIScrollView *, SEL))oldImp)(self, selector);
            id<KSScrollViewDelegate> delegate = (id<KSScrollViewDelegate>)self.delegate;
            if (delegate != nil && [delegate respondsToSelector:@selector(scrollViewDidEndScroll:)]) {
                BOOL scrollToScrollStop = !self.tracking && !self.dragging && !self.decelerating;
                if (scrollToScrollStop) {
                    [delegate scrollViewDidEndScroll:self];
                }
            }
        }));
    }
    {
        static IMP oldImp = NULL;
        static SEL selector = NULL;
        NSString *a = [NSString stringWithFormat:@"_scrollView%@End%@For%@With%@:", @"Did", @"Dragging", @"Delegate", @"Deceleration"];
        selector = NSSelectorFromString(a);
        Method method = class_getInstanceMethod(self, selector);
        oldImp = method_getImplementation(method);
        method_setImplementation(method, imp_implementationWithBlock(^(UIScrollView *self, BOOL deceleration) {
            ((void (*)(UIScrollView *, SEL, BOOL))oldImp)(self, selector, deceleration);
            if (!deceleration) {
                id<KSScrollViewDelegate> delegate = (id<KSScrollViewDelegate>)self.delegate;
                if (delegate != nil && [delegate respondsToSelector:@selector(scrollViewDidEndScroll:)]) {
                    BOOL dragToDragStop = self.tracking && !self.dragging && !self.decelerating;
                    if (dragToDragStop) {
                        [delegate scrollViewDidEndScroll:self];
                    }
                }
            }
        }));
    }
}

static Class _ks_RefreshHeaderClass = nil;
+ (void)setRefreshHeaderClass:(Class)class {
    _ks_RefreshHeaderClass = class;
}

+ (Class)refreshHeaderClass {
    if (_ks_RefreshHeaderClass == nil) {
        _ks_RefreshHeaderClass = MJRefreshNormalHeader.class;
    }
    return _ks_RefreshHeaderClass;
}

static Class _ks_LoadMoreFooterClass = nil;
+ (void)setLoadMoreFooterClass:(Class)class {
    _ks_LoadMoreFooterClass = class;
}

+ (Class)loadMoreFooterClass {
    if (_ks_LoadMoreFooterClass == nil) {
        _ks_LoadMoreFooterClass = MJRefreshAutoFooter.class;
    }
    return _ks_LoadMoreFooterClass;
}

static const char __ks_LoadStyleKey = '\0';

- (void)setLoadStyle:(KSScrollViewLoadStyle)loadStyle {
    if (loadStyle != self.loadStyle) {
        objc_setAssociatedObject(self, &__ks_LoadStyleKey, [NSNumber numberWithInteger:loadStyle], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        switch (loadStyle) {
            case KSScrollViewLoadStyleNormal:
                [self ks_removeRefreshHeader];
                [self ks_removeLoadMoreFooter];
                break;
            case KSScrollViewLoadStyleRefresh:
                [self ks_addRefreshHeader];
                [self ks_removeLoadMoreFooter];
                break;
            case KSScrollViewLoadStyleLoadMore:
                [self ks_addLoadMoreFooter];
                [self ks_removeRefreshHeader];
                break;
            case KSScrollViewLoadStyleAll:
                [self ks_addRefreshHeader];
                [self ks_addLoadMoreFooter];
                break;
        }
    }
}

- (KSScrollViewLoadStyle)loadStyle {
    return [objc_getAssociatedObject(self, &__ks_LoadStyleKey) integerValue];
}

- (void)ks_addRefreshHeader {
    self.mj_header = [self.class.refreshHeaderClass headerWithRefreshingTarget:self refreshingAction:@selector(ks_performDelegateRefreshSelector)];
}

- (void)ks_removeRefreshHeader {
    self.mj_header = nil;
}

- (void)ks_addLoadMoreFooter {
    self.mj_footer = [self.class.loadMoreFooterClass footerWithRefreshingTarget:self refreshingAction:@selector(ks_performDelegateLoadMoreSelector)];
}

- (void)ks_removeLoadMoreFooter {
    self.mj_footer = nil;
}

- (void)launchRefresh {
    [self.mj_footer resetNoMoreData];
    [self.mj_header beginRefreshing];
}

- (void)finishRefresh {
    [self.mj_header endRefreshing];
}

- (void)finishLoadMore {
    [self.mj_footer endRefreshing];
}

- (void)finishLoadMoreAndNoMore {
    [self.mj_footer endRefreshingWithNoMoreData];
}

- (void)resetNoMoreData {
    [self.mj_footer resetNoMoreData];
}

- (void)ks_performDelegateRefreshSelector {
    id<KSScrollViewDelegate> delegate = (id<KSScrollViewDelegate>)self.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(scrollViewDidBeginRefresh:)]) {
        [self.mj_footer resetNoMoreData];
        [delegate scrollViewDidBeginRefresh:self];
    }
}

- (void)ks_performDelegateLoadMoreSelector {
    id<KSScrollViewDelegate> delegate = (id<KSScrollViewDelegate>)self.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(scrollViewDidLoadMoreData:)]) {
        [delegate scrollViewDidLoadMoreData:self];
    }
}

- (void)scrollViewScrollsToTop {
    [self scrollViewScrollsToTopAnimated:NO];
}

- (void)scrollViewScrollsToTopAnimated:(BOOL)animated {
    CGFloat top = self.contentInset.top;
    [self setContentOffset:(CGPoint){0.f, -top} animated:animated];
}

static const NSInteger ___ks__LOADING_VIEW_TAG = NSIntegerMax;
static const char ___ks__topMarginString = '\0';

- (KSLoadingView *)loadingView {
    KSLoadingView *loadingView = [self viewWithTag:___ks__LOADING_VIEW_TAG];
    if (loadingView == nil) {
        loadingView = [self loadLoadingView];
        loadingView.tag = ___ks__LOADING_VIEW_TAG;
        [self addSubview:loadingView];
    }
    return loadingView;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    KSLoadingView *loadingView = [self viewWithTag:___ks__LOADING_VIEW_TAG];
    if (loadingView != nil) {
        [self layoutLoadingView:loadingView];
    }
}

- (void)layoutLoadingView:(KSLoadingView *)loadingView {
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    
    UIEdgeInsets inset = self.contentInset;
    CGFloat viewW = windowWidth-inset.right;
    CGFloat viewH = windowHeight-inset.bottom;
    CGPoint offset = self.contentOffset;
    CGFloat offsetX = offset.x;
    
    CGFloat topMargin = self.topMargin;
    
    if (offsetX < 0.f) viewW += offsetX;
    CGFloat offsetY = offset.y;
    offsetY -= topMargin;
    CGFloat viewY = topMargin;
    if (offsetY < 0.f) viewH += offsetY;
    loadingView.frame = (CGRect){0.0, viewY, viewW, viewH};
}

- (KSLoadingView *)loadLoadingView {
    KSLoadingView *view = KSLoadingView.alloc.init;
    [view setTitle:@"加载失败" forStatus:KSLoadingViewStatusLoadFailure];
    return view;
}

- (void)setTopMargin:(CGFloat)topMargin {
    self.mj_header.ignoredScrollViewContentInsetTop = -topMargin;
    objc_setAssociatedObject(self, &___ks__topMarginString, [NSNumber numberWithDouble:topMargin], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)topMargin {
    return [objc_getAssociatedObject(self, &___ks__topMarginString) doubleValue];
}

- (void)dealloc {
    objc_removeAssociatedObjects(self);
}

@end
