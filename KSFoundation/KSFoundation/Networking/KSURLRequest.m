//
//  KSURLRequest.m
//  KSFoundation
//
//  Created by Kinsun on 2020/6/4.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSURLRequest.h"

@implementation KSURLRequest

- (instancetype)initWithURL:(NSURL *)URL method:(KSURLRequestMethod)method contentType:(KSURLRequestContentType)contentType query:(NSDictionary <NSString *, id> *)query body:(NSData *)body {
    if (query != nil && query.count > 0) {
        NSString *queryString = [KSURLRequest buildParameters:query];
        NSString *urlString = [NSString stringWithFormat:@"%@?%@", URL.absoluteString, queryString];
        URL = [NSURL URLWithString:urlString];
    }
    if (self = [super initWithURL:URL]) {
        _query = query.copy;
        _method = method;
        _contentType = contentType;
        switch (method) {
            case KSURLRequestMethodGET:
                self.HTTPMethod = @"GET";
                break;
            case KSURLRequestMethodPOST:
                self.HTTPMethod = @"POST";
                break;
            case KSURLRequestMethodDELETE:
                self.HTTPMethod = @"DELETE";
                break;
            case KSURLRequestMethodPUT:
                self.HTTPMethod = @"PUT";
                break;
            default:
                break;
        }
        [self setValue:@"max-age=2000000, no-cache, no-store" forHTTPHeaderField:@"Cache-Control"];
        [self setValue:KSURLRequest.nowUTCTime forHTTPHeaderField:@"If-Modified-Since"];
        if (body != nil) {
            switch (contentType) {
                case KSURLRequestContentTypeJSON:
                    [self setValue:@"utf-8" forHTTPHeaderField:@"Accept-Encoding"];
                    [self setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                    [self setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    break;
                case KSURLRequestContentTypeFormUrlencoded:
                    [self setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
                    [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                    break;
                case KSURLRequestContentTypeTextPlain:
                    [self setValue:@"utf-8" forHTTPHeaderField:@"Accept-Encoding"];
                    [self setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
                    break;
                case KSURLRequestContentTypeEventStream:
                    [self setValue:@"utf-8" forHTTPHeaderField:@"Accept-Encoding"];
                    [self setValue:@"text/event-stream; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
                    break;
                default:
                    break;
            }
            self.HTTPBody = body;
        }
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL method:(KSURLRequestMethod)method contentType:(KSURLRequestContentType)contentType query:(NSDictionary <NSString *, id> *)query params:(NSDictionary <NSString *, id> *)params {
    NSData *body = nil;
    if (params != nil && params.count > 0) {
        switch (contentType) {
            case KSURLRequestContentTypeJSON:
            case KSURLRequestContentTypeEventStream: {
                NSJSONWritingOptions options = 0;
                if (@available(iOS 11.0, *)) options = NSJSONWritingSortedKeys;
                body = [NSJSONSerialization dataWithJSONObject:params options:options error:nil];
            }
                break;
            case KSURLRequestContentTypeFormUrlencoded: {
                NSString *queryString = [KSURLRequest buildParameters:params];
                body = [queryString dataUsingEncoding:NSUTF8StringEncoding];
            }
                break;
            case KSURLRequestContentTypeTextPlain: {
                NSString *text = [params objectForKey:@"content"];
                if (text != nil && text.length > 0) {
                    body = [text dataUsingEncoding:NSUTF8StringEncoding];
                }
            }
                break;
            default:
                break;
        }
    }
    if (self = [self initWithURL:URL method:method contentType:contentType query:query body:body]) {
        _params = params;
    }
    return self;
}

+ (NSString *)buildParameters:(NSDictionary <NSString *, id> *)parameters {
    NSMutableArray<NSArray <NSString *> *> *components = [NSMutableArray array];
    NSMutableArray <NSString *> *keys = parameters.allKeys.mutableCopy;
    NSSortDescriptor *descripor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    [keys sortUsingDescriptors:@[descripor]];
    for (NSString *key in keys) {
        id value = [parameters objectForKey:key];
        [components addObjectsFromArray:[self queryComponentsWithKey:key value:value]];
    }
    NSMutableString *returnString = NSMutableString.string;
    NSUInteger lastIndex = components.count-1;
    [components enumerateObjectsUsingBlock:^(NSArray<NSString *> *obj, NSUInteger idx, BOOL *stop) {
        [returnString appendFormat:@"%@=%@", obj.firstObject, obj.lastObject];
        if (idx != lastIndex) [returnString appendString:@"&"];
    }];
    return [NSString stringWithString:returnString];
}

+ (NSArray<NSArray <NSString *> *> *)queryComponentsWithKey:(NSString *)key value:(id)value {
    NSMutableArray<NSArray <NSString *> *> *components = [NSMutableArray array];
    if ([value isKindOfClass:NSDictionary.class]) {
        NSDictionary <NSString *, id> *dictionary = value;
        [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *nestedKey, id obj, BOOL *stop) {
            [components addObjectsFromArray:[self queryComponentsWithKey:[NSString stringWithFormat:@"%@[%@]", key, nestedKey] value:obj]];
        }];
    } else if ([value isKindOfClass:NSArray.class]) {
        NSArray *array = value;
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [components addObjectsFromArray:[self queryComponentsWithKey:key value:obj]];
        }];
    } else {
        [components addObject:@[[self escapeOfString:key.description], [self escapeOfString:[value description]]]];
    }
    return components;
}

+ (NSString *)escapeOfString:(NSString *)string {
    static NSCharacterSet *_escapeSet = nil;
    if (_escapeSet == nil) {
        _escapeSet = [NSCharacterSet characterSetWithCharactersInString:@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| "].invertedSet;
    }
    return [string stringByAddingPercentEncodingWithAllowedCharacters:_escapeSet];
}

+ (NSString *)nowUTCTime {
    NSDateFormatter *dateFormatter = NSDateFormatter.alloc.init;
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    if (@available(iOS 13.0, *)) {
        return [dateFormatter stringFromDate:NSDate.now];
    } else {
        return [dateFormatter stringFromDate:NSDate.date];
    }
}

@end

@implementation KSURLRequest (Convenient)

- (instancetype)initWithURL:(NSURL *)URL jsonData:(NSData *)jsonData {
    return [self initWithURL:URL method:KSURLRequestMethodPOST contentType:KSURLRequestContentTypeJSON query:nil body:jsonData];
}

- (instancetype)initWithURL:(NSURL *)URL method:(KSURLRequestMethod)method contentType:(KSURLRequestContentType)contentType params:(NSDictionary <NSString *, id> *)params {
    if (method == KSURLRequestMethodGET || method == KSURLRequestMethodDELETE) {
        return [self initWithURL:URL method:method contentType:contentType query:params params:nil];
    } else {
        return [self initWithURL:URL method:method contentType:contentType query:nil params:params];
    }
}

- (instancetype)initWithURL:(NSURL *)URL method:(KSURLRequestMethod)method params:(NSDictionary <NSString *, id> *)params {
    return [self initWithURL:URL method:method contentType:KSURLRequestContentTypeJSON params:params];
}

@end
