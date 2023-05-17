//
//  KSImagePickerViewerController.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/4.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSImagePickerViewerController.h"
#import "KSImagePickerViewerView.h"
#import "KSImagePickerViewerCell.h"
#if __has_include(<KSUserInterface/KSVideoLayer.h>)
#import "KSImagePickerViewerVideoCell.h"
#endif
#import "KSImagePickerAlbumModel.h"

@implementation KSImagePickerViewerController

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (self.navigationController == nil) {
        [super dismissViewControllerAnimated:animated completion:completion];
    } else {
        [self.navigationController popViewControllerAnimated:animated];
        if (completion != nil) {
            completion();
        }
    }
}

static NSString * const k_iden1 = @"KSImagePickerViewerCell";
#if __has_include(<KSUserInterface/KSVideoLayer.h>)
static NSString * const k_iden2 = @"KSImagePickerViewerVideoCell";
#endif
- (KSMediaViewerView *)loadMediaViewerView {
    KSImagePickerViewerView *view = [[KSImagePickerViewerView alloc] init];
    
    KSImagePickerViewerNavigationView *navigationView = view.navigationView;
    KSImagePickerSelectIndicator *selectIndicator = navigationView.selectIndicator;
    BOOL selectIndicatorHidden = _didClickDoneButtonCallback == nil;
    if (selectIndicatorHidden) {
        selectIndicator.hidden = selectIndicatorHidden;
    } else {
        selectIndicator.multipleSelected = _multipleSelected;
        [selectIndicator addTarget:self action:@selector(didClickSelectIndicator:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    KSGradientButton *doneButton = view.doneButton;
    doneButton.enabled = YES;
    [doneButton addTarget:self action:@selector(didClickButton) forControlEvents:UIControlEventTouchUpInside];
    UICollectionView *collectionView = view.collectionView;
    [collectionView registerClass:KSImagePickerViewerCell.class forCellWithReuseIdentifier:k_iden1];
#if __has_include(<KSUserInterface/KSVideoLayer.h>)
    [collectionView registerClass:KSImagePickerViewerVideoCell.class forCellWithReuseIdentifier:k_iden2];
#endif
    return view;
}

- (void)didClickNavigationBackButton:(UIControl *)backButton {
    [self dismissViewController];
}

- (void)didClickSelectIndicator:(KSImagePickerSelectIndicator *)selectIndicator {
    if (_didClickSelectButtonCallback != nil) {
        selectIndicator.index = _didClickSelectButtonCallback(self.currentIndex);
    }
}

- (void)didClickButton {
    if (_didClickDoneButtonCallback != nil) {
        _didClickDoneButtonCallback(self, self.currentIndex);
    }
}

- (KSMediaViewerCell *)mediaViewerCellAtIndexPath:(NSIndexPath *)indexPath data:(KSImagePickerItemModel *)data ofCollectionView:(UICollectionView *)collectionView {
    switch (data.asset.mediaType) {
        case PHAssetMediaTypeImage:
            return [collectionView dequeueReusableCellWithReuseIdentifier:k_iden1 forIndexPath:indexPath];
#if __has_include(<KSUserInterface/KSVideoLayer.h>)
        case PHAssetMediaTypeVideo:
            return [collectionView dequeueReusableCellWithReuseIdentifier:k_iden2 forIndexPath:indexPath];
#endif
        default:
            return nil;
    }
}

- (void)didClickViewCurrentItem {
    KSImagePickerViewerView *view = self.view;
    BOOL isFullScreen = !view.isFullScreen;
    view.fullScreen = isFullScreen;
//    [self setStatusBarHidden:isFullScreen withAnimation:UIStatusBarAnimationSlide];
}

- (void)mediaViewerCellWillBeganPan {
    [super mediaViewerCellWillBeganPan];
    self.view.fullScreen = YES;
}

- (void)currentIndexDidChanged:(NSInteger)currentIndex {
    [super currentIndexDidChanged:currentIndex];
#if __has_include(<KSUserInterface/KSVideoLayer.h>)
    KSImagePickerViewerVideoCell *cell = (KSImagePickerViewerVideoCell *)self.currentCell;
    if ([cell isKindOfClass:KSImagePickerViewerVideoCell.class]) {
        [cell.mainView play];
    }
#endif
    NSArray <KSImagePickerItemModel *> *dataArray = self.dataArray;
    KSImagePickerItemModel *data = [dataArray objectAtIndex:currentIndex];
    self.view.navigationView.selectIndicator.index = data.index;
    self.view.pageString = [NSString stringWithFormat:@"%td/%td", currentIndex+1, dataArray.count];
}

- (void)setDataArray:(NSArray <KSImagePickerItemModel *> *)dataArray currentIndex:(NSInteger)currentIndex {
    [super setDataArray:dataArray currentIndex:currentIndex];
}

- (UIImage *)currentThumb {
    return [self.dataArray objectAtIndex:self.currentIndex].thumb;
}

- (void)setMultipleSelected:(BOOL)multipleSelected {
    _multipleSelected = multipleSelected;
    if (self.viewLoaded) {
        self.view.navigationView.selectIndicator.multipleSelected = multipleSelected;
    }
}

@end
