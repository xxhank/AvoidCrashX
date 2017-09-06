//
//  NSObject+NTYAvoidCrashMRC.m
//  AvoidCrash
//
//  Created by wangchao on 2017/9/6.
//  Copyright © 2017年 ibestv. All rights reserved.
//

#import "NSObject+NTYAvoidCrashMRC.h"
#import <JRSwizzle/JRSwizzle.h>

#if __has_feature(objc_arc)
#error This file must be compiled with MRC. Use -fno-objc-arc flag.
#endif // if !__has_feature(objc_arc)

#define ACSwizzle(clazz, method) \
    do { \
        NSError*error = nil; \
        [clazz jr_swizzleMethod:@selector(method) \
                     withMethod:@selector(nty_##method) \
                          error:&error]; \
        if (error) {ACLogError(@"%@", error);} \
    } while (0)

#define ACAssert(condition, ...) \
    if (!(condition)) {ACLogError(__VA_ARGS__);}
// ACAssert(condition, __VA_ARGS__);

#ifndef __FILENAME__
#define __FILENAME__ ({(strrchr(__FILE__, '/')?:(__FILE__ - 1)) + 1;})
#endif // ifndef __FILENAME__


#ifdef NSLogError
#define ACLogError NSLogError
#else // ifdef NSLogError
#define ACLogError(fmt, ...) \
    NSLog(@"\033[fg255,0,0;%s:%d %s> " fmt @"\033[;", \
    __FILENAME__, __LINE__, __FUNCTION__,##__VA_ARGS__)
#endif // ifdef NSLogError

@interface NSObject_NTYAvoidCrashMRC : NSObject

@end

@implementation NSObject_NTYAvoidCrashMRC

@end

@implementation NSMutableArray (NTYAvoidCrashMRC)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray*obj = [[NSMutableArray alloc] init];
        Class clazz = [obj class];
        //对象方法 __NSArrayM 和 __NSArrayI 都有实现，都要swizz
        ACSwizzle(clazz,objectAtIndex:);
        ACSwizzle(clazz,objectAtIndexedSubscript:);

        clazz = NSClassFromString(@"__NSArrayM");
        ACSwizzle(clazz,objectAtIndex:);
        ACSwizzle(clazz,objectAtIndexedSubscript:);

        [obj release];
    });
}

- (id)nty_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self nty_objectAtIndex:index];
    }
    ACAssert(NO, @"NSArray invalid index:[%@]", @(index));
    return nil;
}

- (id)nty_objectAtIndexedSubscript:(NSInteger)index {
    if (index < self.count) {
        return [self nty_objectAtIndexedSubscript:index];
    }
    ACAssert(NO, @"NSArray invalid index:[%@]", @(index));
    return nil;
}
@end
