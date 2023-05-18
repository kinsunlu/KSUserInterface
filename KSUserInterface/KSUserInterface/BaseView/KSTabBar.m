//
//  KSTabBar.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/1.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSTabBar.h"
#import "UIColor+Hex.h"

@implementation KSTabBar {
    NSMutableArray <KSTabBarItem*>* _itemArray;
    __weak CALayer *_lineLayer;
    __weak KSTabBarItem *_selecteditem;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _itemArray = NSMutableArray.array;
        self.backgroundColor = UIColor.clearColor;
        self.clipsToBounds = NO;
        
        CALayer *lineLayer = CALayer.layer;
        lineLayer.backgroundColor = UIColor.ks_lightGray.CGColor;
        [self.layer addSublayer:lineLayer];
        _lineLayer = lineLayer;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    
    CGFloat viewX = 0.0;
    CGFloat viewY = 0.0;
    CGFloat viewW = windowWidth;
    CGFloat viewH = 0.5;
    _lineLayer.frame = (CGRect){viewX, viewY, viewW, viewH};
    
    viewW = ceil(windowWidth/_itemArray.count);
    viewH = windowHeight;
    for (NSInteger i = 0; i < _itemArray.count; i++) {
        viewX = viewW*i;
        [_itemArray objectAtIndex:i].frame = (CGRect){viewX, viewY, viewW, viewH};
    }
}

- (NSArray<KSTabBarItem *> *)items {
    return _itemArray.copy;
}

- (void)_insertTabBarItem:(KSTabBarItem*)item atIndex:(NSInteger)index {
    [_itemArray insertObject:item atIndex:index];
    [self addSubview:item];
    [self setNeedsLayout];
}

- (void)_addTabBarItem:(KSTabBarItem*)item {
    [_itemArray addObject:item];
    [self addSubview:item];
    [self setNeedsLayout];
}

- (void)setSelectedItem:(KSTabBarItem *)selectedItem {
    if (_selecteditem != nil) {
        _selecteditem.selected = NO;
    }
    if (selectedItem != nil) {
        selectedItem.selected = YES;
    }
    _selecteditem = selectedItem;
}

- (void)setHiddenLine:(BOOL)hiddenLine {
    _lineLayer.hidden = hiddenLine;
}

- (BOOL)isHiddenLine {
    return _lineLayer.isHidden;
}

@end

static NSString * const _KSTabBarMaskAnimationKey = @"KSTabBarController.tabBar.mask.animation";

@interface KSSystemTabBar () <CAAnimationDelegate>

@end

@implementation KSSystemTabBar {
    __weak CALayer *_maskLayer;
}
@synthesize tabBar = _tabBar;

- (KSTabBar *)tabBar {
    if (_tabBar == nil) {
        KSTabBar *tabbar = KSTabBar.alloc.init;
        [super addSubview:tabbar];
        _tabBar = tabbar;
    }
    return _tabBar;
}

- (void)layoutSubviews {
    CGRect bounds = self.bounds;
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets safeArea = self.safeAreaInsets;
        CGRect frame = bounds;
        frame.size.height -= safeArea.bottom;
        _tabBar.frame = frame;
    } else {
        _tabBar.frame = bounds;
    }
    _maskLayer.frame = bounds;
}

- (void)addSubview:(UIView *)view { }
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {}

- (void)_showMaskWithColor:(UIColor *)color animation:(CAAnimation *)animation {
    if (_maskLayer == nil) {
        CALayer *layer = self.tabBar.layer;
        CALayer *maskLayer = CALayer.layer;
        maskLayer.frame = layer.bounds;
        [layer addSublayer:maskLayer];
        _maskLayer = maskLayer;
        _tabBar.userInteractionEnabled = NO;
    }
    _maskLayer.backgroundColor = color.CGColor;
    if (animation != nil) {
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [_maskLayer addAnimation:animation forKey:_KSTabBarMaskAnimationKey];
    }
}

- (void)_hiddenMaskWithAnimation:(CAAnimation *)animation {
    if (animation == nil) {
        [_maskLayer removeFromSuperlayer];
        _tabBar.userInteractionEnabled = YES;
    } else {
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.delegate = self;
        [_maskLayer addAnimation:animation forKey:_KSTabBarMaskAnimationKey];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (_maskLayer != nil) {
        CAAnimation *a = [_maskLayer animationForKey:_KSTabBarMaskAnimationKey];
        if (a == anim) {
            [_maskLayer removeFromSuperlayer];
            _tabBar.userInteractionEnabled = YES;
        }
    }
}

@end
