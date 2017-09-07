//
//  NSStringSafeTest.m
//  AvoidCrash
//
//  Created by wangchao on 2017/9/7.
//  Copyright © 2017年 ibestv. All rights reserved.
//

#import <XCTest/XCTest.h>

#ifndef __FILENAME__
#define __FILENAME__ ({(strrchr(__FILE__, '/')?:(__FILE__ - 1)) + 1;})
#endif // ifndef __FILENAME__


#ifdef NSLogError
#define ACLogInfo NSLogError
#else // ifdef NSLogError
#define ACLogInfo(fmt, ...) \
    NSLog(@"\033[fg128,128,128;%s:%d %s> " fmt @"\033[;", \
    __FILENAME__, __LINE__, __FUNCTION__,##__VA_ARGS__)
#endif // ifdef NSLogError

@interface NSStringSafeTest : XCTestCase

@end

@implementation NSStringSafeTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInit {
    NSString       *nilString    = nil;
    NSString       *nonnilString = @"";
    NSString       *nilFormatter = nil;
    id              nilAnything  = nil;
    char           *bytes        = "1";
    unichar         chars[]      = {'1',0};
    NSData         *data         = [NSData dataWithBytes:bytes length:1];
    NSCharacterSet *set          = [NSCharacterSet characterSetWithCharactersInString:@"1"];

    {
        NSString *obj = @"";
        ACLogInfo(@"%@", [obj class]);
    }

    {
        NSString *obj = @"1";
        ACLogInfo(@"%@", [obj class]);
    }

    {
        NSString *obj = [[NSString alloc] init];
        ACLogInfo(@"%@", [obj class]);
    }

    {
        // NSString *obj = [[NSString alloc] initWithCoder:nilAnything];
        //NSLog(@"%@", [obj class]);
    }

    {
        NSString *obj = [[NSString alloc] initWithString:nilString];
        obj = [[NSString alloc] initWithString:nonnilString];
        ACLogInfo(@"%@", [obj class]);
    }
    {
        NSString *obj = [[NSString alloc] initWithUTF8String:NULL];
        obj = [[NSString alloc] initWithUTF8String:nonnilString.UTF8String];
        ACLogInfo(@"%@", [obj class]);
    }

    {
        NSString *obj = [[NSString alloc] initWithCharacters:nil length:10];
        obj = [[NSString alloc] initWithCharacters:chars length:1];
        ACLogInfo(@"%@", [obj class]);
    }
    {
        NSString *obj = [[NSString alloc] initWithCharactersNoCopy:nil length:10  freeWhenDone:YES];
        obj = [[NSString alloc] initWithCharactersNoCopy:chars length:1  freeWhenDone:NO];
        ACLogInfo(@"%@", [obj class]);
    }

    {
        NSString *obj = [[NSString alloc] initWithFormat:nil];
        obj = [[NSString alloc] initWithFormat:@"%d", 1];
        ACLogInfo(@"%@", [obj class]);
    }
    {
//        NSString *obj = [[NSString alloc] initWithFormat:nilString arguments:nil];
//        obj = [[NSString alloc] initWithFormat:@"%d" arguments:nil];
//        ACLogInfo(@"%@", [obj class]);
    }

    {
        NSString *obj = [[NSString alloc] initWithBytes:nil length:10 encoding:NSUTF8StringEncoding];
        obj = [[NSString alloc] initWithBytes:bytes length:1 encoding:NSUTF8StringEncoding];
        ACLogInfo(@"%@", [obj class]);
    }
    {
        // NSString *obj = [[NSString alloc] initWithBytesNoCopy:nil length:10 encoding:NSUTF8StringEncoding freeWhenDone:YES];
        // NSLog(@"%@", [obj class]);
    }


    {
        NSString *obj = [[NSString alloc] initWithData:nil encoding:NSUTF8StringEncoding];
        obj = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        ACLogInfo(@"%@", [obj class]);
    }


//    {
//        NSString *obj = [[NSString alloc]];
//        NSLog(@"%@", [obj class]);
//    }
//    {
//        NSString *obj = [[NSString alloc]];
//        NSLog(@"%@", [obj class]);
//    }
//    {
//        NSString *obj = [[NSString alloc]];
//        NSLog(@"%@", [obj class]);
//    }
}
- (void)testNSCFConstantStringOperations {
    NSString       *nilString                = nil;
    NSString       *nilFormatter             = nil;
    NSCharacterSet *nilCharacterSet          = nil;
    NSString       *nilSeparator             = nil;
    NSCharacterSet *nilSeparatorCharacterSet = nil;
    NSRange         range                    = NSMakeRange(3, 10);
    {
        unichar   chars[] = {'1',0};

        NSString *obj = [[NSString alloc] initWithCharacters:chars length:1];
        ;
        [obj characterAtIndex:10];
        [obj substringFromIndex:10];
        [obj substringToIndex:10];
        [obj substringWithRange:range];
        unichar *nilbuffer = nil;
        [obj getCharacters:nilbuffer range:range];

        unichar buffer[100] = {};
        [obj getCharacters:buffer range:range];

        [obj containsString:nilString];

        [obj rangeOfString:nilString options:NSLiteralSearch range:NSMakeRange(3, 10)];

        [obj rangeOfCharacterFromSet:nilCharacterSet options:NSLiteralSearch range:NSMakeRange(3, 10)];

        [obj stringByAppendingString:nilString];
        [obj stringByAppendingFormat:nilFormatter, nilString];

        [obj componentsSeparatedByString:nilSeparator];
        [obj componentsSeparatedByCharactersInSet:nilSeparatorCharacterSet];

        [obj stringByTrimmingCharactersInSet:nilCharacterSet];

        [obj stringByReplacingOccurrencesOfString:nilString withString:@"1"];
        [obj stringByReplacingOccurrencesOfString:@"1" withString:nilString];

        [obj stringByReplacingCharactersInRange:range withString:nilString];
        [obj stringByReplacingCharactersInRange:range withString:@"1"];
    }
}

- (void)testNSTaggedPointerStringOperations {
    NSString       *nilString                = nil;
    NSString       *nilFormatter             = nil;
    NSCharacterSet *nilCharacterSet          = nil;
    NSString       *nilSeparator             = nil;
    NSCharacterSet *nilSeparatorCharacterSet = nil;
    NSRange         range                    = NSMakeRange(3, 10);
    {
        NSString *obj = @"";
        [obj characterAtIndex:10];
        [obj substringFromIndex:10];
        [obj substringToIndex:10];
        [obj substringWithRange:range];
        unichar *nilbuffer = nil;
        [obj getCharacters:nilbuffer range:range];

        unichar buffer[100] = {};
        [obj getCharacters:buffer range:range];

        [obj containsString:nilString];

        [obj rangeOfString:nilString options:NSLiteralSearch range:NSMakeRange(3, 10)];

        [obj rangeOfCharacterFromSet:nilCharacterSet options:NSLiteralSearch range:NSMakeRange(3, 10)];

        [obj stringByAppendingString:nilString];
        [obj stringByAppendingFormat:nilFormatter, nilString];

        [obj componentsSeparatedByString:nilSeparator];
        [obj componentsSeparatedByCharactersInSet:nilSeparatorCharacterSet];

        [obj stringByTrimmingCharactersInSet:nilCharacterSet];

        [obj stringByReplacingOccurrencesOfString:nilString withString:@"1"];
        [obj stringByReplacingOccurrencesOfString:@"1" withString:nilString];

        [obj stringByReplacingCharactersInRange:range withString:nilString];
        [obj stringByReplacingCharactersInRange:range withString:@"1"];
    }
}

- (void)testNSCFStringOperations {
    NSString       *nilString                = nil;
    NSString       *nilFormatter             = nil;
    NSCharacterSet *nilCharacterSet          = nil;
    NSString       *nilSeparator             = nil;
    NSCharacterSet *nilSeparatorCharacterSet = nil;
    NSRange         range                    = NSMakeRange(3, 10);
    {
        unichar   chars[] = {'1',0};
        NSString *obj     = [[NSString alloc] initWithCharactersNoCopy:chars length:1  freeWhenDone:NO];;
        [obj characterAtIndex:10];
        [obj substringFromIndex:10];
        [obj substringToIndex:10];
        [obj substringWithRange:range];
        unichar *nilbuffer = nil;
        [obj getCharacters:nilbuffer range:range];

        unichar buffer[100] = {};
        [obj getCharacters:buffer range:range];

        [obj containsString:nilString];

        [obj rangeOfString:nilString options:NSLiteralSearch range:NSMakeRange(3, 10)];

        [obj rangeOfCharacterFromSet:nilCharacterSet options:NSLiteralSearch range:NSMakeRange(3, 10)];

        [obj stringByAppendingString:nilString];
        [obj stringByAppendingFormat:nilFormatter, nilString];

        [obj componentsSeparatedByString:nilSeparator];
        [obj componentsSeparatedByCharactersInSet:nilSeparatorCharacterSet];

        [obj stringByTrimmingCharactersInSet:nilCharacterSet];

        [obj stringByReplacingOccurrencesOfString:nilString withString:@"1"];
        [obj stringByReplacingOccurrencesOfString:@"1" withString:nilString];

        [obj stringByReplacingCharactersInRange:range withString:nilString];
        [obj stringByReplacingCharactersInRange:range withString:@"1"];
    }
}

//- (void)testNSCFConstantStringOperations {
//    NSString       *nilString                = nil;
//    NSString       *nilFormatter             = nil;
//    NSCharacterSet *nilCharacterSet          = nil;
//    NSString       *nilSeparator             = nil;
//    NSCharacterSet *nilSeparatorCharacterSet = nil;
//    NSRange         range                    = NSMakeRange(3, 10);
//    {
//        NSString *obj = @"";
//        [obj characterAtIndex:10];
//        [obj substringFromIndex:10];
//        [obj substringToIndex:10];
//        [obj substringWithRange:range];
//        unichar *nilbuffer = nil;
//        [obj getCharacters:nilbuffer range:range];
//
//        unichar buffer[100] = {};
//        [obj getCharacters:buffer range:range];
//
//        [obj containsString:nilString];
//
//        [obj rangeOfString:nilString options:NSLiteralSearch range:NSMakeRange(3, 10)];
//
//        [obj rangeOfCharacterFromSet:nilCharacterSet options:NSLiteralSearch range:NSMakeRange(3, 10)];
//
//        [obj stringByAppendingString:nilString];
//        [obj stringByAppendingFormat:nilFormatter, nilString];
//
//        [obj componentsSeparatedByString:nilSeparator];
//        [obj componentsSeparatedByCharactersInSet:nilSeparatorCharacterSet];
//
//        [obj stringByTrimmingCharactersInSet:nilCharacterSet];
//
//        [obj stringByReplacingOccurrencesOfString:nilString withString:@"1"];
//        [obj stringByReplacingOccurrencesOfString:@"1" withString:nilString];
//
//        [obj stringByReplacingCharactersInRange:range withString:nilString];
//        [obj stringByReplacingCharactersInRange:range withString:@"1"];
//    }
//}
@end
