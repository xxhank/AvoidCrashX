//
//  NSObject+AvoidCrash.m
//  AvoidCrash
//
//  Created by wangchao on 2017/9/6.
//  Copyright © 2017年 ibestv. All rights reserved.
//

#import "NSObject+NTYAvoidCrash.h"
@import UIKit;
#import <objc/runtime.h>
#import <objc/message.h>

#import <JRSwizzle/JRSwizzle.h>

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

#define USE_SAFE_PROXY        1
#define USE_SAFE_PROXY_SHARED 0
#if USE_SAFE_PROXY
@interface NSSafeProxy : NSObject
- (instancetype)initWithSelector:(SEL)aSelector;
@end

id fakeIMP(id sender,SEL sel,...) {
    return nil;
}
@implementation NSSafeProxy
#if USE_SAFE_PROXY_SHARED
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static NSSafeProxy    *proxy;
    dispatch_once(&onceToken, ^{
        proxy = [[[self class] alloc] init];
    });
    return proxy;
}

- (void)traceNotExistSelector:(SEL)aSelector forClass:(Class)clazz {
    ACAssert(NO, @"[%@ %@]", NSStringFromClass(clazz), NSStringFromSelector(aSelector));
    if (![self respondsToSelector:aSelector]) {
        BOOL successed = class_addMethod([self class], aSelector, (IMP)fakeIMP, NULL);
        if (successed) {}
    }
}
#else // if USE_SAFE_PROXY_SHARED
- (instancetype)initWithSelector:(SEL)aSelector {
    self = [super init];
    if (self) {
        if (class_addMethod([self class], aSelector, (IMP)fakeIMP, NULL)) {
            // NSLog(@"add Fake Selector:[instance %@]",NSStringFromSelector(aSelector));
        }
    }
    return self;
}
#endif // if USE_SAFE_PROXY_SHARED
@end
#endif // if USE_SAFE_PROXY


@implementation NSObject (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = NSClassFromString(@"NSObject");
        ACSwizzle(clazz, setNilValueForKey:);
        ACSwizzle(clazz, valueForUndefinedKey:);
        ACSwizzle(clazz, setValue: forUndefinedKey:);
   #if USE_SAFE_PROXY
        ACSwizzle(clazz, forwardingTargetForSelector:);
   #else // if 0
        ACSwizzle(clazz, methodSignatureForSelector:);
        ACSwizzle(clazz, forwardInvocation:);
   #endif // if 0
    });
}

- (void)nty_setNilValueForKey:(NSString*)key {
    ACAssert(NO,@"Attempt to set nil value for key:%@", key);
    // [self nty_setNilValueForKey:key];
}

- (id)nty_valueForUndefinedKey:(NSString*)key {
    ACAssert(NO, @"Attempt to acess invalid key:%@", key);
    return nil;
    // return [self nty_valueForUndefinedKey:key];
}

- (void)nty_setValue:(id)value forUndefinedKey:(NSString*)key {
    ACAssert(NO, @"Attempt to set value for invalid key:%@", key);
    // [self nty_setValue:value forUndefinedKey:key];
}

#if USE_SAFE_PROXY
- (id)nty_forwardingTargetForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
    if ([self respondsToSelector:aSelector] || signature) {
        return [self nty_forwardingTargetForSelector:aSelector];
    }
   #if USE_SAFE_PROXY_SHARED
    NSSafeProxy *proxy = [NSSafeProxy shared];
    [proxy traceNotExistSelector:aSelector forClass:[self class]];
    return proxy;
   #else // if USE_SAFE_PROXY_SHARED
    ACAssert(NO, @"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(aSelector));
    return [[NSSafeProxy alloc] initWithSelector:aSelector];
   #endif // if USE_SAFE_PROXY_SHARED
}
#else // if 0
- (NSMethodSignature*)nty_methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *signature = [self nty_methodSignatureForSelector:aSelector];
    if (signature) {
        return signature;
    }
    ACAssert(NO, @"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(aSelector));
    return [NSMethodSignature signatureWithObjCTypes:@encode(void)];
}
- (void)nty_forwardInvocation:(NSInvocation*)anInvocation {
    NSUInteger returnLength = [[anInvocation methodSignature] methodReturnLength];
    if (!returnLength) {
        return;// nothing to do
    }

    // set return value to all zero bits
    char buffer[returnLength];
    memset(buffer, 0, returnLength);
    [anInvocation setReturnValue:buffer];
}
#endif // if USE_SAFE_PROXY
@end

#pragma mark - NSString
@implementation NSString (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 类方法不用在NSMutableString里再swizz一次 */
        Class clazz = [NSString class];
        // ACSwizzle(clazz, stringWithUTF8String:);
        // ACSwizzle(clazz, stringWithCString: encoding:);

        /* init方法 */
        clazz = [[NSString alloc] class]; //NSPlaceholderString
        ACSwizzle(clazz,initWithCString: encoding:);
        ACSwizzle(clazz,initWithString:);
        ACSwizzle(clazz,initWithUTF8String:);
        ACSwizzle(clazz,initWithCharacters: length:);
        ACSwizzle(clazz,initWithFormat: arguments:);
        ACSwizzle(clazz,initWithFormat:);
        ACSwizzle(clazz,initWithBytes: length: encoding:);
        ACSwizzle(clazz,initWithData: encoding:);


        /* 普通方法 */
        clazz = [[[NSString alloc] init] class];
        ACSwizzle(clazz, characterAtIndex:);
        ACSwizzle(clazz, stringByAppendingString:);
        ACSwizzle(clazz, substringFromIndex:);
        ACSwizzle(clazz, substringToIndex:);
        ACSwizzle(clazz, substringWithRange:);
        ACSwizzle(clazz, getCharacters: range:);
        ACSwizzle(clazz, containsString:);
        ACSwizzle(clazz, rangeOfString: options: range:);
        ACSwizzle(clazz, rangeOfCharacterFromSet: options: range:);
        ACSwizzle(clazz, stringByTrimmingCharactersInSet:);
        ACSwizzle(clazz, stringByReplacingOccurrencesOfString: withString:);
        ACSwizzle(clazz, stringByReplacingCharactersInRange: withString:);

        clazz = NSClassFromString(@"__NSCFString");
        ACSwizzle(clazz, characterAtIndex:);
        ACSwizzle(clazz, stringByAppendingString:);
        ACSwizzle(clazz, substringFromIndex:);
        ACSwizzle(clazz, substringToIndex:);
        ACSwizzle(clazz, substringWithRange:);
        ACSwizzle(clazz, getCharacters: range:);
        ACSwizzle(clazz, containsString:);
        ACSwizzle(clazz, rangeOfString: options: range:);
        ACSwizzle(clazz, rangeOfCharacterFromSet: options: range:);
        ACSwizzle(clazz, stringByTrimmingCharactersInSet:);
        ACSwizzle(clazz, stringByReplacingOccurrencesOfString: withString:);
        ACSwizzle(clazz, stringByReplacingCharactersInRange: withString:);
    });
}

- (NSString*)nty_stringByTrimmingCharactersInSet:(NSCharacterSet*)set {
    if (!set) {
        ACAssert(NO, @"nil argument");
        return nil;
    }
    return [self nty_stringByTrimmingCharactersInSet:set];
}
- (NSString*)nty_stringByReplacingOccurrencesOfString:(NSString*)target withString:(NSString*)replacement {
    if (!target) {
        ACAssert(NO, @"nil argument");
        return nil;
    }

    if (!replacement) {
        ACAssert(NO, @"nil argument");
        return nil;
    }
    return [self nty_stringByReplacingOccurrencesOfString:target withString:replacement];
}
- (NSString*)nty_stringByReplacingCharactersInRange:(NSRange)range withString:(NSString*)replacement {
    if (!replacement) {
        ACAssert(NO, @"nil argument");
        return nil;
    }
    NSRange intersection = NSMakeRange(0, 0);
    if (range.location + range.length <= self.length) {
        intersection = range;
        return [self nty_stringByReplacingCharactersInRange:intersection withString:replacement];
    } else if (range.location < self.length) {
        intersection = NSMakeRange(range.location, self.length - range.location);
        return [self nty_stringByReplacingCharactersInRange:intersection withString:replacement];
    } else {
        ACAssert(NO, @"overflow %@ in [0, %zd]", NSStringFromRange(range), self.length);
        return nil;
    }
}

- (instancetype)nty_initWithFormat:(NSString*)format, ... {
    if (!format) {
        ACAssert(NO, @"nil argument");
        return nil;
    }
    va_list   arguments;
    va_start(arguments, format);
    NSString *result = [self initWithFormat:format arguments:arguments];
    va_end(arguments);

    return result;
}

- (instancetype)nty_initWithFormat:(NSString*)format arguments:(va_list)argList {
    if (!format) {
        ACAssert(NO, @"nil format argument");
        return nil;
    }

    if (!argList) {
        ACAssert(NO, @"nil argList argument");
        return nil;
    }
    return [self nty_initWithFormat:format arguments:argList];
}

- (instancetype)nty_initWithBytes:(const void*)bytes length:(NSUInteger)len encoding:(NSStringEncoding)encoding {
    if (!bytes) {
        ACAssert(NO, @"nil bytes argument");
        return nil;
    }
    return [self nty_initWithBytes:bytes length:len encoding:encoding];
}

- (instancetype)nty_initWithData:(NSData*)data encoding:(NSStringEncoding)encoding {
    if (!data) {
        ACAssert(NO, @"nil data argument");
        return nil;
    }
    return [self nty_initWithData:data encoding:encoding];
}

- (instancetype)nty_initWithString:(NSString*)aString {
    if (NULL != aString) {
        return [self nty_initWithString:aString];
    }
    ACAssert(NO, @"nil argument");
    return nil;
}

- (instancetype)nty_initWithUTF8String:(const char*)nullTerminatedCString {
    if (NULL != nullTerminatedCString) {
        return [self nty_initWithUTF8String:nullTerminatedCString];
    }
    ACAssert(NO, @"nil argument");
    return nil;
}

- (instancetype)nty_initWithCharacters:(const unichar*)characters length:(NSUInteger)length {
    if (!characters) {
        ACAssert(NO, @"nil argument");
        return nil;
    }

    return [self nty_initWithCharacters:characters length:length];
}

- (nullable instancetype)nty_initWithCString:(const char*)nullTerminatedCString encoding:(NSStringEncoding)encoding {
    if (NULL != nullTerminatedCString) {
        return [self nty_initWithCString:nullTerminatedCString encoding:encoding];
    }
    ACAssert(NO, @"nil argument");
    return nil;
}

- (NSString*)nty_stringByAppendingString:(NSString*)aString {
    if (aString) {
        return [self nty_stringByAppendingString:aString];
    }
    ACAssert(NO, @"nil argument");
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

- (unichar)nty_characterAtIndex:(NSUInteger)index {
    if (index < self.length) {
        return [self nty_characterAtIndex:index];
    }
    ACAssert(NO, @"overflow %zd in [0,%zd)", index, self.length);
    return 0;
}

- (void)nty_getCharacters:(unichar*)buffer range:(NSRange)range {
    if (!buffer) {
        ACAssert(NO, @"nil buffer arguments");
        return;
    }

    if (range.location + range.length <= self.length) {
        [self nty_getCharacters:buffer range:range];
    } else if (range.location < self.length) {
        [self nty_getCharacters:buffer range:
         NSMakeRange(range.location, self.length - range.location)];
    } else {
        ACAssert(NO, @"overflow %@ in [0, %zd]", NSStringFromRange(range), self.length);
    }
}

- (BOOL)nty_containsString:(NSString*)str {
    if (!str) {
        ACAssert(NO, @"nil arguments");
        return nil;
    }
    return [self nty_containsString:str];
}

- (NSRange)nty_rangeOfString:(NSString*)searchString options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToSearch {
    if (!searchString) {
        ACAssert(NO, @"nil arguments");
        return NSMakeRange(0, 0);
    }

    if (rangeOfReceiverToSearch.location + rangeOfReceiverToSearch.length <= self.length) {
        return [self nty_rangeOfString:searchString options:mask range:rangeOfReceiverToSearch];
    } else if (rangeOfReceiverToSearch.location < self.length) {
        return [self nty_rangeOfString:searchString options:mask range:
                NSMakeRange(rangeOfReceiverToSearch.location, self.length - rangeOfReceiverToSearch.location)];
    } else {
        ACAssert(NO, @"overflow %@ in [0, %zd]", NSStringFromRange(rangeOfReceiverToSearch), self.length);
        return NSMakeRange(0, 0);
    }
}

- (NSRange)nty_rangeOfCharacterFromSet:(NSCharacterSet*)searchSet options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToSearch {
    if (!searchSet) {
        ACAssert(NO, @"nil arguments");
        return NSMakeRange(0, 0);
    }

    if (rangeOfReceiverToSearch.location + rangeOfReceiverToSearch.length <= self.length) {
        return [self nty_rangeOfCharacterFromSet:searchSet options:mask range:rangeOfReceiverToSearch];
    } else if (rangeOfReceiverToSearch.location < self.length) {
        return [self nty_rangeOfCharacterFromSet:searchSet options:mask range:
                NSMakeRange(rangeOfReceiverToSearch.location, self.length - rangeOfReceiverToSearch.location)];
    } else {
        ACAssert(NO, @"overflow %@ in [0, %zd]", NSStringFromRange(rangeOfReceiverToSearch), self.length);
        return NSMakeRange(0, 0);
    }
}
@end

@implementation NSMutableString (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* init方法 */
        Class clazz = [[NSMutableString alloc] class]; //NSPlaceholderMutableString
        ACSwizzle(clazz, initWithCString: encoding:);
        ACSwizzle(clazz, appendString:);
        ACSwizzle(clazz, appendFormat:);
        ACSwizzle(clazz, insertString: atIndex:);
        ACSwizzle(clazz, deleteCharactersInRange:);
        ACSwizzle(clazz, stringByAppendingString:);
        ACSwizzle(clazz, substringFromIndex:);
        ACSwizzle(clazz, substringToIndex:);
        ACSwizzle(clazz, substringWithRange:);

        /* 普通方法 */
        clazz = [[[NSMutableString alloc] init] class];
        ACSwizzle(clazz, appendString:);
        ACSwizzle(clazz, appendFormat:);
        ACSwizzle(clazz, insertString: atIndex:);
        ACSwizzle(clazz, deleteCharactersInRange:);
        ACSwizzle(clazz, stringByAppendingString:);
        ACSwizzle(clazz, substringFromIndex:);
        ACSwizzle(clazz, substringToIndex:);
        ACSwizzle(clazz, substringWithRange:);
        ACSwizzle(clazz, setString:);

//        clazz = NSClassFromString(@"__NSCFString");
//        ACSwizzle(clazz, characterAtIndex:);
//        ACSwizzle(clazz, stringByAppendingString:);
//        ACSwizzle(clazz, substringFromIndex:);
//        ACSwizzle(clazz, substringToIndex:);
//        ACSwizzle(clazz, substringWithRange:);
//        ACSwizzle(clazz, getCharacters: range:);
//        ACSwizzle(clazz, containsString:);
//        ACSwizzle(clazz, rangeOfString: options: range:);
//        ACSwizzle(clazz, rangeOfCharacterFromSet: options: range:);
//        ACSwizzle(clazz, stringByTrimmingCharactersInSet:);
//        ACSwizzle(clazz, stringByReplacingOccurrencesOfString: withString:);
//        ACSwizzle(clazz, stringByReplacingCharactersInRange: withString:);
    });
}
- (nullable instancetype)nty_initWithCString:(const char*)nullTerminatedCString encoding:(NSStringEncoding)encoding {
    if (NULL != nullTerminatedCString) {
        return [self nty_initWithCString:nullTerminatedCString encoding:encoding];
    }
    ACAssert(NO, @"Invalid args initWithCString nil cstring");
    return nil;
}
- (void)nty_setString:(NSString*)aString {
    if (aString) {
        [self nty_setString:aString];
    } else {
        ACAssert(NO, @"Invalid args setString:[%@]", aString);
    }
}
- (void)nty_appendString:(NSString*)aString {
    if (aString) {
        [self nty_appendString:aString];
    } else {
        ACAssert(NO, @"Invalid args appendString:[%@]", aString);
    }
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

- (void)nty_insertString:(NSString*)aString atIndex:(NSUInteger)loc {
    if (aString && loc <= self.length) {
        [self nty_insertString:aString atIndex:loc];
    } else {
        ACAssert(NO, @"Invalid args insertString:[%@] atIndex:[%@]", aString, @(loc));
    }
}
- (void)nty_deleteCharactersInRange:(NSRange)range {
    if (range.location + range.length <= self.length) {
        [self nty_deleteCharactersInRange:range];
    } else {
        ACAssert(NO, @"Invalid args deleteCharactersInRange:[%@]", NSStringFromRange(range));
    }
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

#pragma mark - NSAttributedString
@implementation NSAttributedString (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* init方法 */
        Class clazz = [[NSAttributedString alloc] class];
        ACSwizzle(clazz,initWithString:);


        /* 普通方法 */
        clazz = [[[NSAttributedString alloc] init] class];
        ACSwizzle(clazz,attributedSubstringFromRange:);
    });
}
- (id)nty_initWithString:(NSString*)str {
    if (str) {
        return [self nty_initWithString:str];
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
        /* init方法 */
        Class clazz = [[NSMutableAttributedString alloc] class];
        ACSwizzle(clazz,initWithString:);
        ACSwizzle(clazz,initWithString: attributes:);


        /* 普通方法 */
        clazz = [[[NSMutableAttributedString alloc] init] class];
        ACSwizzle(clazz,attributedSubstringFromRange:);
        ACSwizzle(clazz,addAttribute: value: range:);
        ACSwizzle(clazz,addAttributes: range:);
        ACSwizzle(clazz,setAttributes: range:);
        ACSwizzle(clazz,removeAttribute: range:);
        ACSwizzle(clazz,deleteCharactersInRange:);
        ACSwizzle(clazz,replaceCharactersInRange: withString:);
        ACSwizzle(clazz,replaceCharactersInRange: withAttributedString:);
    });
}
- (id)nty_initWithString:(NSString*)str {
    if (str) {
        return [self nty_initWithString:str];
    }
    return nil;
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
- (void)nty_addAttribute:(id)name value:(id)value range:(NSRange)range {
    if (!range.length) {
        [self nty_addAttribute:name value:value range:range];
    } else if (value) {
        if (range.location + range.length <= self.length) {
            [self nty_addAttribute:name value:value range:range];
        } else if (range.location < self.length) {
            [self nty_addAttribute:name value:value range:NSMakeRange(range.location, self.length - range.location)];
        }
    } else {
        ACAssert(NO, @"nty_addAttribute:value:range: value is nil");
    }
}
- (void)nty_addAttributes:(NSDictionary<NSString*,id>*)attrs range:(NSRange)range {
    if (!range.length) {
        [self nty_addAttributes:attrs range:range];
    } else if (attrs) {
        if (range.location + range.length <= self.length) {
            [self nty_addAttributes:attrs range:range];
        } else if (range.location < self.length) {
            [self nty_addAttributes:attrs range:NSMakeRange(range.location, self.length - range.location)];
        }
    } else {
        ACAssert(NO, @"nty_addAttributes:range: attrs is nil");
    }
}
- (void)nty_setAttributes:(NSDictionary<NSString*,id>*)attrs range:(NSRange)range {
    if (!range.length) {
        [self nty_setAttributes:attrs range:range];
    } else if (attrs) {
        if (range.location + range.length <= self.length) {
            [self nty_setAttributes:attrs range:range];
        } else if (range.location < self.length) {
            [self nty_setAttributes:attrs range:NSMakeRange(range.location, self.length - range.location)];
        }
    } else {
        ACAssert(NO, @"nty_setAttributes:range:  attrs is nil");
    }
}
- (void)nty_removeAttribute:(id)name range:(NSRange)range {
    if (!range.length) {
        [self nty_removeAttribute:name range:range];
    } else if (name) {
        if (range.location + range.length <= self.length) {
            [self nty_removeAttribute:name range:range];
        } else if (range.location < self.length) {
            [self nty_removeAttribute:name range:NSMakeRange(range.location, self.length - range.location)];
        }
    } else {
        ACAssert(NO, @"nty_removeAttribute:range:  name is nil");
    }
}
- (void)nty_deleteCharactersInRange:(NSRange)range {
    if (range.location + range.length <= self.length) {
        [self nty_deleteCharactersInRange:range];
    } else if (range.location < self.length) {
        [self nty_deleteCharactersInRange:NSMakeRange(range.location, self.length - range.location)];
    }
}
- (void)nty_replaceCharactersInRange:(NSRange)range withString:(NSString*)str {
    if (str) {
        if (range.location + range.length <= self.length) {
            [self nty_replaceCharactersInRange:range withString:str];
        } else if (range.location < self.length) {
            [self nty_replaceCharactersInRange:NSMakeRange(range.location, self.length - range.location) withString:str];
        }
    } else {
        ACAssert(NO, @"nty_replaceCharactersInRange:withString:  str is nil");
    }
}
- (void)nty_replaceCharactersInRange:(NSRange)range withAttributedString:(NSString*)str {
    if (str) {
        if (range.location + range.length <= self.length) {
            [self nty_replaceCharactersInRange:range withAttributedString:str];
        } else if (range.location < self.length) {
            [self nty_replaceCharactersInRange:NSMakeRange(range.location, self.length - range.location) withAttributedString:str];
        }
    } else {
        ACAssert(NO, @"nty_replaceCharactersInRange:withString:  str is nil");
    }
}
@end

#pragma mark - NSArray
@implementation NSArray (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 类方法不用在NSMutableArray里再swizz一次 */
        //ACSwizzle(@"y",arrayWithObject:);
        // ACSwizzle(@"y",arrayWithObjects: count:);

        /* 数组有内容obj类型才是__NSArrayI */
        Class clazz = [[[NSArray alloc] initWithObjects:@0, @1, nil] class];
        ACSwizzle(clazz, initWithObjects: count:);
        ACSwizzle(clazz, objectAtIndex:);
        ACSwizzle(clazz, subarrayWithRange:);
        ACSwizzle(clazz, objectAtIndexedSubscript:);

        clazz = NSClassFromString(@"__NSPlaceholderArray");
        ACSwizzle(clazz, initWithObjects: count:);

        clazz = NSClassFromString(@"NSArray");
        ACSwizzle(clazz, arrayByAddingObject:);

        /* iOS10 以上，单个内容类型是__NSArraySingleObjectI */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
            clazz = [[[NSArray alloc] initWithObjects:@0, nil] class];
            ACSwizzle(clazz, initWithObjects: count:);
            ACSwizzle(clazz, objectAtIndex:);
            ACSwizzle(clazz, subarrayWithRange:);
            ACSwizzle(clazz, objectAtIndexedSubscript:);
        }

        /* iOS9 以上，没内容类型是__NSArray0 */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            clazz = [[[NSArray alloc] init] class];
            ACSwizzle(clazz, initWithObjects: count:);
            ACSwizzle(clazz, objectAtIndex:);
            ACSwizzle(clazz, subarrayWithRange:);
            ACSwizzle(clazz, objectAtIndexedSubscript:);
        }
    });
}

- (instancetype)nty_initWithObjects:(const id[])objects count:(NSUInteger)cnt {
    NSInteger index = 0;
    id        objs[cnt];
    for (NSInteger i = 0; i < cnt; ++i) {
        if (objects[i]) {
            objs[index++] = objects[i];
        }
    }
    return [self nty_initWithObjects:objs count:index];
}

//+ (instancetype)nty_arrayWithObject:(id)anObject {
//    if (anObject) {
//        return [self nty_arrayWithObject:anObject];
//    }
//    ACAssert(NO, @"Invalid args arrayWithObject:[%@]", anObject);
//    return nil;
//}
/* __NSArray0 没有元素，也不可以变 */
- (id)nty_objectAtIndex0:(NSUInteger)index {
    ACAssert(NO, @"NSArray invalid index:[%@]", @(index));
    return nil;
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
        Class clazz = [[[NSMutableArray alloc] init] class];
        //对象方法 __NSArrayM 和 __NSArrayI 都有实现，都要swizz
        ACSwizzle(clazz,objectAtIndex:);
        ACSwizzle(clazz,objectAtIndexedSubscript:);

        ACSwizzle(clazz,addObject:);
        ACSwizzle(clazz,insertObject: atIndex:);
        ACSwizzle(clazz,removeObjectAtIndex:);
        ACSwizzle(clazz,replaceObjectAtIndex: withObject:);
        ACSwizzle(clazz,removeObjectsInRange:);
        ACSwizzle(clazz,subarrayWithRange:);
    });
}
- (void)nty_addObject:(id)anObject {
    if (anObject) {
        [self nty_addObject:anObject];
    } else {
        ACAssert(NO, @"Invalid args addObject:[%@]", anObject);
    }
}

#if 0 // 需要采用MRC的方式
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
#endif // if 0

- (void)nty_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (anObject && index <= self.count) {
        [self nty_insertObject:anObject atIndex:index];
    } else {
        if (!anObject) {
            ACAssert(NO, @"Invalid args insertObject:[%@] atIndex:[%@]", anObject, @(index));
        }
        if (index > self.count) {
            ACAssert(NO, @"NSMutableArray nty_insertObject[%@] atIndex:[%@] out of bound:[%@]", anObject, @(index), @(self.count));
        }
    }
}

- (void)nty_removeObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        [self nty_removeObjectAtIndex:index];
    } else {
        ACAssert(NO, @"NSMutableArray nty_removeObjectAtIndex:[%@] out of bound:[%@]", @(index), @(self.count));
    }
}

- (void)nty_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (index < self.count && anObject) {
        [self nty_replaceObjectAtIndex:index withObject:anObject];
    } else {
        if (!anObject) {
            ACAssert(NO, @"Invalid args replaceObjectAtIndex:[%@] withObject:[%@]", @(index), anObject);
        }
        if (index >= self.count) {
            ACAssert(NO, @"NSMutableArray nty_replaceObjectAtIndex:[%@] withObject:[%@] out of bound:[%@]", @(index), anObject, @(self.count));
        }
    }
}

- (void)nty_removeObjectsInRange:(NSRange)range {
    if (range.location + range.length <= self.count) {
        [self nty_removeObjectsInRange:range];
    } else {
        ACAssert(NO, @"Invalid args removeObjectsInRange:[%@]", NSStringFromRange(range));
    }
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

#pragma mark - NSDictionary
@implementation NSDictionary (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 类方法 */

        /* 数组有内容obj类型才是__NSDictionaryI */
        Class clazz = [[[NSDictionary alloc] initWithObjectsAndKeys:@0, @0, @0, @0, nil] class];
        ACSwizzle(clazz, objectForKey:);

        clazz = NSClassFromString(@"__NSPlaceholderDictionary");
        ACSwizzle(clazz, initWithObjects: forKeys: count:);

        /* iOS10 以上，单个内容类型是__NSArraySingleEntryDictionaryI */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
            clazz = [[[NSDictionary alloc] initWithObjectsAndKeys:@0, @0, nil] class];
            ACSwizzle(clazz,objectForKey:);
        }

        /* iOS9 以上，没内容类型是__NSDictionary0 */
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            clazz = [[[NSDictionary alloc] init] class];
            ACSwizzle(clazz,objectForKey:);
        }
    });
}

- (instancetype)nty_initWithObjects:(const id[])objects forKeys:(const id[])keys count:(NSUInteger)cnt {
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
- (id)nty_objectForKey:(id)aKey {
    if (aKey) {
        return [self nty_objectForKey:aKey];
    }
    return nil;
}

@end

@implementation NSMutableDictionary (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = [[[NSMutableDictionary alloc] init] class];
        ACSwizzle(clazz,objectForKey:);
        ACSwizzle(clazz,setObject: forKey:);
        ACSwizzle(clazz,removeObjectForKey:);
    });
}
- (id)nty_objectForKey:(id)aKey {
    if (aKey) {
        return [self nty_objectForKey:aKey];
    }
    return nil;
}
- (void)nty_setObject:(id)anObject forKey:(id)aKey {
    if (anObject && aKey) {
        [self nty_setObject:anObject forKey:aKey];
    } else {
        ACAssert(NO, @"Invalid args setObject:[%@] forKey:[%@]", anObject, aKey);
    }
}

- (void)nty_removeObjectForKey:(id)aKey {
    if (aKey) {
        [self nty_removeObjectForKey:aKey];
    } else {
        ACAssert(NO, @"Invalid args removeObjectForKey:[%@]", aKey);
    }
}

@end

#pragma mark - NSSet
@implementation NSSet (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 类方法 */
        // ACSwizzle(@"t",setWithObject:);
    });
}
+ (instancetype)nty_setWithObject:(id)object {
    if (object) {
        return [self nty_setWithObject:object];
    }
    ACAssert(NO, @"Invalid args setWithObject:[%@]", object);
    return nil;
}
@end

@implementation NSMutableSet (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 普通方法 */
        Class clazz = [[NSMutableSet setWithObjects:@0, nil] class];
        ACSwizzle(clazz,addObject:);
        ACSwizzle(clazz,removeObject:);
    });
}
- (void)nty_addObject:(id)object {
    if (object) {
        [self nty_addObject:object];
    } else {
        ACAssert(NO, @"Invalid args addObject[%@]", object);
    }
}

- (void)nty_removeObject:(id)object {
    if (object) {
        [self nty_removeObject:object];
    } else {
        ACAssert(NO, @"Invalid args removeObject[%@]", object);
    }
}
@end

#pragma mark - NSOrderedSet
@implementation NSOrderedSet (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 类方法 */
        // ACSwizzle(@"t",orderedSetWithObject:);

        /* init方法:[NSOrderedSet alloc] 和 [NSMutableOrderedSet alloc] 返回的类是一样   */
        Class clazz = [[NSOrderedSet alloc] class];
        ACSwizzle(clazz,initWithObject:);


        /* 普通方法 */
        clazz = [[NSOrderedSet orderedSetWithObjects:@0, nil] class];
        ACSwizzle(clazz,objectAtIndex:);
    });
}
+ (instancetype)nty_orderedSetWithObject:(id)object {
    if (object) {
        return [self nty_orderedSetWithObject:object];
    }
    ACAssert(NO, @"Invalid args orderedSetWithObject:[%@]", object);
    return nil;
}
- (instancetype)nty_initWithObject:(id)object {
    if (object) {
        return [self nty_initWithObject:object];
    }
    ACAssert(NO, @"Invalid args initWithObject:[%@]", object);
    return nil;
}
- (id)nty_objectAtIndex:(NSUInteger)idx {
    if (idx < self.count) {
        return [self nty_objectAtIndex:idx];
    }
    return nil;
}
@end

@implementation NSMutableOrderedSet (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /* 普通方法 */
        Class clazz = [[NSMutableOrderedSet orderedSetWithObjects:@0, nil] class];
        ACSwizzle(clazz,objectAtIndex:);
        ACSwizzle(clazz,addObject:);
        ACSwizzle(clazz,removeObjectAtIndex:);
        ACSwizzle(clazz,insertObject: atIndex:);
        ACSwizzle(clazz,replaceObjectAtIndex: withObject:);
    });
}
- (id)nty_objectAtIndex:(NSUInteger)idx {
    if (idx < self.count) {
        return [self nty_objectAtIndex:idx];
    }
    return nil;
}
- (void)nty_addObject:(id)object {
    if (object) {
        [self nty_addObject:object];
    } else {
        ACAssert(NO, @"Invalid args addObject:[%@]", object);
    }
}
- (void)nty_insertObject:(id)object atIndex:(NSUInteger)idx {
    if (object && idx <= self.count) {
        [self nty_insertObject:object atIndex:idx];
    } else {
        ACAssert(NO, @"Invalid args insertObject:[%@] atIndex:[%@]", object, @(idx));
    }
}
- (void)nty_removeObjectAtIndex:(NSUInteger)idx {
    if (idx < self.count) {
        [self nty_removeObjectAtIndex:idx];
    } else {
        ACAssert(NO, @"Invalid args removeObjectAtIndex:[%@]", @(idx));
    }
}
- (void)nty_replaceObjectAtIndex:(NSUInteger)idx withObject:(id)object {
    if (object && idx < self.count) {
        [self nty_replaceObjectAtIndex:idx withObject:object];
    } else {
        ACAssert(NO, @"Invalid args replaceObjectAtIndex:[%@] withObject:[%@]", @(idx), object);
    }
}
@end

#pragma mark - NSUserDefaults
@implementation NSUserDefaults (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = [[[NSUserDefaults alloc] init] class];
        ACSwizzle(clazz,objectForKey:);
        ACSwizzle(clazz,setObject: forKey:);
        ACSwizzle(clazz,removeObjectForKey:);

        ACSwizzle(clazz,integerForKey:);
        ACSwizzle(clazz,boolForKey:);
    });
}
- (id)nty_objectForKey:(NSString*)defaultName {
    if (defaultName) {
        return [self nty_objectForKey:defaultName];
    }
    return nil;
}

- (NSInteger)nty_integerForKey:(NSString*)defaultName {
    if (defaultName) {
        return [self nty_integerForKey:defaultName];
    }
    return 0;
}

- (BOOL)nty_boolForKey:(NSString*)defaultName {
    if (defaultName) {
        return [self nty_boolForKey:defaultName];
    }
    return NO;
}

- (void)nty_setObject:(id)value forKey:(NSString*)aKey {
    if (aKey) {
        [self nty_setObject:value forKey:aKey];
    } else {
        ACAssert(NO, @"Invalid args setObject:[%@] forKey:[%@]", value, aKey);
    }
}
- (void)nty_removeObjectForKey:(NSString*)aKey {
    if (aKey) {
        [self nty_removeObjectForKey:aKey];
    } else {
        ACAssert(NO, @"Invalid args removeObjectForKey:[%@]", aKey);
    }
}

@end

#pragma mark - NSCache

@implementation NSCache (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = [[[NSCache alloc] init] class];
        ACSwizzle(clazz,setObject: forKey:);
        ACSwizzle(clazz,setObject: forKey: cost:);
    });
}
- (void)nty_setObject:(id)obj forKey:(id)key // 0 cost
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

@implementation NSNumber (AvoidCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = NSClassFromString(@"__NSCFNumber");
        ACSwizzle(clazz, compare:);
    });
}

- (NSComparisonResult)nty_compare:(NSNumber*)otherNumber {
    if (!otherNumber) {
        return NSOrderedDescending;
    }
    return [self nty_compare:otherNumber];
}

@end
