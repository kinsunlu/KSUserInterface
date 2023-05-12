//
//  KSActionSheetViewController.m
//  KSUserInterface
//
//  Created by Kinsun on 2022/8/11.
//

#import "KSActionSheetViewController.h"

@interface _KSActionSheetContentView : UIView

@property (nonatomic, weak) UIView *actionSheetView;
@property (nonatomic, assign) CGFloat bottomMargin;

@end

@implementation _KSActionSheetContentView {
    __weak UIView *_bottomMarginView;
    CGFloat _keyBoradHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        _bottomMargin = 0.0;
        _keyBoradHeight = 0.0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_actionSheetView == nil) {
        _bottomMarginView.frame = CGRectZero;
        return;
    }
    CGSize windowSize = self.bounds.size;
    CGFloat windowHeight = windowSize.height;
    CGSize size = [_actionSheetView sizeThatFits:windowSize];
    CGFloat w = size.width;
    CGFloat x = (windowSize.width-w)*0.5;
    _actionSheetView.frame = (CGRect){x, windowHeight-MAX(_keyBoradHeight, _bottomMargin)-size.height, size};
    if (_bottomMarginView != nil) {
        _bottomMarginView.frame = (CGRect){x, windowHeight-_bottomMargin-1.0, w, _bottomMargin+1.0};
    }
}

- (void)setActionSheetView:(UIView *)actionSheetView {
    if (_actionSheetView != nil) {
        [_actionSheetView removeFromSuperview];
    }
    _actionSheetView = actionSheetView;
    if (actionSheetView != nil) {
        _bottomMarginView.backgroundColor = actionSheetView.backgroundColor;
        [self addSubview:actionSheetView];
        [self setNeedsLayout];
    }
}

- (void)setBottomMargin:(CGFloat)bottomMargin {
    if (_bottomMargin == bottomMargin) return;
    _bottomMargin = bottomMargin;
    if (bottomMargin <= 0.0) {
        [_bottomMarginView removeFromSuperview];
    } else if (_bottomMarginView == nil) {
        UIView *bottomView = UIView.alloc.init;
        bottomView.backgroundColor = _actionSheetView.backgroundColor;
        [self insertSubview:bottomView atIndex:0];
        _bottomMarginView = bottomView;
    }
    [self setNeedsLayout];
}

- (void)followKeyboardWithHeight:(CGFloat)height duration:(NSTimeInterval)duration {
    _keyBoradHeight = height;
    __weak typeof(_actionSheetView) weakView = _actionSheetView;
    CGRect frame = weakView.frame;
    frame.origin.y = self.bounds.size.height-MAX(_keyBoradHeight, _bottomMargin)-frame.size.height;
    [UIView animateWithDuration:duration animations:^{
        weakView.frame = frame;
    }];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (_actionSheetView != nil) {
        CGRect frame = _actionSheetView.frame;
        frame.size.height += _bottomMargin;
        if (!CGRectContainsPoint(frame, point)) {
            return nil;
        }
    }
    return [super hitTest:point withEvent:event];
}

@end

@implementation KSActionSheetViewController {
    __weak _KSActionSheetContentView *_contentView;
}
@synthesize actionSheetView = _actionSheetView;
@dynamic view;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        _clickBackgroundCloseEnable = YES;
    }
    return self;
}

- (void)loadView {
    UIControl *view = UIControl.alloc.init;
    view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    if (_clickBackgroundCloseEnable) {
        [view addTarget:self action:@selector(didClickBackgroundView) forControlEvents:UIControlEventTouchUpInside];
    }
    
    _KSActionSheetContentView *contentView = _KSActionSheetContentView.alloc.init;
    contentView.hidden = YES;
    contentView.actionSheetView = self.actionSheetView;
    [view addSubview:contentView];
    _contentView = contentView;
    self.view = view;
}

- (void)setActionSheetView:(UIView *)actionSheetView {
    _actionSheetView = actionSheetView;
    if (self.isViewLoaded) {
        _contentView.actionSheetView = actionSheetView;
    }
}

- (UIView *)actionSheetView {
    if (_actionSheetView == nil) {
        _actionSheetView = self.loadActionSheetView;
    }
    return _actionSheetView;
}

- (UIView *)loadActionSheetView {
    return UIView.alloc.init;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (animated) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf _showAnimation];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (_followKeyboard && _keyBoradShowed) {
        [_actionSheetView endEditing:YES];
    }
    [super viewWillDisappear:animated];
    if (!animated) return;
    CGSize windowSize = self.view.bounds.size;
    CGRect frame = _contentView.frame;
    frame.origin.y = 0.0;
    _contentView.frame = frame;
    frame.origin.y = windowSize.height-([_actionSheetView sizeThatFits:windowSize].height+_contentView.bottomMargin);
    __weak typeof(_contentView) weakView = _contentView;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.4 animations:^{
        weakView.frame = frame;
    } completion:^(BOOL finished) {
        weakView.hidden = YES;
        [weakSelf.view setNeedsLayout];
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIView *view = self.view;
    if (@available(iOS 11.0, *)) {
        _contentView.bottomMargin = view.safeAreaInsets.bottom;
    }
    _contentView.frame = view.bounds;
    [_contentView setNeedsLayout];
}

- (void)_showAnimation {
    CGSize windowSize = self.view.bounds.size;
    CGRect frame = _contentView.frame;
    frame.origin.y = windowSize.height-([_actionSheetView sizeThatFits:windowSize].height+_contentView.bottomMargin);
    _contentView.frame = frame;
    _contentView.hidden = NO;
    frame.origin.y = 0.0;
    __weak typeof(_contentView) weakView = _contentView;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:0.7 initialSpringVelocity:0.3 options:0 animations:^{
        weakView.frame = frame;
    } completion:^(BOOL finished) {
        [weakSelf.view setNeedsLayout];
    }];
}

- (void)setFollowKeyboard:(BOOL)followKeyboard {
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
    CGFloat keyBoradHeight = toFrame.origin.y >= UIScreen.mainScreen.bounds.size.height ? 0.0 : toFrame.size.height;
    _keyBoradShowed = keyBoradHeight > 0.0;
    [self followKeyboardWithHeight:keyBoradHeight duration:duration];
}

- (void)followKeyboardWithHeight:(CGFloat)height duration:(NSTimeInterval)duration {
    [_contentView followKeyboardWithHeight:height duration:duration];
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
    if (_keyBoradShowed) {
        [_actionSheetView endEditing:YES];
    } else {
        [self closeActionSheetViewController];
    }
}

- (void)closeActionSheetViewController {
    [self.navigationController ?: self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    self.followKeyboard = NO;
}

@end
