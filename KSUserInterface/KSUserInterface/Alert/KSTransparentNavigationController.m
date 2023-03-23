//
//  KSTransparentNavigationController.m
//  KSUserInterface
//
//  Created by Kinsun on 2022/8/12.
//

#import "KSTransparentNavigationController.h"
#import "KSBaseViewController.h"

@implementation KSTransparentNavigationController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = UIColor.clearColor;
    self.navigationBarHidden = YES;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    self.navigationBar.hidden = navigationBarHidden;
}

- (BOOL)isNavigationBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.viewControllers.lastObject.preferredStatusBarStyle;
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

@end
