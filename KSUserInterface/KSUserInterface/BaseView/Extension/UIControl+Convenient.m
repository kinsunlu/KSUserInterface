//
//  UIControl+Convenient.m
//  KSUserInterface
//
//  Created by Kinsun on 2022/8/12.
//

#import "UIControl+Convenient.h"
#import <objc/runtime.h>

@interface UIControl (Convenient)

@property (nonatomic, readonly) NSMutableDictionary<NSString *, id> *__handlesData;

@end

void kkkk_new_UIControl_performHandle(UIControl *self, SEL _cmd) {
    NSString *key = NSStringFromSelector(_cmd);
    void (^handle)(__kindof UIControl *) = [self.__handlesData objectForKey:key];
    if (handle != nil) {
        handle(self);
    }
}

@implementation UIControl (Convenient)

- (NSMutableDictionary<NSString *,id> *)__handlesData {
    NSMutableDictionary<NSString *,id> *handlesData = objc_getAssociatedObject(self, "__handlesData");
    if (handlesData == nil) {
        handlesData = NSMutableDictionary.dictionary;
        objc_setAssociatedObject(self, "__handlesData", handlesData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return handlesData;
}

- (void)addControlEvents:(UIControlEvents)events handle:(void (^)(__kindof UIControl *))handle {
    NSString *key = [NSString stringWithFormat:@".____handleKey@%lu", (unsigned long)events];
    [self.__handlesData setObject:[handle copy] forKey:key];
    Class cls = UIControl.class;
    SEL selector = NSSelectorFromString(key);
    if (!class_respondsToSelector(cls, selector)) {
        class_addMethod(cls, selector, (IMP)kkkk_new_UIControl_performHandle, "v@");
    }
    [self addTarget:self action:selector forControlEvents:events];
}

- (void)removeHandleForControlEvents:(UIControlEvents)events {
    NSString *key = [NSString stringWithFormat:@".____handleKey@%lu", (unsigned long)events];
    [self.__handlesData removeObjectForKey:key];
    [self removeTarget:self action:NSSelectorFromString(key) forControlEvents:events];
}

- (void)dealloc {
    objc_removeAssociatedObjects(self);
}

@end
