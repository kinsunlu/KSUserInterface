//
//  KSImagePickerNavigationView.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/2.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSNavigationView.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSImagePickerNavigationView : KSSecondaryNavigationView

@property (nonatomic, readonly) UIControl *centerButton;

@property (nonatomic, getter=isIndicatorUp) BOOL indicatorUp;

@end

NS_ASSUME_NONNULL_END
