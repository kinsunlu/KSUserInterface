//
//  KSBaseViewController.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/11/30.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSBaseViewController.h"

@interface KSBaseViewController ()

@end

@implementation KSBaseViewController {
    BOOL _isFirstLayout;
    BOOL _isFirstAppear;
}
@dynamic view;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        _isFirstLayout = YES;
        _isFirstAppear = YES;
        _interactivePopEnabled = YES;
    }
    return self;
}

- (void)loadView {
    self.view = KSBaseView.alloc.init;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    [self.view setDidClickLoadingViewCallback:^(KSBaseView *view, KSLoadingView *loadingView) {
        [weakSelf didClickLoadingView:loadingView];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.interactivePopEnabled = _interactivePopEnabled;
    if (_isFirstAppear) {
        [self firstViewDidAppear:animated];
        _isFirstAppear = NO;
    }
}

- (void)firstViewDidAppear:(BOOL)animated {}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_isFirstLayout && !CGSizeEqualToSize(self.view.bounds.size, CGSizeZero)) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf firstViewDidLayoutSubviews];
        });
        _isFirstLayout = NO;
    }
}

- (void)firstViewDidLayoutSubviews {}

- (void)setInteractivePopEnabled:(BOOL)interactivePopEnabled {
    _interactivePopEnabled = interactivePopEnabled;
    if (self.isViewLoaded && self.view.window != nil) {
        UIGestureRecognizer *interactivePopGestureRecognizer = self.navigationController.interactivePopGestureRecognizer;
        if (interactivePopGestureRecognizer.enabled != interactivePopEnabled) {
            interactivePopGestureRecognizer.enabled = interactivePopEnabled;
        }
    }
}

- (void)clickTabBarItemOnTheSelfController {}
- (void)didClickLoadingView:(KSLoadingView *)loadingView {}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDarkContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

@end

@implementation KSSystemStyleViewController
@dynamic view;

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    if (self.isViewLoaded) {
        self.view.navigationView.title = title;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.navigationView.title = self.title;
}

- (void)loadView {
    self.view = KSSystemStyleView.alloc.init;
}

@end

@implementation KSSecondaryViewController
@dynamic view;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)loadView {
    self.view = KSSecondaryView.alloc.init;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view.navigationView.backButton addTarget:self action:@selector(didClickNavigationBackButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didClickNavigationBackButton:(UIControl *)backButton {
    [self closeCurrentViewController];
}

@end

@implementation KSNavigationController

- (instancetype)initWithRootViewController:(KSBaseViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarHidden = YES;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    UINavigationBar *bar = self.navigationBar;
    if (navigationBarHidden) {
        [self.view sendSubviewToBack:bar];
        bar.hidden = YES;
    } else {
        [self.view bringSubviewToFront:bar];
        bar.hidden = NO;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    Class class = KSBaseViewController.class;
    if ([viewController isKindOfClass:class]) {
        KSBaseViewController *ctl = (KSBaseViewController *)viewController;
        NSString *tag1 = ctl.tag;
        if (tag1 != nil && tag1.length > 0) {
            NSArray <UIViewController *> *controlls = self.viewControllers;
            NSUInteger count = controlls.count;
            if (count >= 2) {
                KSBaseViewController *ctl2 = (KSBaseViewController *)[controlls objectAtIndex:count-2];
                NSString *tag2 = ctl2.tag;
                if (tag2 != nil && tag2.length > 0 && ctl.class == ctl2.class && [tag1 isEqualToString:tag2]) {
                    [self popViewControllerAnimated:animated];
                    return;
                }
            }
        }
    }
    [super pushViewController:viewController animated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.viewControllers.lastObject.preferredStatusBarStyle;
}

@end

@implementation UIViewController (KSNavigationController)

- (UIViewController *)lastPresentedViewController {
    UIViewController *temp = self;
    UIViewController *next = self.presentedViewController;
    while (next != nil) {
        temp = next;
        next = next.presentedViewController;
    }
    return temp;
}

- (KSNavigationController *)controllerNavigationController {
    return (KSNavigationController *)(self.isNavigationController ? self : self.navigationController);
}

- (BOOL)isNavigationController {
    return [self isKindOfClass:KSNavigationController.class];
}

- (void)presentNavigationControllerWithViewController:(ViewController *)controller {
    [self presentNavigationControllerWithViewController:controller animated:YES];
}

- (void)presentNavigationControllerWithViewController:(ViewController *)controller animated:(BOOL)animated {
    [self presentNavigationControllerWithViewController:controller animated:animated completion:nil];
}

- (void)presentNavigationControllerWithViewController:(ViewController *)controller animated:(BOOL)animated completion:(void (^)(void))completion {
    KSNavigationController *childNav = [[KSNavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:childNav animated:animated completion:completion];
}

- (void)dismissViewController {
    [self dismissViewControllerAnimation:YES];
}

- (void)dismissViewControllerAnimation:(BOOL)animated {
    [self dismissViewControllerAnimated:animated completion:nil];
}

- (void)dismissToViewController:(ViewController *)controller {
    [self dismissToViewController:controller completion:nil];
}

- (void)dismissToViewController:(ViewController *)controller completion:(void (^)(void))completion {
    if (controller == self) {
        if (completion != nil) {
            completion();
        }
        return;
    }
    UIViewController *ctl = self.presentingViewController;
    if (ctl == controller) {
        [self dismissViewControllerAnimated:NO completion:completion];
    } else {
        [self dismissViewControllerAnimated:NO completion:^{
            [ctl dismissToViewController:controller completion:completion];
        }];
    }
}

- (void)popToRootViewController {
    [self popToRootViewControllerAnimated:YES];
}

- (void)popToRootViewControllerAnimated:(BOOL)animated {
    UIViewController *controller = self.presentedViewController;
    if (controller != nil) {
        __weak typeof(self) weakSelf = self;
        [controller dismissViewControllerAnimated:animated completion:^{
            __strong typeof(weakSelf) self = weakSelf;
            [self popToRootViewControllerAnimated:NO];
        }];
    } else {
        KSNavigationController *nav = self.controllerNavigationController;
        [nav popToRootViewControllerAnimated:animated];
    }
}

- (void)popViewController {
    [self popViewControllerAnimated:YES];
}

- (void)popViewControllerAnimated:(BOOL)animated {
    [self popToViewController:nil animation:animated];
}

- (void)popToViewController:(ViewController *)controller {
    [self popToViewController:controller animation:YES];
}

- (void)popToViewController:(ViewController *)controller animation:(BOOL)animated {
    KSNavigationController *nav = self.controllerNavigationController;
    if (controller != nil) {
        [nav popToViewController:controller animated:animated];
    } else {
        [nav popViewControllerAnimated:animated];
    }
}

- (void)pushViewController:(ViewController *)controller {
    [self pushViewController:controller animated:YES];
}

- (void)pushViewController:(ViewController *)controller animated:(BOOL)animated {
    KSNavigationController *nav = self.controllerNavigationController;
    if (nav != nil){
        [nav pushViewController:controller animated:animated];
    }
}

- (void)closeCurrentViewController {
    [self closeCurrentViewControllerAnimated:YES];
}

- (void)closeCurrentViewControllerAnimated:(BOOL)animated {
    if (self.navigationController.viewControllers.count > 1) {
        [self popViewControllerAnimated:animated];
    } else if (self.presentingViewController != nil) {
        [self dismissViewControllerAnimation:animated];
    }
}

@end
