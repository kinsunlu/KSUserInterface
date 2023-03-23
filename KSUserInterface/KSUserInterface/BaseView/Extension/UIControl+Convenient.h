//
//  UIControl+Convenient.h
//  KSUserInterface
//
//  Created by Kinsun on 2022/8/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 方便Swift以闭包形式接收响应
@interface UIControl (Convenient)

- (void)addControlEvents:(UIControlEvents)events handle:(void(^)(__kindof UIControl *))handle;

- (void)removeHandleForControlEvents:(UIControlEvents)events;

@end

NS_ASSUME_NONNULL_END
