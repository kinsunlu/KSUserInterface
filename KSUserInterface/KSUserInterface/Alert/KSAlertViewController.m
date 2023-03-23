//
//  KSAlertViewController.m
//  KSUserInterface
//
//  Created by Kinsun on 2022/8/11.
//

#import "KSAlertViewController.h"

NSString * const KSAlertViewControllerAnimationKey = @"KSAlertViewController.animation";

@implementation KSAlertViewController {
    CGFloat _keyBoradHeight;
}
@synthesize alertView = _alertView;
@dynamic view;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        CABasicAnimation *showAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        showAnimation.duration = 0.4;
        showAnimation.fromValue = @0.0;
        showAnimation.toValue = @1.0;
        showAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        _showAnimation = showAnimation;
        
        CABasicAnimation *hiddenAnimation = showAnimation.mutableCopy;
        hiddenAnimation.fromValue = @1.0;
        hiddenAnimation.toValue = @0.0;
        _hiddenAnimation = hiddenAnimation;
        
        if ([self conformsToProtocol:@protocol(CAAnimationDelegate)]) {
            KSAlertViewController<CAAnimationDelegate> *delegate = (KSAlertViewController<CAAnimationDelegate> *)self;
            showAnimation.delegate = delegate;
            hiddenAnimation.delegate = delegate;
        }
        
        _keyBoradHeight = 0.0;
        _clickBackgroundCloseEnable = NO;
        _followKeyboard = NO;
    }
    return self;
}

- (void)loadView {
    UIControl *view = UIControl.alloc.init;
    view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    if (_clickBackgroundCloseEnable) {
        [view addTarget:self action:@selector(didClickBackgroundView) forControlEvents:UIControlEventTouchUpInside];
    }
    [view addSubview:self.alertView];
    self.view = view;
}

- (void)setAlertView:(UIView *)alertView {
    if (_alertView != nil) {
        [_alertView removeFromSuperview];
    }
    _alertView = alertView;
    if (self.isViewLoaded && alertView != nil) {
        UIView *view = self.view;
        [view addSubview:alertView];
        [view setNeedsLayout];
    }
}

- (UIView *)alertView {
    if (_alertView == nil) {
        _alertView = self.loadAlertView;
    }
    return _alertView;
}

- (UIView *)loadAlertView {
    return UIView.alloc.init;
}

- (void)setShowAnimation:(CAAnimation *)showAnimation {
    _showAnimation = showAnimation.mutableCopy;
    if (_showAnimation != nil && [self conformsToProtocol:@protocol(CAAnimationDelegate)]) {
        KSAlertViewController<CAAnimationDelegate> *delegate = (KSAlertViewController<CAAnimationDelegate> *)self;
        _showAnimation.delegate = delegate;
    }
}

- (void)setHiddenAnimation:(CAAnimation *)hiddenAnimation {
    _hiddenAnimation = hiddenAnimation.mutableCopy;
    if (_hiddenAnimation != nil && [self conformsToProtocol:@protocol(CAAnimationDelegate)]) {
        KSAlertViewController<CAAnimationDelegate> *delegate = (KSAlertViewController<CAAnimationDelegate> *)self;
        _hiddenAnimation.delegate = delegate;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_showAnimation != nil && animated) {
        [_alertView.layer addAnimation:_showAnimation forKey:KSAlertViewControllerAnimationKey];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (_followKeyboard && _keyBoradHeight > 0.0) {
        [_alertView endEditing:YES];
    }
    [super viewWillDisappear:animated];
    if (_hiddenAnimation != nil && animated) {
        [_alertView.layer addAnimation:_hiddenAnimation forKey:KSAlertViewControllerAnimationKey];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGSize windowSize = self.view.bounds.size;
    CGFloat windowHeight = windowSize.height-_keyBoradHeight;
    CGSize size = [_alertView sizeThatFits:windowSize];
    _alertView.frame = (CGRect){(windowSize.width-size.width)*0.5, (windowHeight-size.height)*0.5, size};
}

- (void)setFollowKeyboard:(BOOL)followKeyboard {
    if (_followKeyboard == followKeyboard) return;
    _followKeyboard = followKeyboard;
    if (followKeyboard) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_keyboardWillChangeFrameNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    } else {
        [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
}

- (void)_keyboardWillChangeFrameNotification:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo == nil) return;
    CGRect toFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        [weakSelf keyboardWillChangeToFrame:toFrame duration:duration];
    }];
}

- (void)keyboardWillChangeToFrame:(CGRect)frame duration:(NSTimeInterval)duration {
    _keyBoradHeight = frame.origin.y >= UIScreen.mainScreen.bounds.size.height ? 0.0 : frame.size.height;
    CGRect r = _alertView.frame;
    r.origin.y = (self.view.bounds.size.height-r.size.height-_keyBoradHeight)*0.5;
    _alertView.frame = r;
}

- (BOOL)isKeyBoradShowed {
    return _keyBoradHeight > 0.0;
}

- (void)setClickBackgroundCloseEnable:(BOOL)clickBackgroundCloseEnable {
    if (_clickBackgroundCloseEnable == clickBackgroundCloseEnable) return;
    _clickBackgroundCloseEnable = clickBackgroundCloseEnable;
    if (clickBackgroundCloseEnable) {
        [self.view addTarget:self action:@selector(didClickBackgroundView) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.view removeTarget:self action:@selector(didClickBackgroundView) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)didClickBackgroundView {
    if (_keyBoradHeight > 0.0) {
        [_alertView endEditing:YES];
    } else {
        [self closeAlertViewController];
    }
}

- (void)closeAlertViewController {
    [self.navigationController ?: self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    self.followKeyboard = NO;
}

@end
