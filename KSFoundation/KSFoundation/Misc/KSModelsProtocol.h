//
//  KSModelsProtocol.h
//  KSFoundation
//
//  Created by Kinsun on 2020/12/7.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KSEnModelsProtocol <NSObject>

@required
- (instancetype _Nonnull)initWithDictionary:(NSDictionary *_Nonnull)dictionary;

@end

@protocol KSEnModelsArrayProtocol <NSObject>

@required
+ (NSMutableArray <id>* _Nonnull)modelArrayFromDictionaryArray:(NSArray <NSDictionary <id<NSCopying>, id>*> *_Nonnull)dictionaryArray;

@end

@protocol KSDeModelsProtocol <NSObject>

@required
@property (nonatomic, readonly, nullable) NSDictionary *toDictionaryValue;

@end

@protocol KSEnJsonModelsProtocol <NSObject>

@required
- (instancetype _Nonnull)initWithJsonString:(NSString *_Nonnull)jsonString;

@end

@protocol KSDeJsonModelsProtocol <NSObject>

@required
@property (nonatomic, readonly, nullable) NSString *toJsonString;

@end
