//
//  AvoidCrashTests.m
//  AvoidCrashTests
//
//  Created by wangchao on 2017/9/6.
//  Copyright © 2017年 ibestv. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <objc/runtime.h>

@interface Base : NSObject
@end
@implementation Base

@end

@interface A : Base
- (void)print:(NSString*)msg;
@end
@implementation A
@end

@interface AvoidCrashTests : XCTestCase

@end

@implementation AvoidCrashTests
- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNotImplementMethod {
    A *a = [A new];
    [a print:@"hello"];
}

- (void)testNotExistMethod {
    NSArray *array = @"hello";
    NSString*item  = [array objectAtIndex:1];
    NSLog(@"%@", item);
}

- (void)testArray {
    NSArray*array = [NSArray array];     //__NSArray0
    NSLog(@"%@", array[1]);
    [array objectAtIndex:4];
    [array subarrayWithRange:NSMakeRange(2, 2)];
}
- (void)testArrayZero {
    NSArray*array = [NSArray arrayWithObjects:nil];     //__NSArray0
    NSLog(@"%@", array[1]);
    [array objectAtIndex:4];
    [array subarrayWithRange:NSMakeRange(2, 2)];
}

- (void)testArrayOne {
    NSArray*array = [NSArray arrayWithObjects:@1, nil];     //__NSSingleObjectArrayI
    NSLog(@"%@", array[2]);
    [array objectAtIndex:4];
}

- (void)testArrayThree {
    NSArray*array = [NSArray arrayWithObjects:@1, @2, nil];     //__NSArrayI
    NSLog(@"%@", array[3]);
    [array objectAtIndex:4];
}

- (void)testMutableArray {
    NSMutableArray*array = [NSMutableArray array];     //__NSArray0
    NSLog(@"%@", array[1]);
    [array objectAtIndex:4];
    [array subarrayWithRange:NSMakeRange(2, 2)];
}

- (void)testMutableArrayZero {
    NSMutableArray*array = [NSMutableArray arrayWithObjects:nil];     //__NSArray0
    NSLog(@"%@", array[1]);
    [array objectAtIndex:4];
    [array subarrayWithRange:NSMakeRange(2, 2)];
}

- (void)testMutableArrayOne {
    NSMutableArray*array = [NSMutableArray arrayWithObjects:@1, nil];     //__NSSingleObjectArrayI
    NSLog(@"%@", array[2]);
    [array objectAtIndex:4];
}

- (void)testMutableArrayThree {
    NSMutableArray*array = [NSMutableArray arrayWithObjects:@1, @2, nil];     //__NSArrayI
    NSLog(@"%@", array[3]);
    [array objectAtIndex:4];
}

- (void)testMutableArrayInsertOverflow {
    NSMutableArray*array = [NSMutableArray array];                            //__NSArrayI
    [array insertObject:@3 atIndex:3];
    NSLog(@"%@", array[3]);
    [array removeObjectAtIndex:3];
}

- (void)testArrayLiteral {
    NSArray *item  = nil;
    NSArray *items = @[@"a",@"b", item,@"c"];
}

- (void)testNSDictionary {
    NSDictionary*dict = [NSDictionary dictionaryWithObjectsAndKeys:nil];     //__NSDictionary0
    [dict objectForKey:nil];

    dict = [NSDictionary dictionaryWithObjectsAndKeys:@"a",@"1", nil];     //__NSSingleEntryDictionaryI
    [dict objectForKey:nil];

    dict = [NSDictionary dictionaryWithObjectsAndKeys:@"a",@"1",@"b",@"2", nil];     //__NSDictionaryI
    [dict objectForKey:nil];
}

- (void)testNSDictionaryLiteral {
    NSString    *key   = nil;
    NSString    *value = nil;
    NSDictionary*dict  = @{@"b":@"c",key:value, @"e":value};
}

- (void)testNSMutableDictionary {
    for (NSInteger i = 0; i < 1000; ++i) {
        NSMutableDictionary*mdict = [[NSMutableDictionary alloc] initWithCapacity:3];
        [mdict setObject:@1 forKey:@1];
        [mdict setObject:nil forKey:@1];
        [mdict setObject:@1 forKey:@1];
        [NSMutableArray arrayWithArray:[mdict allValues]];
    }
}

- (void)testNSString {
    NSString*string = @"12345";
    [string substringFromIndex:6];
    [string substringToIndex:6];
    [string substringWithRange:NSMakeRange(0, 6)];
}

- (void)testNSMutableString {
    NSMutableString*mstring = [NSMutableString string];
    [mstring appendString:@"12345"];
    NSLog(@"%@", [mstring substringToIndex:10]);
    NSLog(@"%@", [mstring substringWithRange:NSMakeRange(3, 10)]);

    {
        NSMutableString *obj       = (NSMutableString*)@"";
        NSString        *formatter = nil;
        NSString        *nilValue  = nil;
        [obj appendFormat:formatter, nil];
        [obj appendString:formatter];
        [obj insertString:nilValue atIndex:1];
        [obj deleteCharactersInRange:NSMakeRange(0, 10)];
        [obj stringByAppendingString:nilValue];
        [obj substringFromIndex:10];
        [obj substringToIndex:10];
        [obj substringWithRange:NSMakeRange(3, 10)];
    }
    {
        NSMutableString *obj       = [[NSMutableString alloc] init];
        NSString        *formatter = nil;
        NSString        *nilValue  = nil;
        [obj appendFormat:formatter, nil];
        [obj appendString:formatter];
        [obj insertString:nilValue atIndex:1];
        [obj deleteCharactersInRange:NSMakeRange(0, 10)];
        [obj stringByAppendingString:nilValue];
        [obj substringFromIndex:10];
        [obj substringToIndex:10];
        [obj substringWithRange:NSMakeRange(3, 10)];
    }

    {
        NSMutableString *obj       = @"".mutableCopy;
        NSString        *formatter = nil;
        NSString        *nilValue  = nil;
        [obj appendFormat:formatter, nil];
        [obj appendString:formatter];
        [obj insertString:nilValue atIndex:1];
        [obj deleteCharactersInRange:NSMakeRange(0, 10)];
        [obj stringByAppendingString:nilValue];
        [obj substringFromIndex:10];
        [obj substringToIndex:10];
        [obj substringWithRange:NSMakeRange(3, 10)];
    }
}

- (void)testNSCache {
    NSCache *cache = [[NSCache alloc] init];

    [cache setObject:nil forKey:@""];
    [cache setObject:nil forKey:@"" cost:0];
}

- (void)testNSMutableArrayWithObjects {
    id a[] = {@"a",@"b", nil,@"c"};
    NSLog(@"%@", [NSMutableArray arrayWithObjects:a count:4]);
}


- (void)testNSAttributedString {
    NSAttributedString*attr = [[NSAttributedString alloc] initWithString:nil attributes:nil];
    attr = [[NSAttributedString alloc] initWithString:@"hello"];
    NSLog(@"%@", [attr attributedSubstringFromRange:NSMakeRange(1, 10)]);
    attr = [[NSMutableAttributedString alloc] initWithString:nil attributes:nil];
    attr = [[NSMutableAttributedString alloc] initWithString:@""];
    [attr attributedSubstringFromRange:NSMakeRange(1, 3)];
}

- (void)testNSAttributedStringQuery {
    NSMutableAttributedString*attr = [[NSMutableAttributedString alloc] initWithString:@"hello" attributes:nil];
    [attr attributedSubstringFromRange:NSMakeRange(1000, 1)];

    id nilValue = nil;
    [attr addAttribute:@"a" value:nilValue range:NSMakeRange(100, 0)];
    [attr addAttributes:@{@"c":@"d"} range:NSMakeRange(1000, 0)];
    [attr removeAttribute:@"a" range:NSMakeRange(1000, 0)];
    [attr setAttributes:nil range:NSMakeRange(100, 0)];

    [attr replaceCharactersInRange:NSMakeRange(10, 1) withString:@"a"];
    [attr replaceCharactersInRange:NSMakeRange(10, 1) withAttributedString:@"a"];

    [attr deleteCharactersInRange:NSMakeRange(10000, 1)];
    NSLog(@"%@", attr);
}

- (void)testClass {
    NSString *cls = @"UIWebBrowserView";
    if (!strncmp(cls.UTF8String, "UIWebBro", 8) && !strncmp(cls.UTF8String + 8, "wserView", 8)) {
        NSLog(@"asdfas");
    }
    char buf[17];
    snprintf(buf, 17, "%s%s", "UIWebBro", "wserView");
    // snprintf(buf, 35, "%s%s%s%s", "UIWebBro", "wserView", "MinusAcc", "essoryView");
}



/*
   NSString* className = NSStringFromClass(cls);
   const char *subclassName = [className stringByAppendingString:NSSafeSubclassSuffix].UTF8String;
   Class subclass = objc_getClass(subclassName);
   if (subclass == nil) {
   subclass = objc_allocateClassPair(c, subclassName, 0);
   if (subclass) {
   class_addMethod(subclass, @selector(methodSignatureForSelector:), imp_implementationWithBlock(^NSMethodSignature*(SEL selector){
   return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
   }), "@@::");
   class_addMethod(subclass, @selector(forwardInvocation:), imp_implementationWithBlock(^(NSInvocation* invocation){
   NSString* info = [NSString stringWithFormat:@"unrecognized selector [%@] sent to %@", NSStringFromSelector(invocation.selector), NSStringFromClass(c)];
   [invocation setSelector:@selector(dealException:)];
   [invocation setArgument:&info atIndex:2];
   [invocation invokeWithTarget:[NSSafeProxy new]];
   }), "v@:@");
   objc_registerClassPair(subclass);

   }else {
   SFAssert(0, @"objc_allocateClassPair failed to allocate class %s.", subclassName);

   }
   }*/
@end
