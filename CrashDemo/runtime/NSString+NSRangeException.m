//
//  NSString+NSRangeException.m
//  TestDemo
//
//  Created by Bruce on 16/12/22.
//  Copyright © 2016年 Bruce. All rights reserved.
//

#import "NSString+NSRangeException.h"
#import "NSObject+Swizzling.h"
#import <objc/runtime.h>

@implementation NSString (NSRangeException)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [objc_getClass("__NSCFConstantString") swizzleMethod:@selector(substringToIndex:) swizzledSelector:@selector(replace_substringToIndex:)];
            [objc_getClass("__NSCFConstantString") swizzleMethod:@selector(objectForKeyedSubscript:) swizzledSelector:@selector(replace_objectForKeyedSubscript:)];
        }
    });
}

- (NSString *)replace_substringToIndex:(NSUInteger)to {
    if (to > self.length) {
        return nil;
    }
    
    return [self replace_substringToIndex:to];
}

- (id)replace_objectForKeyedSubscript:(NSString *)key {
    return nil;
}

@end
