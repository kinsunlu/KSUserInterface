//
//  KSBorderButton.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/10/29.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSBorderButton : KSButton

- (void)setBorderColor:(UIColor *_Nullable)borderColor forState:(UIControlState)state;
- (UIColor *_Nullable)borderColorForState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
