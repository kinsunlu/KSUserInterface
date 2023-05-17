//
//  KSImagePickerView.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/2.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSBaseView.h"
#import "KSImagePickerNavigationView.h"
#import "KSBoxLayoutButton.h"
#import "KSGradientButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSImagePickerView : KSSecondaryView

@property (nonatomic, weak, readonly) KSImagePickerNavigationView *navigationView;
@property (nonatomic, weak, readonly) UICollectionView *collectionView;
@property (nonatomic, weak, readonly) UITableView *albumTableView;

@property (nonatomic, readonly) KSTextButton *previewButton;
@property (nonatomic, readonly) KSGradientButton *doneButton;

@property (nonatomic, assign, getter=isShowAlbumList, readonly) BOOL showAlbumList;

- (void)chengedAlbumListStatus;

@end

NS_ASSUME_NONNULL_END
