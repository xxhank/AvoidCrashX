//
//  NSObject+NTYAvoidCrashNotUsed.m
//  AvoidCrash
//
//  Created by wangchao on 2017/9/6.
//  Copyright © 2017年 ibestv. All rights reserved.
//

#import "NSObject+NTYAvoidCrashNotUsed.h"

@implementation NSObject (NTYAvoidCrashNotUsed)

@end
#if 0
@implementation NSArray (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ACSwizzle(@"__NSPlaceholderArray",   initWithObjects: count:);

        ACSwizzle(@"__NSArrayI",             objectAtIndex:);
        ACSwizzle(@"__NSArray0",             objectAtIndex:);
        ACSwizzle(@"__NSSingleObjectArrayI", objectAtIndex:);

        ACSwizzle(@"NSArray",                arrayByAddingObject:);
        ACSwizzle(@"NSArray",                subarrayWithRange:);
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

- (id)nty_objectAtIndexedSubscript:(NSInteger)index {
    if (index < self.count) {
        return [self nty_objectAtIndexedSubscript:index];
    }
    ACAssert(NO, @"NSArray invalid index:[%@]", @(index));
    return nil;
}

- (NSArray*)nty_arrayByAddingObject:(id)anObject {
    if (!anObject) {
        ACAssert(NO, @"attempt to append nil object");
        return [self copy];
    }
    return [self nty_arrayByAddingObject:anObject];
}

- (NSArray*)nty_subarrayWithRange:(NSRange)range {
    if (range.location + range.length <= self.count) {
        return [self nty_subarrayWithRange:range];
    } else if (range.location < self.count) {
        return [self nty_subarrayWithRange:NSMakeRange(range.location, self.count - range.location)];
    }
    return nil;
}
@end

@implementation NSMutableArray (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ACSwizzle(@"__NSArrayM", objectAtIndex:);
        ACSwizzle(@"__NSArrayM", insertObject: atIndex:);
        ACSwizzle(@"__NSArrayM", replaceObjectAtIndex: withObject:);
        ACSwizzle(@"__NSArrayM", removeObjectsInRange:);
    });
}

- (id)nty_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self nty_objectAtIndex:index];
    }
    return nil;
}

- (void)nty_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (!anObject) {ACAssert(NO, @"");return;}
    if (index > self.count) {ACAssert(NO, @"");return;}
    [self nty_insertObject:anObject atIndex:index];
}

- (void)nty_removeObjectsInRange:(NSRange)range {
    if (NSMaxRange(range) > self.count) {
        ACAssert(NO, @"");
        return;
    }
    [self nty_removeObjectsInRange:range];
}

- (void)nty_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (index < self.count && anObject) {
        [self nty_replaceObjectAtIndex:index withObject:anObject];
    } else {
        if (!anObject) {
            ACAssert(NO, @"Invalid args replaceObjectAtIndex:[%@] withObject:[%@]", @(index), anObject);
        }
        if (index >= self.count) {
            ACAssert(NO, @"NSMutableArray  nty_replaceObjectAtIndex:[%@] withObject:[%@] out of bound:[%@]", @(index), anObject, @(self.count));
        }
    }
}
@end

@implementation NSDictionary (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ACSwizzle(@"__NSPlaceholderDictionary", initWithObjects: forKeys: count:);
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
            ACAssert(NO, @"Invalid args dictionaryWithObject:[%@] forKey:[%@]", objects[i], keys[i]);
        }
    }
    return [self nty_initWithObjects:objs forKeys:ks count:index];
}
@end

@implementation NSMutableDictionary (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ACSwizzle(@"__NSDictionaryM", setObject: forKey:);
        ACSwizzle(@"__NSDictionaryM", removeObjectForKey:);
    });
}

- (void)nty_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (!anObject) {
        ACAssert(NO, @"Attempt set nil object for %@", aKey);
        return;
    }
    if (!aKey) {
        ACAssert(NO, @"Attempt set %@ for nil key", anObject);
        return;
    }
    [self nty_setObject:anObject forKey:aKey];
}
- (void)nty_removeObjectForKey:(id)aKey {
    if (!aKey) {
        ACAssert(NO, @"");
        return;
    }
    [self nty_removeObjectForKey:aKey];
}
@end

@implementation NSString (AvoidCrash)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ACSwizzle(@"__NSCFConstantString", characterAtIndex:);
        ACSwizzle(@"__NSCFConstantString", initWithCString: encoding:);
        ACSwizzle(@"__NSCFConstantString", substringFromIndex:);
        ACSwizzle(@"__NSCFConstantString", substringToIndex:);
        ACSwizzle(@"__NSCFConstantString", substringWithRange:);
    });
}

- (nullable instancetype)nty_initWithCString:(const char*)nullTerminatedCString encoding:(NSStringEncoding)encoding {
    if (NULL != nullTerminatedCString) {
        return [self nty_initWithCString:nullTerminatedCString encoding:encoding];
    }
    ACAssert(NO, @"NSString invalid args nil cstring");
    return nil;
}

- (unichar)nty_characterAtIndex:(NSUInteger)index {
    if (index >= self.length) {
        ACAssert(NO, @"NSString: overflow %zd [0,%zd)", index, self.length);
        return 0;
    }
    return [self nty_characterAtIndex:index];
}

- (NSString*)nty_stringByAppendingString:(NSString*)aString {
    if (aString) {
        return [self nty_stringByAppendingString:aString];
    }
    return self;
}
- (NSString*)nty_substringFromIndex:(NSUInteger)from {
    if (from <= self.length) {
        return [self nty_substringFromIndex:from];
    }
    return nil;
}
- (NSString*)nty_substringToIndex:(NSUInteger)to {
    if (to <= self.length) {
        return [self nty_substringToIndex:to];
    }
    return self;
}
- (NSString*)nty_substringWithRange:(NSRange)range {
    if (range.location + range.length <= self.length) {
        return [self nty_substringWithRange:range];
    } else if (range.location < self.length) {
        return [self nty_substringWithRange:NSMakeRange(range.location, self.length - range.location)];
    }
    return nil;
}
@end

@implementation NSMutableString (AvoidCrash)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ACSwizzle(@"__NSCFString", substringFromIndex:);
        ACSwizzle(@"__NSCFString", substringToIndex:);
        ACSwizzle(@"__NSCFString", substringWithRange:);

        ACSwizzle(@"__NSCFString", appendString:);
        ACSwizzle(@"__NSCFString", appendFormat:);

        ACSwizzle(@"__NSCFString", setString:);
        ACSwizzle(@"__NSCFString", insertString: atIndex:);
    });
}

- (NSString*)nty_substringFromIndex:(NSUInteger)from {
    if (from <= self.length) {
        return [self nty_substringFromIndex:from];
    }
    return nil;
}
- (NSString*)nty_substringToIndex:(NSUInteger)to {
    if (to <= self.length) {
        return [self nty_substringToIndex:to];
    }
    return self;
}
- (NSString*)nty_substringWithRange:(NSRange)range {
    if (range.location + range.length <= self.length) {
        return [self nty_substringWithRange:range];
    } else if (range.location < self.length) {
        return [self nty_substringWithRange:NSMakeRange(range.location, self.length - range.location)];
    }
    return nil;
}

- (void)nty_appendString:(NSString*)aString {
    if (!aString) {
        ACAssert(NO,@"");
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
        ACAssert(NO, "NSMutableString: Attempt to set nil string");
        return;
    }
    [self nty_setString:aString];
}

- (void)nty_insertString:(NSString*)aString atIndex:(NSUInteger)loc {
    if (!aString) {
        ACAssert(NO,@"");
        return;
    }
    if (loc > self.length) {
        ACAssert(NO, @"");
        return;
    }

    [self nty_insertString:aString atIndex:loc];
}
@end


#pragma mark - NSMutableAttributedString
@implementation NSAttributedString (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ACSwizzle(@"NSConcreteAttributedString", initWithString: attributes:);
        ACSwizzle(@"NSConcreteAttributedString", attributedSubstringFromRange:);

        /* init方法 */
        //Class clazz = [[NSMutableAttributedString alloc] class];
        //[obj nty_swizzleInstanceMethod:@selector(initWithString:)
        //[obj nty_swizzleInstanceMethod:@selector(initWithString:attributes:)
        //

        /* 普通方法 */
        //clazz = [[[NSMutableAttributedString alloc] init] class];
        //[obj nty_swizzleInstanceMethod:@selector(attributedSubstringFromRange:)
        //
    });
}
- (instancetype)nty_initWithString:(NSString*)str attributes:(NSDictionary<NSString*,id>*)attrs {
    if (str) {
        return [self nty_initWithString:str attributes:attrs];
    }
    return nil;
}
- (NSAttributedString*)nty_attributedSubstringFromRange:(NSRange)range {
    if (range.location + range.length <= self.length) {
        return [self nty_attributedSubstringFromRange:range];
    } else if (range.location < self.length) {
        return [self nty_attributedSubstringFromRange:NSMakeRange(range.location, self.length - range.location)];
    }
    return nil;
}
@end
#pragma mark - NSMutableAttributedString
@implementation NSMutableAttributedString (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ACSwizzle(@"NSConcreteMutableAttributedString", initWithString: attributes:);
        ACSwizzle(@"NSConcreteMutableAttributedString", attributedSubstringFromRange:);
        /* init方法 */
        //Class clazz = [[NSMutableAttributedString alloc] class];
        //[obj nty_swizzleInstanceMethod:@selector(initWithString:)
        //[obj nty_swizzleInstanceMethod:@selector(initWithString:attributes:)
        //

        /* 普通方法 */
        //clazz = [[[NSMutableAttributedString alloc] init] class];
        //[obj nty_swizzleInstanceMethod:@selector(attributedSubstringFromRange:)
        //
    });
}


- (id)nty_initWithString:(NSString*)str attributes:(nullable NSDictionary*)attributes {
    if (str) {
        return [self nty_initWithString:str attributes:attributes];
    }
    return nil;
}
- (NSAttributedString*)nty_attributedSubstringFromRange:(NSRange)range {
    if (range.location + range.length <= self.length) {
        return [self nty_attributedSubstringFromRange:range];
    } else if (range.location < self.length) {
        return [self nty_attributedSubstringFromRange:NSMakeRange(range.location, self.length - range.location)];
    }
    return nil;
}
@end


#pragma mark - NSCache

@implementation NSCache (Safe)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ACSwizzle(@"NSCache", setObject: forKey:);
        ACSwizzle(@"NSCache", setObject: forKey: cost:);
    });
}
- (void)nty_setObject:(id)obj forKey:(id)key   // 0 cost
{
    if (obj && key) {
        [self nty_setObject:obj forKey:key];
    } else {
        ACAssert(NO, @"Invalid args setObject:[%@] forKey:[%@]", obj, key);
    }
}
- (void)nty_setObject:(id)obj forKey:(id)key cost:(NSUInteger)g {
    if (obj && key) {
        [self nty_setObject:obj forKey:key cost:g];
    } else {
        ACAssert(NO, @"Invalid args setObject:[%@] forKey:[%@] cost:[%@]", obj, key, @(g));
    }
}
@end
#endif // if 0
