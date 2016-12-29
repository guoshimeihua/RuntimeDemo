//
//  NSDictionary+NSRangeException.m
//  TestDemo
//
//  Created by Bruce on 16/12/22.
//  Copyright © 2016年 Bruce. All rights reserved.
//

#import "NSDictionary+NSRangeException.h"
#import "NSObject+Swizzling.h"
#import <objc/runtime.h>

@implementation NSDictionary (NSRangeException)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [objc_getClass("__NSDictionaryI") swizzleMethod:@selector(objectForKey:) swizzledSelector:@selector(replace_objectForKey:)];
            [objc_getClass("__NSDictionaryI") swizzleMethod:@selector(length) swizzledSelector:@selector(replace_length)];
        }
    });
}

- (id)replace_objectForKey:(NSString *)key {
    if ([self isKindOfClass:[NSDictionary class]]) {
        return [self replace_objectForKey:key];
    }
    return nil;
}

- (NSUInteger)replace_length {
    return 0;
}

@end
