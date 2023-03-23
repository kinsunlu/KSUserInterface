//
//  KSPageSlideSegmented.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/13.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSPageSlideSegmented.h"
#import "UIColor+Hex.h"

@interface _KSPageSlideSegmentedItem : UIControl

@property (nonatomic) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *selectedTitleColor;
@property (nonatomic, strong) UIColor *normalTitleColor;

@end

@implementation _KSPageSlideSegmentedItem {
    __weak CATextLayer *_textLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _selectedTitleColor = UIColor.ks_red;
        _normalTitleColor = UIColor.ks_title;
        
        CATextLayer *textLayer = [CATextLayer layer];
//        textLayer.wrapped = YES;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.contentsScale = UIScreen.mainScreen.scale;
        [self.layer addSublayer:textLayer];
        _textLayer = textLayer;
        
        self.selected = NO;
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    CGSize windowSize = layer.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    
    layer.cornerRadius = windowHeight*0.5f;
    
    CGFloat viewH = _font.lineHeight;
    CGFloat viewY = (windowHeight-viewH)*0.5f;
    _textLayer.frame = (CGRect){0.0, viewY, windowWidth, viewH};
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    _textLayer.foregroundColor = (selected ? _selectedTitleColor : _normalTitleColor).CGColor;
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    _selectedTitleColor = selectedTitleColor;
    if (self.isSelected) {
        _textLayer.foregroundColor = selectedTitleColor.CGColor;
    }
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor {
    _normalTitleColor = normalTitleColor;
    if (!self.isSelected) {
        _textLayer.foregroundColor = normalTitleColor.CGColor;
    }
}

- (void)setFont:(UIFont *)font {
    _font = font;
    if (font == nil) {
        _textLayer.font = nil;
    } else {
        CFStringRef fontCFString = (__bridge CFStringRef)font.fontName;
        CGFontRef fontRef = CGFontCreateWithFontName(fontCFString);
        _textLayer.font = fontRef;
        _textLayer.fontSize = font.pointSize;
        CGFontRelease(fontRef);
    }
}

- (void)setText:(NSString *)text {
    _textLayer.string = text;
}

- (NSString *)text {
    return _textLayer.string;
}

@end

@implementation KSPageSlideSegmented {
    NSPointerArray *_itemViewArray;
    __weak _KSPageSlideSegmentedItem *_selectedItemView;
    
    NSArray <NSNumber *>*_widths;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _font = [UIFont systemFontOfSize:14.0];
        self.showsHorizontalScrollIndicator = NO;
        self.clipsToBounds = YES;
        self.contentInset = (UIEdgeInsets){0.0, 2.0, 0.0, 2.0};
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowHeight = windowSize.height;
    
    CGFloat viewX = 0.0;
    CGFloat viewY = 0.0;
    CGFloat viewW = 0.0;
    CGFloat viewH = windowHeight;
    NSUInteger count = _itemViewArray.count;
    CGFloat lastX = 0;
    for (NSUInteger i = 0; i < count; i++) {
        viewX = lastX;
        viewW = [_widths objectAtIndex:i].doubleValue;
        _KSPageSlideSegmentedItem *itemView = [_itemViewArray pointerAtIndex:i];
        itemView.frame = (CGRect){viewX, viewY, viewW, viewH};
        lastX = CGRectGetMaxX(itemView.frame);
        if (i == count-1) {
            self.contentSize = (CGSize){lastX, 0.f};
        }
    }
}

- (void)setItems:(NSArray<NSString *> *)items {
    _items = items;
    if (_itemViewArray != nil)
        for (_KSPageSlideSegmentedItem *itemView in _itemViewArray)
            [itemView removeFromSuperview];
    
    UIFont *font = self.font;
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGSize maxSize = (CGSize){CGFLOAT_MAX, CGFLOAT_MAX};
    
    NSMutableArray <NSNumber *> * widths = [NSMutableArray arrayWithCapacity:items.count];
    
    SEL selector = @selector(_didClickItem:);
    NSPointerArray *itemViewArray = [NSPointerArray weakObjectsPointerArray];
    for (NSUInteger i = 0; i < items.count; i++) {
        NSString *title = [items objectAtIndex:i];
        
        CGSize k_size = [title boundingRectWithSize:maxSize options:options attributes:attributes context:nil].size;
        CGFloat width = floor(k_size.width)+30.f;
        [widths addObject:[NSNumber numberWithDouble:width]];
        
        _KSPageSlideSegmentedItem *itemView = _KSPageSlideSegmentedItem.alloc.init;
        itemView.font = _font;
        itemView.tag = i;
        itemView.text = title;
        [itemView addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:itemView];
        [itemViewArray addPointer:(__bridge void *)itemView];
        if (i == 0) {
            itemView.selected = YES;
            _selectedItemView = itemView;
        }
    }
    _itemViewArray = itemViewArray;
    _widths = widths;
    [self setNeedsLayout];
}

- (void)setSelectedSegmentIndex:(NSUInteger)index {
    if (index >= 0 && index < _itemViewArray.count && _selectedSegmentIndex != index) {
        _selectedSegmentIndex = index;
        if (_selectedItemView != nil) _selectedItemView.selected = NO;
        _KSPageSlideSegmentedItem *itemView = [_itemViewArray pointerAtIndex:index];
        itemView.selected = YES;
        _selectedItemView = itemView;
        CGRect frame = itemView.frame;
        CGRect bounds = self.bounds;
        if (!CGRectContainsRect(bounds, frame)) {
            CGFloat offsetX = self.contentOffset.x;
            CGFloat x = frame.origin.x-offsetX;
            if (x < 0) {
                CGFloat defX = offsetX+x-self.contentInset.left;
                [self setContentOffset:(CGPoint){defX, 0.f} animated:YES];
            } else {
                CGFloat maxX = CGRectGetMaxX(frame)-offsetX;
                CGFloat width = bounds.size.width;
                if (maxX > width) {
                    CGFloat defX = offsetX+(maxX-width)+self.contentInset.right;
                    [self setContentOffset:(CGPoint){defX, 0.f} animated:YES];
                }
            }
        }
    }
}

- (void)_didClickItem:(_KSPageSlideSegmentedItem *)itemView {
    if (_didClickItemCallback != nil) {
        _didClickItemCallback(self, itemView.tag);
    }
}

- (void)setFont:(UIFont *)font {
    _font = font;
    for (_KSPageSlideSegmentedItem *itemView in _itemViewArray) {
        itemView.font = font;
    }
}

@end
