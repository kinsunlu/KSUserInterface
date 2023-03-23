//
//  KSTransparentNavigationController.h
//  KSUserInterface
//
//  Created by Kinsun on 2022/8/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 某些情况下我们需要弹出的alert/actionsheet需要再push出新的控制器，
/// 为了防止画面中出现NavigationBar请套用KSTransparentNavigationController来解决这个问题
@interface KSTransparentNavigationController : UINavigationController

@end

NS_ASSUME_NONNULL_END
