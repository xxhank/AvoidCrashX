//
//  AppDelegate.m
//  SafeKitExample
//
//  Created by zhangyu on 16/2/16.
//  Copyright © 2016年 zhangyu. All rights reserved.
//

#import "AppDelegate.h"
#import "SKMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    NSArray *array = @"hello";
    NSString*item  = [array objectAtIndex:1];

    return YES;
}

@end
