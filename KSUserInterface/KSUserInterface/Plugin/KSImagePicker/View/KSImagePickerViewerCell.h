//
//  KSImagePickerViewerCell.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/4.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSMediaViewerCell.h"
#import "KSImagePickerItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSImagePickerViewerCell : KSMediaViewerCell

@property (nonatomic, weak) UIImageView *mainView;
@property (nonatomic, strong, nullable) KSImagePickerItemModel *data;

@end

NS_ASSUME_NONNULL_END
