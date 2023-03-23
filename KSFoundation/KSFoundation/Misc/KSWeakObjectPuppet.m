//
//  KSWeakObjectPuppet.m
//  KSFoundation
//
//  Created by Kinsun on 2022/8/9.
//

#import "KSWeakObjectPuppet.h"

@implementation KSWeakObjectPuppet

- (instancetype)initWithObject:(id)object {
    if (self = [super init]) {
        _object = object;
        if ([object isKindOfClass:self.class]) {
            NSLog(@"KSWeakObjectPuppet: ⚠️⚠️⚠️ 在初始化是传入的宿主对象的类型为傀儡对象的类型，这是不被建议使用的，可能会直接释放目标傀儡对象。");
        }
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _object;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (_object == nil) {
        NSLog(@"KSWeakObjectPuppet: ⚠️⚠️⚠️ 傀儡宿主的对象已经被释放， %@ 没有被真正的执行", NSStringFromSelector(invocation.selector));
    } else {
        [_object forwardInvocation:invocation];
    }
}

@end
