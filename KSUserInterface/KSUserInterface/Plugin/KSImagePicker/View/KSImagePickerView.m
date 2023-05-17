//
//  KSImagePickerView.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/2.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSImagePickerView.h"
#import "KSImagePickerToolBar.h"
#import "UIColor+Hex.h"

@implementation KSImagePickerView {
    __weak UICollectionViewFlowLayout *_layout;
    __weak UIView *_toolBarSafeAreaView;
    __weak KSImagePickerToolBar *_toolBar;
}
@dynamic navigationView;

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame navigationView:KSImagePickerNavigationView.alloc.init];
}

- (instancetype)initWithFrame:(CGRect)frame navigationView:(KSSecondaryNavigationView *)navigationView {
    if (self = [super initWithFrame:frame navigationView:navigationView]) {
        self.backgroundColor = UIColor.ks_white;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _layout = layout;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        collectionView.backgroundColor = UIColor.clearColor;
        collectionView.alwaysBounceVertical = YES;
        [self addSubview:collectionView];
        _collectionView = collectionView;
        
        UIColor *whiteColor = UIColor.ks_white;
        
        UIView *toolBarSafeAreaView = [[UIView alloc] init];
        toolBarSafeAreaView.backgroundColor = whiteColor;
        [self addSubview:toolBarSafeAreaView];
        _toolBarSafeAreaView = toolBarSafeAreaView;
        
        KSImagePickerToolBar *toolBar = [[KSImagePickerToolBar alloc] init];
        [toolBarSafeAreaView addSubview:toolBar];
        _toolBar = toolBar;
        
        UITableView *albumTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        albumTableView.backgroundColor = whiteColor;
        if (@available(iOS 11.0, *)) {
            albumTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        albumTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        albumTableView.rowHeight = 88.f;
        [self addSubview:albumTableView];
        _albumTableView = albumTableView;
    }
    return self;
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
    CGFloat viewH = 48.0+safeArea.bottom;
    CGFloat viewY = windowHeight-viewH;
    CGFloat viewX = 0.0;
    _toolBarSafeAreaView.frame = (CGRect){viewX, viewY, viewW, viewH};
    
    viewY = 0.f; viewH = 48.f;
    _toolBar.frame = (CGRect){viewX, viewY, viewW, viewH};
    
    CGFloat margin = 3.f;
    NSUInteger columnCount = 4;
    CGFloat itemW = floor((windowWidth-margin*(columnCount-1))/columnCount);
    UICollectionViewFlowLayout *layout = _layout;
    layout.itemSize = (CGSize){itemW, itemW};
    layout.minimumLineSpacing = margin;
    layout.minimumInteritemSpacing = margin;
    layout.sectionInset = UIEdgeInsetsZero;
    
    _collectionView.frame = bounds;
    UIEdgeInsets inset = (UIEdgeInsets){CGRectGetMaxY(self.navigationView.frame), 0.0, _toolBarSafeAreaView.frame.size.height, 0.0};
    _collectionView.contentInset = inset;
    _collectionView.scrollIndicatorInsets = inset;
    
    _albumTableView.frame = bounds;
    CGRect frame = bounds;
    frame.origin.y = -windowHeight;
    _albumTableView.frame = frame;
    _albumTableView.contentInset = inset;
    _albumTableView.scrollIndicatorInsets = inset;
}

- (void)chengedAlbumListStatus {
    if (_showAlbumList) {
        [self hiddenAlbumList];
        _showAlbumList = NO;
        self.navigationView.indicatorUp = NO;
    } else {
        [self showAlbumList];
        _showAlbumList = YES;
        self.navigationView.indicatorUp = YES;
    }
}

- (void)showAlbumList {
    CGRect frame = _albumTableView.frame;
    frame.origin.y = 0.f;
    __weak UITableView *weakView = _albumTableView;
    [UIView animateWithDuration:0.2f animations:^{
        weakView.frame = frame;
    }];
}

- (void)hiddenAlbumList {
    CGRect frame = _albumTableView.frame;
    frame.origin.y = -self.bounds.size.height;
    __weak UITableView *weakView = _albumTableView;
    [UIView animateWithDuration:0.2f animations:^{
        weakView.frame = frame;
    }];
}

- (KSTextButton *)previewButton {
    return _toolBar.previewButton;
}

- (KSGradientButton *)doneButton {
    return _toolBar.doneButton;
}

@end
