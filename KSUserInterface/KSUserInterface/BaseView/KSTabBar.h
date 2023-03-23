//
//  KSTabBar.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/1.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSTabBarItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSTabBar : UIView

@property (nonatomic, strong, readonly) NSArray <KSTabBarItem *> *items;
@property (nonatomic, strong, nullable) KSTabBarItem *selectedItem;
@property (nonatomic, getter=isHiddenLine) BOOL hiddenLine;

@end

@interface KSSystemTabBar : UITabBar

@property (nonatomic, strong, readonly) KSTabBar *tabBar;

@end

NS_ASSUME_NONNULL_END
