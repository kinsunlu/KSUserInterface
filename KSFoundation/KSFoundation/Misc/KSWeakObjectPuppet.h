//
//  KSWeakObjectPuppet.h
//  KSFoundation
//
//  Created by Kinsun on 2022/8/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 使用KSWeakObjectPuppet可将传入的对象（object）弱引用化，从而中断循环引用
/// eg. NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:KSWeak(self) selector:@selector(self中的目标方法) userInfo:nil repeats:YES];
/// timer中原本对对象是强引用，这样就可将强引用对象变为KSWeakObjectPuppet，KSWeakObjectPuppet再对self弱引用
/// 从而解决timer只有执行过下次后才释放self的问题。以此类推适用于所有想将强引用变为弱引用的场景
@interface KSWeakObjectPuppet : NSObject

@property (nonatomic, weak, readonly) id object;

- (instancetype)initWithObject:(id)object;

@end

static inline KSWeakObjectPuppet * KSWeak(id object) {
    return [KSWeakObjectPuppet.alloc initWithObject:object];
}

NS_ASSUME_NONNULL_END
