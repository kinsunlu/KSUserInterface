//
//  KSStackView.m
//  KSUserInterface
//
//  Created by Kinsun on 2022/8/18.
//

#import "KSStackView.h"

@implementation KSStackView

- (instancetype)initWithSubviews:(NSArray<UIView *> *)subviews {
    if (self = [super initWithFrame:CGRectZero]) {
        for (UIView *subview in subviews) {
            [super addSubview:subview];
        }
    }
    return self;
}

- (instancetype)initWithSubview:(UIView *)subview {
    if (self = [super initWithFrame:CGRectZero]) {
        [super addSubview:subview];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSArray <UIView *> *subviews = self.subviews.copy;
    NSInteger count = subviews.count;
    NSMutableArray <NSValue *> *sizeArray = [NSMutableArray arrayWithCapacity:count];
    CGSize windowSize = self.bounds.size;
    CGFloat left = _contentInset.left;
    CGFloat right = _contentInset.right;
    CGFloat top = _contentInset.top;
    CGFloat bottom = _contentInset.bottom;
    CGFloat windowWidth = windowSize.width-left-right;
    CGFloat windowHeight = windowSize.height-top-bottom;
    CGFloat spacing = _spacing;
    if (_axis == KSStackViewAxisHorizontal) {
        CGFloat totalW = 0.0;
        for (UIView *subview in subviews) {
            CGSize size = [subview sizeThatFits:(CGSize){MAXFLOAT, windowSize.height}];
            totalW += size.width;
            [sizeArray addObject:[NSValue valueWithCGSize:size]];
        }
        CGFloat x;
        switch (_stackLayout) {
            case KSStackViewLayoutCenter:
                x = (windowWidth-(totalW+spacing*(count-1)))*0.5;
                if (x < 0.0) {
                    x = 0.0;
                    spacing = (windowWidth-totalW)/(count-1);
                }
                x += left;
                break;
            case KSStackViewLayoutFromStart:
                x = left;
                break;
            case KSStackViewLayoutFromEnd:
                x = windowWidth-(totalW+spacing*(count-1))+right;
                break;
            case KSStackViewLayoutBothEnds:
                x = left;
                spacing = (windowWidth-totalW)/(count-1);
                break;
        }
        CGRect (^getFrame)(CGSize, CGFloat);
        switch (_subviewLayout) {
            case KSStackViewLayoutCenter:
                getFrame = ^(CGSize size, CGFloat x){
                    return (CGRect){x, (windowHeight-size.height)*0.5+top, size};
                };
                break;
            case KSStackViewLayoutFromStart:
                getFrame = ^(CGSize size, CGFloat x){
                    return (CGRect){x, top, size};
                };
                break;
            case KSStackViewLayoutFromEnd:
                getFrame = ^(CGSize size, CGFloat x){
                    return (CGRect){x, windowHeight-size.height+top, size};
                };
                break;
            case KSStackViewLayoutBothEnds:
                getFrame = ^(CGSize size, CGFloat x){
                    return (CGRect){x, top, size.width, windowHeight};
                };
                break;
        }
        for (NSInteger i = 0; i < count; i++) {
            UIView *view = [subviews objectAtIndex:i];
            CGSize size = [sizeArray objectAtIndex:i].CGSizeValue;
            CGRect frame = getFrame(size, x);
            view.frame = frame;
            x = CGRectGetMaxX(frame)+spacing;
        }
    } else {
        CGFloat totalH = 0.0;
        for (UIView *subview in subviews) {
            CGSize size = [subview sizeThatFits:(CGSize){windowSize.width, MAXFLOAT}];
            totalH += size.height;
            [sizeArray addObject:[NSValue valueWithCGSize:size]];
        }
        CGFloat y;
        switch (_stackLayout) {
            case KSStackViewLayoutCenter:
                y = (windowHeight-(totalH+spacing*(count-1)))*0.5;
                if (y < 0.0) {
                    y = 0.0;
                    spacing = (windowHeight-totalH)/(count-1);
                }
                y += top;
                break;
            case KSStackViewLayoutFromStart:
                y = top;
                break;
            case KSStackViewLayoutFromEnd:
                y = windowHeight-(totalH+spacing*(count-1))+bottom;
                break;
            case KSStackViewLayoutBothEnds:
                y = top;
                spacing = (windowHeight-totalH)/(count-1);
                break;
        }
        CGRect (^getFrame)(CGSize, CGFloat);
        switch (_subviewLayout) {
            case KSStackViewLayoutCenter:
                getFrame = ^(CGSize size, CGFloat y){
                    return (CGRect){(windowWidth-size.width)*0.5+left, y, size};
                };
                break;
            case KSStackViewLayoutFromStart:
                getFrame = ^(CGSize size, CGFloat y){
                    return (CGRect){left, y, size};
                };
                break;
            case KSStackViewLayoutFromEnd:
                getFrame = ^(CGSize size, CGFloat y){
                    return (CGRect){windowWidth-size.width+left, y, size};
                };
                break;
            case KSStackViewLayoutBothEnds:
                getFrame = ^(CGSize size, CGFloat y){
                    return (CGRect){left, y, windowWidth, size.height};
                };
                break;
        }
        for (NSInteger i = 0; i < count; i++) {
            UIView *view = [subviews objectAtIndex:i];
            CGSize size = [sizeArray objectAtIndex:i].CGSizeValue;
            CGRect frame = getFrame(size, y);
            view.frame = frame;
            y = CGRectGetMaxY(frame)+spacing;
        }
    }
}

- (void)setAxis:(KSStackViewAxis)axis {
    if (_axis == axis) return;
    _axis = axis;
    [self setNeedsLayout];
}

- (void)setStackLayout:(KSStackViewLayout)stackLayout {
    if (_stackLayout == stackLayout) return;
    _stackLayout = stackLayout;
    [self setNeedsLayout];
}

- (void)setSubviewLayout:(KSStackViewLayout)subviewLayout {
    if (_subviewLayout == subviewLayout) return;
    _subviewLayout = subviewLayout;
    [self setNeedsLayout];
}

- (void)setSpacing:(CGFloat)spacing {
    if (_spacing == spacing) return;
    _spacing = spacing;
    [self setNeedsLayout];
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    [self setNeedsLayout];
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
    [super insertSubview:view atIndex:index];
    [self setNeedsLayout];
}

- (void)removeSubview:(UIView *)subview {
    [subview removeFromSuperview];
    [self setNeedsLayout];
}

- (UIView *)removeSubviewAtIndex:(NSInteger)index {
    NSArray <UIView *> *subviews = self.subviews;
    if (index >= 0 && index < subviews.count) {
        UIView *view = [subviews objectAtIndex:index];
        [view removeFromSuperview];
        [self setNeedsLayout];
        return view;
    }
    return nil;
}

- (CGSize)sizeThatFits:(CGSize)size {
    NSArray <UIView *> *subviews = self.subviews.copy;
    CGFloat w = 0.0;
    CGFloat h = 0.0;
    if (_axis == KSStackViewAxisHorizontal) {
        for (UIView *subview in subviews) {
            CGSize r = [subview sizeThatFits:size];
            w += r.width;
            CGFloat rh = r.height;
            if (rh > h) h = rh;
        }
        w += _spacing*(subviews.count-1)+_contentInset.left+_contentInset.right;
        return (CGSize){w, h+_contentInset.top+_contentInset.bottom};
    } else {
        for (UIView *subview in subviews) {
            CGSize r = [subview sizeThatFits:size];
            h += r.height;
            CGFloat rw = r.width;
            if (rw > w) w = rw;
        }
        h += _spacing*(subviews.count-1)+_contentInset.top+_contentInset.bottom;
        return (CGSize){w+_contentInset.left+_contentInset.right, h};
    }
}

@end

@implementation KSStrutView

- (instancetype)initWithContentView:(UIView *)contentView {
    if (self = [super initWithFrame:CGRectZero]) {
        _contentViewSize = contentView.bounds.size;
        [self addSubview:contentView];
        _contentView = contentView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _contentView.frame = self.bounds;
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView == contentView) return;
    [_contentView removeFromSuperview];
    _contentView = contentView;
    if (contentView != nil) {
        [self addSubview:contentView];
        [self setNeedsLayout];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return _contentViewSize;
}

@end

@implementation KSBoxLayoutView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _contentInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = self.bounds.size;
    CGFloat windowHeight = size.height;
    CGFloat x = _contentInset.left;
    CGFloat y = _contentInset.top;
    _contentView.frame = (CGRect){x, y, size.width-x-_contentInset.right, windowHeight-y-_contentInset.bottom};
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView != nil) {
        [_contentView removeFromSuperview];
    }
    _contentView = contentView;
    if (contentView != nil) {
        [self addSubview:contentView];
        [self setNeedsLayout];
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    if (UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset)) return;
    _contentInset = contentInset;
    [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat defW = _contentInset.left+_contentInset.right;
    CGFloat defH = _contentInset.top+_contentInset.bottom;
    CGSize r = [_contentView sizeThatFits:(CGSize){size.width-defW, size.height-defH}];
    r.width += defW;
    r.height += defH;
    return r;
}

- (void)sizeToFit {
    self.frame = (CGRect){CGPointZero, [self sizeThatFits:(CGSize){MAXFLOAT, MAXFLOAT}]};
}

@end
