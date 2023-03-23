//
//  KSImagePickerViewerNavigationView.h
//  KSUserInterface
//
//  Created by Kinsun on 2019/1/7.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSNavigationView.h"
#import "KSImagePickerSelectIndicator.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSImagePickerViewerNavigationView : KSSecondaryNavigationView

@property (nonatomic, weak, readonly) KSImagePickerSelectIndicator *selectIndicator;

@end

NS_ASSUME_NONNULL_END
