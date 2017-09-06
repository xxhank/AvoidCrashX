//
//  NSObject+AvoidCrash.m
//  AvoidCrash
//
//  Created by wangchao on 2017/9/6.
//  Copyright © 2017年 ibestv. All rights reserved.
//

#import "NSObject+AvoidCrash.h"

#define AvoidCrash_SWizzle(className, method) \
    do { \
        NSError*error = nil; \
        [NSClassFromString(className) jr_swizzleMethod:@selector(method) \
                                            withMethod:@selector(nty_##method) \
                                                 error:&error]; \
        if (error) {NSLog(@"%@", error);} \
    } while (0)

#define AvoidCrashAssert(condition, ...) \
    if (!(condition)) {SFLogError(__VA_ARGS__);}
// AvoidCrashAssert(condition, __VA_ARGS__);

#ifndef __FILENAME__
#define __FILENAME__ ({(strrchr(__FILE__, '/')?:(__FILE__ - 1)) + 1;})
#endif // ifndef __FILENAME__


#ifdef NSLogError
#define SFLogError NSLogError
#else // ifdef NSLogError
#define SFLogError(fmt, ...) \
    NSLog(@"\033[fg255,0,0;%s:%d %s> " fmt @"\033[;", \
    __FILENAME__, __LINE__, __FUNCTION__,##__VA_ARGS__)
#endif // ifdef NSLogError


@interface NSObject_AvoidCrash : NSObject
@end
@implementation NSObject_AvoidCrash
@end

@implementation NSObject (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AvoidCrash_SWizzle(@"NSObject", setNilValueForKey:);
        AvoidCrash_SWizzle(@"NSObject", valueForUndefinedKey:);
        AvoidCrash_SWizzle(@"NSObject", setValue: forUndefinedKey:);
    });
}

- (void)nty_setNilValueForKey:(NSString*)key {
    AvoidCrashAssert(NO,@"Attempt to set nil value for key:%@", key);
    // [self nty_setNilValueForKey:key];
}

- (id)nty_valueForUndefinedKey:(NSString*)key {
    AvoidCrashAssert(NO, @"Attempt to acess invalid key:%@", key);
    return nil;
    // return [self nty_valueForUndefinedKey:key];
}

- (void)nty_setValue:(id)value forUndefinedKey:(NSString*)key {
    AvoidCrashAssert(NO, @"Attempt to set value for invalid key:%@", key);
    // [self nty_setValue:value forUndefinedKey:key];
}
@end
@implementation NSArray (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AvoidCrash_SWizzle(@"__NSPlaceholderArray", initWithObjects: count:);
        AvoidCrash_SWizzle(@"__NSArrayI",           objectAtIndex:);
        AvoidCrash_SWizzle(@"NSArray",              arrayByAddingObject:);
    });
}

- (instancetype)nty_initWithObjects:(id _Nonnull const[])objects count:(NSUInteger)cnt {
    NSInteger index = 0;
    id        objs[cnt];
    for (NSInteger i = 0; i < cnt; ++i) {
        if (objects[i]) {
            objs[index++] = objects[i];
        }
    }
    return [self nty_initWithObjects:objs count:index];
}

- (id)nty_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self nty_objectAtIndex:index];
    }
    return nil;
}
- (NSArray*)nty_arrayByAddingObject:(id)anObject {
    if (!anObject) {
        AvoidCrashAssert(NO, @"attempt to append nil object");
        return [self copy];
    }
    return [self nty_arrayByAddingObject:anObject];
}
@end

@implementation NSMutableArray (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AvoidCrash_SWizzle(@"__NSArrayM", objectAtIndex:);
        AvoidCrash_SWizzle(@"__NSArrayM", insertObject: atIndex:);
        AvoidCrash_SWizzle(@"__NSArrayM", replaceObjectAtIndex: withObject:);
        AvoidCrash_SWizzle(@"__NSArrayM", removeObjectsInRange:);
    });
}

- (id)nty_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self nty_objectAtIndex:index];
    }
    return nil;
}

- (void)nty_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (!anObject) {AvoidCrashAssert(NO, @"");return;}
    if (index > self.count) {AvoidCrashAssert(NO, @"");return;}
    [self nty_insertObject:anObject atIndex:index];
}

- (void)nty_removeObjectsInRange:(NSRange)range {
    if (NSMaxRange(range) > self.count) {
        AvoidCrashAssert(NO, @"");
        return;
    }
    [self nty_removeObjectsInRange:range];
}

- (void)nty_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (index < self.count && anObject) {
        [self nty_replaceObjectAtIndex:index withObject:anObject];
    } else {
        if (!anObject) {
            AvoidCrashAssert(NO, @"NSMutableArray invalid args  nos_replaceObjectAtIndex:[%@] withObject:[%@]", @(index), anObject);
        }
        if (index >= self.count) {
            AvoidCrashAssert(NO, @"NSMutableArray  nos_replaceObjectAtIndex:[%@] withObject:[%@] out of bound:[%@]", @(index), anObject, @(self.count));
        }
    }
}
@end

@implementation NSDictionary (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AvoidCrash_SWizzle(@"__NSPlaceholderDictionary", initWithObjects: forKeys: count:);
    });
}
- (instancetype)nty_initWithObjects:(id _Nonnull const[])objects forKeys:(id<NSCopying> _Nonnull const[])keys count:(NSUInteger)cnt {
    NSInteger index = 0;
    id        ks[cnt];
    id        objs[cnt];
    for (NSInteger i = 0; i < cnt; ++i) {
        if (keys[i] && objects[i]) {
            ks[index]   = keys[i];
            objs[index] = objects[i];
            ++index;
        } else {
            AvoidCrashAssert(NO, @"NSDictionary invalid args  nos_dictionaryWithObject:[%@] forKey:[%@]", objects[i], keys[i]);
        }
    }
    return [self nty_initWithObjects:objs forKeys:ks count:index];
}
@end

@implementation NSMutableDictionary (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AvoidCrash_SWizzle(@"__NSDictionaryM", setObject: forKey:);
        AvoidCrash_SWizzle(@"__NSDictionaryM", removeObjectForKey:);
    });
}

- (void)nty_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!anObject) {
        AvoidCrashAssert(NO, @"");
        return;
    }
    if (!aKey) {
        AvoidCrashAssert(NO, @"");
        return;
    }
    [self nty_setObject:anObject forKey:aKey];
}
- (void)nty_removeObjectForKey:(id)aKey {
    if (!aKey) {
        AvoidCrashAssert(NO, @"");
        return;
    }
    [self nty_removeObjectForKey:aKey];
}
@end

@implementation NSString (AvoidCrash)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AvoidCrash_SWizzle(@"__NSCFConstantString", characterAtIndex:);
    });
}

- (unichar)nty_characterAtIndex:(NSUInteger)index {
    if (index >= self.length) {
        AvoidCrashAssert(NO, @"NSString: overflow %zd [0,%zd)", index, self.length);
        return 0;
    }
    return [self nty_characterAtIndex:index];
}
@end

@implementation NSMutableString (AvoidCrash)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AvoidCrash_SWizzle(@"__NSCFString", appendString:);
        AvoidCrash_SWizzle(@"__NSCFString", appendFormat:);
        AvoidCrash_SWizzle(@"__NSCFString", setString:);
        AvoidCrash_SWizzle(@"__NSCFString", insertString: atIndex:);
    });
}

- (void)nty_appendString:(NSString*)aString {
    if (!aString) {
        AvoidCrashAssert(NO,@"");
        return;
    }
    [self nty_appendString:aString];
}
- (void)nty_appendFormat:(NSString*)format, ... {
    if (!format) {
        return;
    }
    va_list   arguments;
    va_start(arguments, format);
    NSString *formatStr = [[NSString alloc] initWithFormat:format arguments:arguments];
    [self appendString:formatStr];
    va_end(arguments);
}

- (void)nty_setString:(NSString*)aString {
    if (!aString) {
        AvoidCrashAssert(NO, "NSMutableString: Attempt to set nil string");
        return;
    }
    [self nty_setString:aString];
}

- (void)nty_insertString:(NSString*)aString atIndex:(NSUInteger)loc {
    if (!aString) {
        AvoidCrashAssert(NO,@"");
        return;
    }
    if (loc > self.length) {
        AvoidCrashAssert(NO, @"");
        return;
    }

    [self nty_insertString:aString atIndex:loc];
}
@end
