//
//  KSImagePickerViewerController.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/4.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSMediaViewerController.h"
#import "KSImagePickerViewerView.h"

NS_ASSUME_NONNULL_BEGIN

@class KSImagePickerItemModel;
@interface KSImagePickerViewerController : KSMediaViewerController<KSImagePickerItemModel*, KSImagePickerViewerView*, KSMediaViewerCell*>

@property (nonatomic, getter=isMultipleSelected) BOOL multipleSelected;
@property (nonatomic, copy) NSUInteger (^didClickSelectButtonCallback)(NSUInteger index);
@property (nonatomic, copy) void (^didClickDoneButtonCallback)(KSImagePickerViewerController *controller, NSUInteger index);

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^ _Nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
