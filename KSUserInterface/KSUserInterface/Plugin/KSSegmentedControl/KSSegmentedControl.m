//
//  KSSegmentedControl.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/11/25.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSSegmentedControl.h"

@interface _KSSCItemLayer : CATextLayer

@property (nonatomic, assign) CGColorRef normalColor;
@property (nonatomic, assign) CGColorRef selectedColor;
@property (nonatomic, assign, getter=isSelected) BOOL selected;

@end

@implementation _KSSCItemLayer

- (instancetype)init {
    if (self = [super init]) {
        self.wrapped = NO;
        self.alignmentMode = kCAAlignmentCenter;
    }
    return self;
}

- (void)setNormalColor:(CGColorRef)normalColor {
    _normalColor = normalColor;
    if (!_selected) self.foregroundColor = normalColor;
}

- (void)setSelectedColor:(CGColorRef)selectedColor {
    _selectedColor = selectedColor;
    if (_selected) self.foregroundColor = selectedColor;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.foregroundColor = selected ? _selectedColor : _normalColor;
}

@end

#import "UIColor+Hex.h"

@implementation KSSegmentedControl {
    NSArray <NSNumber *> *_itemsWidthArray;
    NSPointerArray *_textLayerArray;
    __weak _KSSCItemLayer *_selectedTextlayer;
    __weak CALayer *_indLayer;
    
    CGFloat _totalWidth;
    CGFloat _maxHeight;
}

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray <NSString *> *)items {
    if (self = [super initWithFrame:frame]) {
        _items = items.copy;
        _totalWidth = 0.0;
        _indicatorHeight = 3.0;
        CALayer *layer = self.layer;
        
        CALayer *indLayer = CALayer.layer;
        [layer addSublayer:indLayer];
        _indLayer = indLayer;
        self.indndicatorColor = UIColor.ks_main;
        
        CGFloat scale = UIScreen.mainScreen.scale;
        NSPointerArray *textLayerArray = NSPointerArray.weakObjectsPointerArray;
        for (NSString *title in _items) {
            _KSSCItemLayer *textLayer = [_KSSCItemLayer layer];
            textLayer.contentsScale = scale;
            textLayer.string = title;
            [layer addSublayer:textLayer];
            [textLayerArray addPointer:(__bridge void *)textLayer];
        }
        _textLayerArray = textLayerArray;
        
        [self _forceUpdateSelectedSegmentIndex:0];
        self.font = [UIFont systemFontOfSize:18.0];
        self.normalTextColor = UIColor.ks_lightTitle;
        self.selectedTextColor = UIColor.ks_title;
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    CGSize windowSize = layer.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    
    CGFloat remainderWidth = windowWidth;
    NSUInteger count = _itemsWidthArray.count;
    for (NSInteger i = 0; i < count; i++) {
        NSNumber *value = [_itemsWidthArray objectAtIndex:i];
        CGFloat width = value.doubleValue;
        remainderWidth -= width;
    }
    CGFloat margin = floor((remainderWidth-_egdeMargin*2.0)/count);
    CGFloat viewX = _egdeMargin+margin*0.5;
    CGFloat viewH = _font.lineHeight;
    CGFloat viewY = (windowHeight-viewH)*0.5;
    for (NSInteger i = 0; i < count; i++) {
        NSNumber *value = [_itemsWidthArray objectAtIndex:i];
        CGFloat viewW = value.doubleValue;
        _KSSCItemLayer *textLayer = [_textLayerArray pointerAtIndex:i];
        CGRect frame = (CGRect){viewX, viewY, viewW, viewH};
        textLayer.frame = frame;
        viewX = CGRectGetMaxX(frame)+margin;
    }
    
    if (windowHeight > 1.0 && !_indLayer.hidden && _indLayer.frame.size.width < 1.0) {
        _KSSCItemLayer *textLayer = [_textLayerArray pointerAtIndex:_selectedSegmentIndex];
        CGRect frame = textLayer.frame;
        frame.size.height = _indicatorHeight;
        frame.origin.y = windowHeight-_indicatorBottomEgdeInset-_indicatorHeight;
        _indLayer.frame = frame;
    }
}

- (void)setShowIndicator:(BOOL)showIndicator {
    _indLayer.hidden = !showIndicator;
}

- (BOOL)isShowIndicator {
    return !_indLayer.hidden;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_didClickItem != nil) {
        UITouch *touch = touches.anyObject;
        CGPoint location = [touch locationInView:self];
        CGRect bounds = self.bounds;
        if (CGRectContainsPoint(bounds, location)) {
            CGFloat lx = location.x;
            for (NSUInteger i = 0; i < _textLayerArray.count; i++) {
                _KSSCItemLayer *textLayer = [_textLayerArray pointerAtIndex:i];
                CGRect frame = textLayer.frame;
                CGFloat x = frame.origin.x;
                CGFloat maxX = x+frame.size.width;
                if (lx >= x && lx < maxX) {
                    _didClickItem(self, i);
                    return;
                }
            }
        }
    }
    [super touchesEnded:touches withEvent:event];
}

- (void)setSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex {
    if (_selectedSegmentIndex != selectedSegmentIndex) {
        [self _forceUpdateSelectedSegmentIndex:selectedSegmentIndex];
    }
}

- (void)_forceUpdateSelectedSegmentIndex:(NSUInteger)selectedSegmentIndex {
    if (selectedSegmentIndex >= 0 && selectedSegmentIndex < _textLayerArray.count) {
        _selectedSegmentIndex = selectedSegmentIndex;
        if (_selectedTextlayer != nil)
            _selectedTextlayer.selected = NO;
        
        _KSSCItemLayer *textLayer = [_textLayerArray pointerAtIndex:selectedSegmentIndex];
        textLayer.selected = YES;
        _selectedTextlayer = textLayer;
    }
}

- (void)setFont:(UIFont *)font {
    if (font == nil) return;
    _font = font;
    
    NSUInteger count = _textLayerArray.count;
    CGFloat pointSize = font.pointSize;
    CFStringRef fontCFString = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontCFString);
    
    CGSize maxSize = (CGSize){MAXFLOAT, MAXFLOAT};
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary <NSAttributedStringKey, UIFont *> *attributes = @{NSFontAttributeName: font};
    NSMutableArray <NSNumber *> *itemsWidthArray = [NSMutableArray arrayWithCapacity:count];
    
    _totalWidth = 0.0;
    _maxHeight = 0.0;
    for (NSUInteger i = 0; i < count; i++) {
        NSString *string = [_items objectAtIndex:i];
        CGSize size = [string boundingRectWithSize:maxSize options:options attributes:attributes context:nil].size;
        CGFloat w = size.width+3.0;
        NSNumber *width = [NSNumber numberWithDouble:w];
        [itemsWidthArray addObject:width];
        _totalWidth += w;
        _maxHeight = MAX(size.height, _maxHeight);
        
        _KSSCItemLayer *textLayer = [_textLayerArray pointerAtIndex:i];
        textLayer.font = fontRef;
        textLayer.fontSize = pointSize;
    }
    CGFontRelease(fontRef);
    _itemsWidthArray = itemsWidthArray;
}

- (void)setNormalTextColor:(UIColor *)normalTextColor {
    _normalTextColor = normalTextColor;
    CGColorRef cgColor = normalTextColor.CGColor;
    for (_KSSCItemLayer *textLayer in _textLayerArray) {
        textLayer.normalColor = cgColor;
    }
}

- (void)setSelectedTextColor:(UIColor *)selectedTextColor {
    _selectedTextColor = selectedTextColor;
    CGColorRef cgColor = selectedTextColor.CGColor;
    for (_KSSCItemLayer *textLayer in _textLayerArray) {
        textLayer.selectedColor = cgColor;
    }
}

- (void)setIndndicatorColor:(UIColor *)indndicatorColor {
    _indndicatorColor = indndicatorColor;
    _indLayer.backgroundColor = indndicatorColor.CGColor;
}

- (void)updateIndicatorProportion:(CGFloat)proportion {
    NSInteger index = floor(proportion);
    NSInteger toIndex = index+1;
    if ([self checkIndexAvailable:index] && [self checkIndexAvailable:toIndex]) {
        _KSSCItemLayer *textLayer = [_textLayerArray pointerAtIndex:index];
        _KSSCItemLayer *toTextLayer = [_textLayerArray pointerAtIndex:toIndex];
        CGRect textLayerFrame = textLayer.frame;
        CGRect toTextLayerFrame = toTextLayer.frame;
        
        CGFloat scale = proportion-index;
        
        CGFloat width = textLayerFrame.size.width;
        CGFloat toWidth = toTextLayerFrame.size.width;
        CGFloat defWidth = toWidth-width;
        CGFloat resultWidth = defWidth*scale+width;
        
        CGFloat x = textLayerFrame.origin.x;
        CGFloat toX = toTextLayerFrame.origin.x;
        CGFloat defX = toX-x;
        CGFloat resultX = defX*scale+x;

        CGRect frame = _indLayer.frame;
        frame.size.width = resultWidth;
        frame.origin.x = resultX;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _indLayer.frame = frame;
        [CATransaction commit];
    }
}

- (BOOL)checkIndexAvailable:(NSInteger)index {
    return index >= 0 && index < _textLayerArray.count;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return (CGSize){MIN(size.width, _totalWidth+_egdeMargin*2.0), MIN(size.height, _maxHeight)};
}

@end

