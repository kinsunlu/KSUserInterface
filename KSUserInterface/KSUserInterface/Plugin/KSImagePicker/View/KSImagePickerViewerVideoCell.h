//
//  KSImagePickerViewerVideoCell.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/11.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#if __has_include(<KSUserInterface/KSVideoLayer.h>)
#import "KSMediaViewerCell.h"
#import "KSVideoPlayerLiteView.h"
#import "KSImagePickerItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSImagePickerViewerVideoCell : KSMediaViewerCell

@property (nonatomic, weak) KSVideoPlayerLiteView *mainView;
@property (nonatomic, strong, nullable) KSImagePickerItemModel *data;

@end

NS_ASSUME_NONNULL_END
#endif
