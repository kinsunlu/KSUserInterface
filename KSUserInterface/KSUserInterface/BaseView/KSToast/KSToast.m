//
//  KSToast.m
//  
//
//  Created by Kinsun on 2018/12/20.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSToast.h"
#import "UIColor+Hex.h"

@interface _KSToastProgressCircleView : UIView

@property (nonatomic, assign) float progress;
@property (nonatomic, strong) UIColor *circleColor;
@property (nonatomic, strong) UIColor *backCircleColor;
@property (nonatomic, copy, readonly) NSDictionary <NSAttributedStringKey, id> *progressAttributes;
@property (nonatomic, copy, readonly) NSAttributedString *percentage;
@property (nonatomic, copy, readonly) NSAttributedString *progressString;

@end

@implementation _KSToastProgressCircleView {
    __weak CAShapeLayer *_backCirclelayer;
    __weak CATextLayer *_textLayer;
    __weak CAShapeLayer *_frontCirclelayer;
    NSUInteger _int_progress;
}
@synthesize progressAttributes = _progressAttributes, percentage = _percentage;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIColor *clearColor = [UIColor clearColor];
        CGFloat lineWidth = 4.f;
        self.backgroundColor = clearColor;
        
        CALayer *layer = self.layer;
        
        CAShapeLayer *backCirclelayer = [CAShapeLayer layer];
        backCirclelayer.fillColor = clearColor.CGColor;
        backCirclelayer.strokeColor = self.backCircleColor.CGColor;
        backCirclelayer.lineWidth = lineWidth;
        [layer addSublayer:backCirclelayer];
        _backCirclelayer = backCirclelayer;
        
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.wrapped = NO;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.contentsScale = UIScreen.mainScreen.scale;
        textLayer.string = self.progressString;
        [layer addSublayer:textLayer];
        _textLayer = textLayer;
        
        CAShapeLayer *frontCirclelayer = [CAShapeLayer layer];
        frontCirclelayer.fillColor = clearColor.CGColor;
        frontCirclelayer.strokeColor = self.circleColor.CGColor;
        frontCirclelayer.lineWidth = lineWidth;
        frontCirclelayer.lineJoin = kCALineJoinRound;
        frontCirclelayer.lineCap = kCALineCapRound;
        [layer addSublayer:frontCirclelayer];
        _frontCirclelayer = frontCirclelayer;
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    CGRect bounds = layer.bounds;
    CGSize windowSize = bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    
    CGFloat viewH = 32.0;
    CGFloat viewY = (windowHeight-viewH)*0.5;
    _textLayer.frame = (CGRect){0.0, viewY, windowWidth, viewH};
    
    UIBezierPath *backCirclePath = [UIBezierPath bezierPathWithOvalInRect:bounds];
    _backCirclelayer.path = backCirclePath.CGPath;
    _backCirclelayer.frame = bounds;
    _frontCirclelayer.frame = bounds;
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *circlePath = nil;
    if (_progress < 1.f) {
        CGSize size = rect.size;
        CGFloat width = size.width, height = size.height;
        CGPoint center = (CGPoint){width*0.5, height * 0.5};
        CGFloat radius = (MIN(width, height))*0.5;
        CGFloat pi = M_PI*2.0;
        CGFloat startAngle = -M_PI_2, endAngle = (1.f-_progress)*pi+startAngle;
        circlePath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:NO];
    } else circlePath = [UIBezierPath bezierPathWithOvalInRect:rect];
    _frontCirclelayer.path = circlePath.CGPath;
}

- (void)setProgress:(float)progress {
    if (_progress != progress) {
        _progress = progress;
        NSUInteger int_progress = progress*100.f;
        if (_int_progress != int_progress) {
            _int_progress = int_progress;
            _textLayer.string = self.progressString;
        }
        [self setNeedsDisplay];
    }
}

- (UIColor *)circleColor {
    if (_circleColor == nil) {
        _circleColor = UIColor.ks_main;
    }
    return _circleColor;
}

- (UIColor *)backCircleColor {
    if (_backCircleColor == nil) {
        _backCircleColor = UIColor.ks_lightMain;
    }
    return _backCircleColor;
}

- (NSAttributedString *)progressString {
    NSMutableAttributedString *progressString = [[NSMutableAttributedString alloc] initWithString:[NSNumber numberWithUnsignedInteger:_int_progress].stringValue attributes:self.progressAttributes];
    [progressString appendAttributedString:self.percentage];
    return progressString;
}

- (NSDictionary<NSAttributedStringKey,id> *)progressAttributes {
    if (_progressAttributes == nil) {
        _progressAttributes = [NSDictionary dictionaryWithObjectsAndKeys:UIColor.ks_title, NSForegroundColorAttributeName, [UIFont systemFontOfSize:25.f], NSFontAttributeName, nil];
    }
    return _progressAttributes;
}

- (NSAttributedString *)percentage {
    if (_percentage == nil) {
        NSDictionary <NSAttributedStringKey, id> *attributes = [NSDictionary dictionaryWithObjectsAndKeys:UIColor.ks_title, NSForegroundColorAttributeName, [UIFont systemFontOfSize:14.f], NSFontAttributeName, nil];
        _percentage = [[NSAttributedString alloc] initWithString:@"%" attributes:attributes];
    }
    return _percentage;
}

@end

@interface KSToast () <CAAnimationDelegate>

@property (nonatomic, copy) void (^_animationCompletion)(KSToast *toast);

@end

@implementation KSToast {
    __weak UILabel *_messageLabel;
    __weak _KSToastProgressCircleView *_progressView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:KSToastStyleMessage];
}

- (instancetype)initWithStyle:(KSToastStyle)style {
    return [self initWithFrame:CGRectZero style:style];
}

- (instancetype)initWithFrame:(CGRect)frame style:(KSToastStyle)style {
    if (self = [super initWithFrame:frame]) {
        _style = style;
        self.hidden = YES;
        self.backgroundColor = UIColor.ks_background;
        CALayer *layer = self.layer;
        layer.cornerRadius = 18.0;
        layer.masksToBounds = YES;
        switch (style) {
            case KSToastStyleMessage: {
                UILabel *messageLabel = [[UILabel alloc] init];
                messageLabel.font = [UIFont systemFontOfSize:13.f];
                messageLabel.textAlignment = NSTextAlignmentCenter;
                messageLabel.numberOfLines = 0;
                messageLabel.textColor = UIColor.ks_title;
                [self addSubview:messageLabel];
                _messageLabel = messageLabel;
            }
                break;
            case KSToastStyleLoading: {
                UIView<KSToastLoadingViewProtocol> *loadingView = [[self.class.loadingViewClass alloc] init];
                [self addSubview:loadingView];
                _loadingView = loadingView;
            }
                break;
            case KSToastStyleProgress: {
                _KSToastProgressCircleView *progressView = [[_KSToastProgressCircleView alloc] init];
                [self addSubview:progressView];
                _progressView = progressView;
            }
                break;
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    switch (_style) {
        case KSToastStyleMessage: {
            CGFloat margin = 18.0;
            CGFloat viewW = windowWidth-margin*2.0;
            CGFloat viewH = windowHeight-margin*2.0;
            _messageLabel.frame = (CGRect){margin, margin, viewW, viewH};
        }
            break;
        case KSToastStyleLoading: {
            CGSize size = [_loadingView sizeThatFits:windowSize];
            CGFloat viewX = (windowWidth-size.width)*0.5;
            CGFloat viewY = (windowHeight-size.height)*0.5;
            _loadingView.frame = (CGRect){viewX, viewY, size};
        }
            break;
        case KSToastStyleProgress: {
            CGFloat side = 90.0;
            CGFloat viewX = (windowWidth-side)*0.5;
            CGFloat viewY = (windowHeight-side)*0.5;
            _progressView.frame = (CGRect){viewX, viewY, side, side};
        }
            break;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    switch (_style) {
        case KSToastStyleMessage: {
            CGFloat margin = 36.0;
            CGFloat maxWidth = size.width-margin;
            CGFloat maxHeight = size.height-margin;
            CGSize k_size = [_messageLabel sizeThatFits:(CGSize){maxWidth, maxHeight}];
            k_size.width += margin;
            k_size.height += margin;
            return k_size;
        }
        default:
            return (CGSize){150.0, 150.0};
    }
}

- (void)setFrame:(CGRect)frame {
    if (_style != KSToastStyleMessage) {
        frame.size = (CGSize){150.0, 150.0};
    }
    [super setFrame:frame];
}

- (void)_startLoadingAnimation {
    [_loadingView startAnimating];
}

- (void)_stopLoadingAnimation {
    [_loadingView stopAnimating];
}

- (void)setProgress:(float)progress {
    _progressView.progress = progress;
}

- (float)progress {
    return _progressView.progress;
}

- (void)setMessage:(id)message {
    if ([message isKindOfClass:NSAttributedString.class]) {
        _messageLabel.attributedText = message;
    } else if ([message isKindOfClass:NSString.class]) {
        _messageLabel.text = message;
    } else {
        _messageLabel.text = [message description];
    }
    [self setNeedsLayout];
}

- (id)message {
    NSAttributedString *string = _messageLabel.attributedText;
    if (string != nil && string.length > 0) {
        return string;
    }
    return _messageLabel.text;
}

- (void)showToast {
    [self showToastWithCompletion:nil];
}

- (void)showToastWithCompletion:(void (^)(KSToast *toast))completion {
    switch (_style) {
        case KSToastStyleLoading: {
            __weak typeof(self) weakSelf = self;
            [self set_animationCompletion:^(KSToast *toast) {
                [weakSelf _startLoadingAnimation];
            }];
            [self _settingToastHidden:NO delegate:self];
        }
            break;
        case KSToastStyleMessage: {
            __weak typeof(self) weakSelf = self;
            NSInteger time = MIN(MAX(8, [self.message length]*.1), 2);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf dismissToastWithCompletion:completion];
            });
        }
        case KSToastStyleProgress:
            [self _settingToastHidden:NO delegate:nil];
            break;
    }
}

- (void)dismissToast {
    [self dismissToastWithCompletion:nil];
}

- (void)dismissToastWithCompletion:(void (^)(KSToast *toast))completion {
    if (_style == KSToastStyleLoading) {
        __weak typeof(self) weakSelf = self;
        [self set_animationCompletion:^(KSToast *toast) {
            [weakSelf _stopLoadingAnimation];
            if (completion != nil) completion(toast);
        }];
    } else __animationCompletion = completion;
    [self _settingToastHidden:YES delegate:self];
}

- (void)_settingToastHidden:(BOOL)hidden delegate:(KSToast *)delegate {
    CATransition *fade = [CATransition animation];
    fade.duration = 0.4;
    fade.type = kCATransitionFade;
    fade.delegate = delegate;
    self.hidden = hidden;
    [self.layer addAnimation:fade forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (__animationCompletion != nil) {
        __animationCompletion(self);
        __animationCompletion = nil;
    }
}

static Class _dn_loadingViewClass = nil;

+ (void)setLoadingViewClass:(Class)loadingViewClass {
    _dn_loadingViewClass = loadingViewClass;
}

+ (Class)loadingViewClass {
    if (_dn_loadingViewClass == nil) {
        _dn_loadingViewClass = KSToastLoadingNormalView.class;
    }
    return _dn_loadingViewClass;
}

@end

@implementation KSToastContentView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:KSToastStyleMessage];
}

- (instancetype)initWithStyle:(KSToastStyle)style {
    return [self initWithFrame:CGRectZero style:style];
}

- (instancetype)initWithFrame:(CGRect)frame style:(KSToastStyle)style {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
        KSToast *toast = [[KSToast alloc] initWithStyle:style];
        [self addSubview:toast];
        _toast = toast;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    CGSize k_size = [_toast sizeThatFits:(CGSize){200.0, windowHeight}];
    CGFloat viewX = (windowWidth-k_size.width)*0.5f;
    CGFloat viewY = (windowHeight-k_size.height)*0.5f;
    _toast.frame = (CGRect){viewX, viewY, k_size};
}

@end

@implementation KSToastLoadingNormalView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        if (@available(iOS 13.0, *)) {
            self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleLarge;
        } else {
            self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        }
        self.color = UIColor.ks_gray;
        self.hidesWhenStopped = NO;
    }
    return self;
}

@end
