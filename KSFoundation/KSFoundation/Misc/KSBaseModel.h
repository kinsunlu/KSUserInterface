//
//  KSBaseModel.h
//  KSFoundation
//
//  Created by Kinsun on 2021/4/14.
//  Copyright © 2021 Kinsun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSModelsProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSBaseModel : NSObject <KSDeModelsProtocol>

/// 注意！toDictionaryValue是懒加载生成值的，并且生成后会缓存值，如果中途值属性的值发生了变化
/// 一定要及时调用-resetToDictionaryValueCache，否则返回的字典值是不会更新的。
@property (nonatomic, strong, readonly) NSMutableDictionary <NSString *, id> *toDictionaryValue;

- (void)resetToDictionaryValueCache;

/// 不转换到toDictionaryValue的属性名单
@property (nonatomic, class, readonly) NSArray <NSString *> *blackList;

@end

NS_ASSUME_NONNULL_END
