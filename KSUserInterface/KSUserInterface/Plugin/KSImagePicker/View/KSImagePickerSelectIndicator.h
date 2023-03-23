//
//  KSImagePickerSelectIndicator.h
//  KSUserInterface
//
//  Created by Kinsun on 2019/1/7.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSImagePickerSelectIndicator : UIControl

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign, getter=isMultipleSelected) BOOL multipleSelected;

@end

NS_ASSUME_NONNULL_END
