//
//  KSPageControl.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/2.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSPageControl.h"

@interface _KSPageControlPoint : UIView

@property (nonatomic, assign) NSInteger index;

@end

@implementation _KSPageControlPoint

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    layer.cornerRadius = layer.frame.size.height*0.5;
}

@end

@interface KSPageControl ()

@property (nonatomic, assign, getter=_isToMuch) BOOL _toMuch;

@end

@implementation KSPageControl {
    NSMutableArray <_KSPageControlPoint *> *_pointArray;
    
    CGFloat _normalW;
    CGFloat _selectedW;
    CGFloat _pointMargin;
    CGFloat _egdeMargin;
    CGFloat _actionZone;
    CGFloat _beforOffsetX;
    
    __weak UIView *_toMuchLine;
    __weak _KSPageControlPoint *_toMuchPoint;
    CGFloat _lineMaxW;
    
    BOOL _isNeedLayout;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        _pointArray = NSMutableArray.array;
        _isNeedLayout = YES;
        _currentPage = 0;
        _toMuchEgdeMargin = 20.f;
        
        UIView *toMuchLine = [[UIView alloc] init];
        toMuchLine.alpha = 0.2f;
        [self addSubview:toMuchLine];
        _toMuchLine = toMuchLine;
        
        _KSPageControlPoint *toMuchPoint = [[_KSPageControlPoint alloc] init];
        [self addSubview:toMuchPoint];
        _toMuchPoint = toMuchPoint;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_isNeedLayout) {
        CGFloat normalW = _normalW, selectedW = _selectedW, egdeMargin = _egdeMargin;
        if (self._isToMuch) {
            CGSize windowSize = self.bounds.size;
            CGFloat windowWidth = windowSize.width;
            CGFloat windowHeight = windowSize.height;
            CGFloat lineW = windowWidth-egdeMargin*2.0;
            
            CGFloat viewX = egdeMargin;
            CGFloat viewW = lineW;
            CGFloat viewH = 1.5;
            CGFloat viewY = (windowHeight-viewH)*0.5;
            _toMuchLine.frame = (CGRect){viewX, viewY, viewW, viewH};
            
            viewH = normalW;
            viewW = selectedW;
            viewY = 0.0;
            CGFloat maxWidth = lineW-viewW;
            _lineMaxW = maxWidth;
            viewX = maxWidth/(_numberOfPages-1)*_currentPage+egdeMargin;
            _toMuchPoint.frame = (CGRect){viewX, viewY, viewW, viewH};
        } else {
            NSArray <_KSPageControlPoint *> *pointArray = _pointArray;
            if (_numberOfPages > 0 && _numberOfPages == pointArray.count) {
                CGFloat margin = _pointMargin;
                CGFloat viewH = normalW;
                CGFloat viewX = egdeMargin;
                for (NSUInteger i = 0; i < _numberOfPages; i++) {
                    CGFloat viewW = _currentPage == i ? selectedW : normalW;
                    _KSPageControlPoint *point = [pointArray objectAtIndex:i];
                    point.frame = (CGRect){viewX, 0.0, viewW, viewH};
                    viewX = CGRectGetMaxX(point.frame)+margin;
                }
            }
        }
        _isNeedLayout = NO;
    }
}

- (void)setFrame:(CGRect)frame {
    _isNeedLayout = YES;
    [super setFrame:frame];
    [self _updateLayoutElement];
}

- (void)_updateLayoutElement {
    CGSize size = self.bounds.size;
    if (CGSizeEqualToSize(size, CGSizeZero)) return;
    NSInteger maginCount = _numberOfPages-1;
    CGFloat normalW = ceil(size.height),
    selectedW = ceil(normalW*3.75f),
    margin = ceil(normalW*1.25f),
    maxW = maginCount*(normalW+margin)+selectedW,
    egdeMargin = ceil((size.width-maxW)*0.5f);
    
    _selectedW = selectedW;
    _normalW = normalW;
    CGFloat minMargin = _toMuchEgdeMargin;
    if (egdeMargin < minMargin) {
        self._toMuch = YES;
        _egdeMargin = minMargin;
    } else {
        self._toMuch = NO;
        _pointMargin = margin;
        _egdeMargin = egdeMargin;
        _actionZone = normalW+selectedW;
    }
}

- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (_numberOfPages != numberOfPages) {
        _numberOfPages = numberOfPages;
        [self _updateLayoutElement];
        if (!self._isToMuch) {
            NSMutableArray <_KSPageControlPoint *> *pointArray = _pointArray;
            if (pointArray.count > 0) {
                for (_KSPageControlPoint *point in pointArray) {
                    [point removeFromSuperview];
                }
                [pointArray removeAllObjects];
            }
            for (NSUInteger i = 0; i < numberOfPages; i++) {
                _KSPageControlPoint *point = [[_KSPageControlPoint alloc] init];
                point.index = i;
                point.backgroundColor = self.tintColor;
                [self addSubview:point];
                [pointArray addObject:point];
            }
        }
    }
}

- (void)set_toMuch:(BOOL)toMuch {
    __toMuch = toMuch;
    BOOL hidden = !toMuch;
    _toMuchPoint.hidden = hidden;
    _toMuchLine.hidden = hidden;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    NSArray <_KSPageControlPoint*>*pointArray = _pointArray;
    if (pointArray.count > 0) {
        for (_KSPageControlPoint *point in pointArray) {
            point.backgroundColor = tintColor;
        }
    }
    _toMuchLine.backgroundColor = tintColor;
    _toMuchPoint.backgroundColor = tintColor;
}

- (void)setAlpha:(CGFloat)alpha {
    NSArray <_KSPageControlPoint *> *pointArray = _pointArray;
    if (pointArray.count > 0) {
        for (_KSPageControlPoint *point in pointArray) {
            point.alpha = alpha;
        }
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage != currentPage && currentPage >= 0 && currentPage < _numberOfPages) {
        _currentPage = currentPage;
        _isNeedLayout = YES;
        [self setNeedsLayout];
    }
}

- (void)updatePageControlWithScrollView:(UIScrollView *)scrollView {
    CGFloat contentSizeW = scrollView.contentSize.width;
    if (contentSizeW > 0.f) {
        CGFloat offsetX = scrollView.contentOffset.x,
        scrollViewW = scrollView.bounds.size.width;
        NSInteger index = offsetX/scrollViewW;
        _currentPage = index;
        if (self._isToMuch) {
            CGRect frame = _toMuchPoint.frame;
            frame.origin.x = offsetX*_lineMaxW/(contentSizeW-scrollViewW)+frame.origin.x;
            _toMuchPoint.frame = frame;
        } else {
            NSInteger toIndex = index+1;
            _KSPageControlPoint *leftPoint = [self _getPointViewOfIndex:index];
            _KSPageControlPoint *rightPoint = [self _getPointViewOfIndex:toIndex];
            CGRect rightPointFrame = rightPoint.frame;
            CGFloat scale = toIndex*scrollViewW-offsetX;
            CGFloat width = scale*(_selectedW-_normalW)/scrollViewW+_normalW;
            CGRect frame = leftPoint.frame;
            frame.size.width = width;
            leftPoint.frame = frame;
            rightPointFrame.origin.x = CGRectGetMaxX(leftPoint.frame)+_pointMargin;
            rightPointFrame.size.width = _actionZone-width;
            rightPoint.frame = rightPointFrame;
            _beforOffsetX = offsetX;
        }
    }
}

- (_KSPageControlPoint *)_getPointViewOfIndex:(NSInteger)index {
    if (index >= 0 && index < _numberOfPages) {
        return [_pointArray objectAtIndex:index];
    }
    return nil;
}

@end
