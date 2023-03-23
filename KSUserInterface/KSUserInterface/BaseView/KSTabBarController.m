//
//  KSTabBarController.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/1.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSTabBarController.h"

@interface KSTabBar ()

- (void)_insertTabBarItem:(KSTabBarItem *)item atIndex:(NSInteger)index;
- (void)_addTabBarItem:(KSTabBarItem *)item;

@end

@implementation UITabBar (KSTabBarController)

+ (instancetype)alloc {
    if (self == KSSystemTabBar.class) {
        return [super alloc];
    }
    return [KSSystemTabBar alloc];
}

@end

@interface KSSystemTabBar ()

- (void)_hiddenMaskWithAnimation:(CAAnimation *)animation;
- (void)_showMaskWithColor:(UIColor *)color animation:(CAAnimation *)animation;

@end

#import "UIColor+Hex.h"
#import "KSTabBarItem.h"
#import "KSBaseViewController.h"

@implementation KSTabBarController
@dynamic tabBar;

static KSTabBarController *_instance = nil;

+ (instancetype)sharedInstance {
    if (_instance == nil) {
        @synchronized (self) {
            if (_instance == nil) {
                _instance = [[self alloc] init];
            }
        }
    }
    return _instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewControllers];
}

- (void)setupViewControllers {}

- (NSArray<KSTabBarItem *> *)items {
    return self.tabBar.tabBar.items;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIViewController *topViewController = [KSTabBarController topViewControllerWithController:self];
    if (topViewController.viewIfLoaded) {
        [topViewController.view setNeedsLayout];
    }
}

- (void)insertTabBarItem:(KSTabBarItem *)item atIndex:(NSInteger)index {
    KSTabBar *tabBar = self.tabBar.tabBar;
    if (![tabBar.items containsObject:item]) {
        [self _setTabBarItem:item];
        [tabBar _insertTabBarItem:item atIndex:index];
    }
}

- (void)addTabBarItem:(KSTabBarItem *)item {
    KSTabBar *tabBar = self.tabBar.tabBar;
    if (![tabBar.items containsObject:item]) {
        [self _setTabBarItem:item];
        [tabBar _addTabBarItem:item];
    }
}

- (void)_setTabBarItem:(KSTabBarItem *)item {
    UIViewController *controller = item.controller;
    if (controller != nil) {
        [item addTarget:self action:@selector(_didClickTabBarItem:) forControlEvents:UIControlEventTouchUpInside];
        [self addChildViewController:controller];
    }
}

- (void)_didClickTabBarItem:(KSTabBarItem *)tabBarItem {
    UIViewController *ctl = tabBarItem.controller;
    if (ctl == self.selectedViewController) {
        KSBaseViewController *bctl = nil;
        if ([ctl isKindOfClass:UINavigationController.class]) {
            KSBaseViewController *c =  ctl.childViewControllers.firstObject;
            if (c != nil && [c isKindOfClass:KSBaseViewController.class]) {
                bctl = c;
            }
        } else if ([ctl isKindOfClass:KSBaseViewController.class]) {
            bctl = (KSBaseViewController *)ctl;
        }
        if (bctl != nil) {
            [bctl clickTabBarItemOnTheSelfController];
        }
    } else {
        self.selectedViewController = ctl;
        [self.tabBar.tabBar setSelectedItem:tabBarItem];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    KSTabBar *tabbar = self.tabBar.tabBar;
    KSTabBarItem *item = [tabbar.items objectAtIndex:selectedIndex];
    UIViewController *conbtroller = item.controller;
    if (conbtroller) {
        self.selectedViewController = conbtroller;
        [tabbar setSelectedItem:item];
    }
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated {
    UITabBar *tabBar = self.tabBar;
    if (hidden != tabBar.hidden) {
        if (animated) {
            CATransition *trans = CATransition.animation;
            trans.duration = 0.2f;
            trans.type = kCATransitionPush;
            trans.subtype = hidden ? kCATransitionFromBottom : kCATransitionFromTop;
            [tabBar.layer addAnimation:trans forKey:nil];
        }
        tabBar.hidden = hidden;
    }
}

- (void)showMaskWithDuration:(NSTimeInterval)duration {
    if (duration > 0.0) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.duration = duration;
        animation.fromValue = @0.0;
        animation.toValue = @1.0;
        [self showMaskWithAnimation:animation];
    } else {
        [self showMaskWithAnimation:nil];
    }
}

- (void)showMaskWithAnimation:(CAAnimation *)animation {
    [self showMaskWithColor:[UIColor colorWithWhite:0.0 alpha:0.5] animation:animation];
}

- (void)showMaskWithColor:(UIColor *)color animation:(CAAnimation *)animation {
    [self.tabBar _showMaskWithColor:color animation:animation];
}

- (void)hiddenMaskWithDuration:(NSTimeInterval)duration {
    if (duration > 0.0) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.duration = duration;
        animation.fromValue = @1.0;
        animation.toValue = @0.0;
        [self hiddenMaskWithAnimation:animation];
    } else {
        [self hiddenMaskWithAnimation:nil];
    }
}

- (void)hiddenMaskWithAnimation:(CAAnimation *)animation {
    [self.tabBar _hiddenMaskWithAnimation:animation];
}

- (UIViewController *)topViewController {
    return [KSTabBarController topViewControllerWithController:self];
}

- (UINavigationController *)topNavgiationViewController {
    UIViewController *topViewController = self.topViewController;
    if (topViewController == self) {
        return (UINavigationController *)self.selectedViewController;
    } else if ([topViewController isKindOfClass:UINavigationController.class]) {
        return (UINavigationController *)topViewController;
    } else return nil;
}

+ (UIViewController *)topViewControllerWithController:(UIViewController *)controller {
    if ([controller isKindOfClass:UITabBarController.class]) {
        return [self topViewControllerWithController:((UITabBarController *)controller).selectedViewController];
    } else if ([controller isKindOfClass:UINavigationController.class]) {
        return [self topViewControllerWithController:((UINavigationController *)controller).topViewController];
    } else {
        UIViewController *presentedViewController = controller.presentedViewController;
        if (presentedViewController == nil) {
            return controller;
        } else {
            return [self topViewControllerWithController:presentedViewController];
        }
    }
}

@end

