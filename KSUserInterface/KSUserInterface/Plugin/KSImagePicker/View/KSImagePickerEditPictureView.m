//
//  KSImagePickerEditPictureView.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/10.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSImagePickerEditPictureView.h"

@interface _KSIPEditPictureMaskView : UIView

@property (nonatomic, assign, getter=isCircularMask) BOOL circularMask;
@property (nonatomic, assign, readonly) CGRect contentRect;

@end

@implementation _KSIPEditPictureMaskView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:.5f];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGSize windowSize = rect.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    CGFloat minWidth = MIN(windowWidth, windowHeight);
    CGFloat x = (windowWidth-minWidth)*0.5, y = (windowHeight-minWidth)*0.5;
    _contentRect = (CGRect){x, y, minWidth, minWidth};
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat height_2 = windowHeight*0.5f;
    [path moveToPoint:(CGPoint){windowWidth, height_2}];
    [path addLineToPoint:(CGPoint){windowWidth, 0.f}];
    [path addLineToPoint:CGPointZero];
    [path addLineToPoint:(CGPoint){0.f, windowHeight}];
    [path addLineToPoint:(CGPoint){windowWidth, windowHeight}];
    [path addLineToPoint:(CGPoint){windowWidth, height_2}];
    if (_circularMask) {
        CGPoint center = (CGPoint){minWidth*0.5f+x,minWidth*0.5f+y};
        CGFloat radius = minWidth*0.5f-10.f;
        [path addArcWithCenter:center radius:radius startAngle:0 endAngle:M_PI*2.f clockwise:YES];
    } else {
        CGFloat maxX = x+minWidth, maxY = y+minWidth;
        [path addLineToPoint:(CGPoint){maxX, height_2}];
        [path addLineToPoint:(CGPoint){maxX, maxY}];
        [path addLineToPoint:(CGPoint){x, maxY}];
        [path addLineToPoint:(CGPoint){x, y}];
        [path addLineToPoint:(CGPoint){maxX, y}];
        [path addLineToPoint:(CGPoint){maxX, height_2}];
    }
    [path closePath];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = path.CGPath;
    self.layer.mask = mask;
}

@end

#import "UIColor+Hex.h"

@interface _KSIPEditPictureTrimView : UIVisualEffectView

@end

@implementation _KSIPEditPictureTrimView {
    NSArray <NSNumber *> *_itemsWidthArray;
    NSPointerArray *_allBtns;
    __weak id _target;
    SEL _action;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    if (self = [super initWithEffect:effect]) {
        _target = target;
        _action = action;
        CALayer *layer = self.layer;
        layer.cornerRadius = 4.f;
        layer.masksToBounds = YES;
        
        UIView *contentView = self.contentView;
        UIColor *whiteColor = UIColor.ks_white;
        UIFont *font = [UIFont systemFontOfSize:18.f];
        NSDictionary <NSAttributedStringKey, UIFont *> *attributes = @{NSFontAttributeName: font};
        CGSize maxSize = (CGSize){MAXFLOAT, MAXFLOAT};
        NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        NSArray <NSString *> *names = @[@"左", @"上", @"下", @"右"];
        
        NSMutableArray <NSNumber *> *itemsWidthArray = [NSMutableArray array];
        NSPointerArray *allBtns = [NSPointerArray weakObjectsPointerArray];
        for (NSUInteger i = 0; i < names.count; i++) {
            NSString *string = [names objectAtIndex:i];
            CGSize size = [string boundingRectWithSize:maxSize options:options attributes:attributes context:nil].size;
            NSNumber *width = [NSNumber numberWithDouble:size.width];
            [itemsWidthArray addObject:width];
            
            KSTextButton *btn = KSTextButton.alloc.init;
            btn.tag = i;
            btn.normalTitle = string;
            UILabel *label = btn.contentView;
            label.font = font;
            label.textColor = whiteColor;
            [btn addTarget:_target action:_action forControlEvents:UIControlEventTouchUpInside];
            [contentView addSubview:btn];
            [allBtns addPointer:(__bridge void *)btn];
        }
        _allBtns = allBtns;
        _itemsWidthArray = itemsWidthArray;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    
    CGFloat egdeMargin = 11.0;
    CGFloat remainderWidth = windowWidth;
    NSUInteger count = _itemsWidthArray.count;
    for (NSUInteger i = 0; i < count; i++) {
        NSNumber *value = [_itemsWidthArray objectAtIndex:i];
        CGFloat width = value.doubleValue;
        remainderWidth -= width;
    }
    CGFloat margin = floor((remainderWidth-egdeMargin*2.0)/count);
    CGFloat viewX = egdeMargin;
    CGFloat viewH = windowHeight;
    CGFloat viewY = 0.0;
    for (NSUInteger i = 0; i < count; i++) {
        NSNumber *value = [_itemsWidthArray objectAtIndex:i];
        CGFloat viewW = value.doubleValue+margin;
        KSTextButton *btn = [_allBtns pointerAtIndex:i];
        CGRect frame = (CGRect){viewX, viewY, viewW, viewH};
        btn.frame = frame;
        viewX = CGRectGetMaxX(frame);
    }
}

@end

@interface _KSIPEditPictureToolBar : UIView

@end

@implementation _KSIPEditPictureToolBar {
    NSArray <NSNumber *> *_itemsWidthArray;
    NSPointerArray *_buttonArray;
    __weak id _target;
    SEL _action;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    if (self = [super initWithFrame:CGRectZero]) {
        _target = target;
        _action = action;
        self.backgroundColor = UIColor.clearColor;
        UIColor *whiteColor = UIColor.ks_white;
        UIFont *font = [UIFont systemFontOfSize:18.f];
        NSDictionary <NSAttributedStringKey, UIFont *> *attributes = @{NSFontAttributeName: font};
        CGSize maxSize = (CGSize){MAXFLOAT, MAXFLOAT};
        NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        NSArray <NSString *> *titles = @[@"还原", @"微调", @"旋转"];
        NSMutableArray <NSNumber *> *itemsWidthArray = [NSMutableArray arrayWithCapacity:titles.count];
        NSPointerArray *buttonArray = [NSPointerArray weakObjectsPointerArray];
        for (NSUInteger i = 0; i < titles.count; i++) {
            NSString *title = [titles objectAtIndex:i];
            CGSize size = [title boundingRectWithSize:maxSize options:options attributes:attributes context:nil].size;
            NSNumber *width = [NSNumber numberWithDouble:size.width];
            [itemsWidthArray addObject:width];
            
            KSTextButton *btn = KSTextButton.alloc.init;
            btn.tag = i;
            btn.normalTitle = title;
            UILabel *label = btn.contentView;
            label.font = font;
            label.textColor = whiteColor;
            [btn addTarget:_target action:_action forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [buttonArray addPointer:(__bridge void *)btn];
        }
        _buttonArray = buttonArray;
        _itemsWidthArray = itemsWidthArray;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    
    CGFloat egdeMargin = 11.0;
    CGFloat remainderWidth = windowWidth;
    NSUInteger count = _itemsWidthArray.count;
    for (NSUInteger i = 0; i < count; i++) {
        NSNumber *value = [_itemsWidthArray objectAtIndex:i];
        CGFloat width = value.doubleValue;
        remainderWidth -= width;
    }
    CGFloat margin = floor((remainderWidth-egdeMargin*2.0)/count);
    CGFloat viewX = egdeMargin;
    CGFloat viewH = windowHeight;
    CGFloat viewY = 0.0;
    for (NSUInteger i = 0; i < count; i++) {
        NSNumber *value = [_itemsWidthArray objectAtIndex:i];
        CGFloat viewW = value.doubleValue+margin;
        KSTextButton *btn = [_buttonArray pointerAtIndex:i];
        CGRect frame = (CGRect){viewX, viewY, viewW, viewH};
        btn.frame = frame;
        viewX = CGRectGetMaxX(frame);
    }
}

@end

@interface KSImagePickerEditPictureView () <UIGestureRecognizerDelegate>

@end

@implementation KSImagePickerEditPictureView {
    __weak UIView *_contentView;
    
    __weak _KSIPEditPictureMaskView *_maskView;
    __weak _KSIPEditPictureToolBar *_toolBar;
    
    __weak _KSIPEditPictureTrimView *_trimView;
}
@dynamic navigationView;

- (instancetype)initWithFrame:(CGRect)frame {
    KSImagePickerEditPictureNavigationView *navigationView = KSImagePickerEditPictureNavigationView.alloc.init;
    navigationView.style = KSNavigationViewStyleDark;
    return [self initWithFrame:frame navigationView:navigationView];
}

- (instancetype)initWithFrame:(CGRect)frame navigationView:(KSSecondaryNavigationView *)navigationView {
    if (self = [super initWithFrame:frame navigationView:navigationView]) {
        self.backgroundColor = UIColor.blackColor;
        
        UIView *contentView = [[UIView alloc] init];
        [self addSubview:contentView];
        _contentView = contentView;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [contentView addSubview:imageView];
        _imageView = imageView;
        
        _KSIPEditPictureMaskView *maskView = [[_KSIPEditPictureMaskView alloc] init];
        [self addSubview:maskView];
        _maskView = maskView;
        
        _KSIPEditPictureToolBar *toolBar = [[_KSIPEditPictureToolBar alloc] initWithTarget:self action:@selector(_didClickToolBarButtons:)];
        [self addSubview:toolBar];
        _toolBar = toolBar;
        
        [self _addGesture];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGRect bounds = self.bounds;
    _contentView.frame = bounds;
    _imageView.frame = bounds;
    _maskView.frame = bounds;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    CGSize windowSize = bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    UIEdgeInsets safeArea = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeArea = self.safeAreaInsets;
    }
    
    CGFloat viewW = windowWidth;
    CGFloat viewH = 44.0;
    CGFloat viewY = windowHeight-viewH-safeArea.bottom;
    _toolBar.frame = (CGRect){0.0, viewY, viewW, viewH};
}

- (void)_didClickToolBarButtons:(KSTextButton *)btn {
    switch (btn.tag) {
        case 0: {
            __weak UIView *contentView = _contentView;
            __weak UIImageView *imageView = _imageView;
            [UIView animateWithDuration:0.4f animations:^{
                imageView.transform = CGAffineTransformIdentity;
                contentView.transform = CGAffineTransformIdentity;
            }];
        }
            break;
        case 1:
            if (_trimView == nil) [self _showTrimView];
            else [self _dismissTrimView];
            break;
        case 2: {
            btn.enabled = NO;
            __weak UIView *contentView = _contentView;
            CGAffineTransform transform = CGAffineTransformRotate(contentView.transform, M_PI_2);
            [UIView animateWithDuration:0.4f animations:^{
                contentView.transform = transform;
            } completion:^(BOOL finished) {
                btn.enabled = YES;
            }];
        }
            break;
    }
}

- (void)_showTrimView {
    CGSize windowSize = self.bounds.size;
    CGFloat viewW = 230.0;
    CGFloat viewH = 44.0;
    CGFloat viewX = (windowSize.width-viewW)*0.5;
    CGFloat viewY = windowSize.height;
    _KSIPEditPictureTrimView *trimView = [[_KSIPEditPictureTrimView alloc]initWithTarget:self action:@selector(_didClickTrimViewButtons:)];
    trimView.frame = (CGRect){viewX, viewY, viewW, viewH};
    _trimView = trimView;
    [self insertSubview:trimView belowSubview:_toolBar];
    CGRect frame = trimView.frame;
    frame.origin.y = _toolBar.frame.origin.y-viewH-7.0;
    [UIView animateWithDuration:0.2 animations:^{
        trimView.frame = frame;
    }];
}

- (void)_dismissTrimView {
    __weak typeof(_trimView) weakView = _trimView;
    CGRect frame = weakView.frame;
    frame.origin.y = self.bounds.size.height;
    [UIView animateWithDuration:0.2f animations:^{
        weakView.frame = frame;
    } completion:^(BOOL finished) {
        [weakView removeFromSuperview];
    }];
}

- (void)_didClickTrimViewButtons:(KSTextButton *)btn {
    CGFloat tx = 0.f, ty = 0.f;
    switch (btn.tag) {
        case 0: tx=-1.f; break;
        case 1: ty=-1.f; break;
        case 2: ty=1.f; break;
        case 3: tx=1.f; break;
    }
    _contentView.transform = CGAffineTransformTranslate(_contentView.transform, tx, ty);
}

#pragma mark - Gesture
- (void)_addGesture {
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(_rotation:)];
    rotation.delegate = self;
    [_contentView addGestureRecognizer:rotation];
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(_pinch:)];
    pinch.delegate = self;
    [_imageView addGestureRecognizer:pinch];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_pan:)];
    [_imageView addGestureRecognizer:pan];
}

- (void)_rotation:(UIRotationGestureRecognizer *)rotation {
    [self _dismissTrimView];
    _contentView.transform = CGAffineTransformRotate(_contentView.transform, rotation.rotation);
    rotation.rotation = 0.f;
}

- (void)_pinch:(UIPinchGestureRecognizer *)pinch {
    [self _dismissTrimView];
    _imageView.transform = CGAffineTransformScale(_imageView.transform, pinch.scale, pinch.scale);
    pinch.scale = 1;
}

- (void)_pan:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
        [self _dismissTrimView];
        CGPoint translation = [pan translationInView:_imageView];
        _imageView.transform = CGAffineTransformTranslate(_imageView.transform, translation.x, translation.y);
        [pan setTranslation:CGPointZero inView:_imageView];
    }
}

- (UIImage *)snapshot {
    _maskView.hidden = YES;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _maskView.hidden = NO;
    return img;
}

#pragma mark - UIGestureRecognizer的代理方法
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)setCircularMask:(BOOL)circularMask {
    _maskView.circularMask = circularMask;
}

- (BOOL)isCircularMask {
    return _maskView.isCircularMask;
}

- (CGRect)contentRect {
    return _maskView.contentRect;
}

@end
