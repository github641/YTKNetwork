//
//  AppDelegate.m
//  YTKNetworkDemo
//
//  Created by Chenyu Lan on 10/28/14.
//  Copyright (c) 2014 yuantiku.com. All rights reserved.
//

#import "AppDelegate.h"
#import "YTKNetworkConfig.h"
#import "YTKUrlArgumentsFilter.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)setupRequestFilters {
    
    #pragma mark - ================== YTKUrlFilterProtocol 接口 ==================
    /* lzy171103注:
     YTKUrlFilterProtocol 接口用于实现对网络请求 URL 或参数的重写，例如可以统一为网络请求加上一些参数，或者修改一些路径。
     例如：在猿题库中，我们需要为每个网络请求加上客户端的版本号作为参数。所以我们实现了如下一个 YTKUrlArgumentsFilter类，实现了 YTKUrlFilterProtocol 接口 :
     
     通过以上 YTKUrlArgumentsFilter 类，我们就可以用以下代码方便地为网络请求增加统一的参数，如增加当前客户端的版本号：
     */
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    YTKNetworkConfig *config = [YTKNetworkConfig sharedConfig];
    YTKUrlArgumentsFilter *urlFilter = [YTKUrlArgumentsFilter filterWithArguments:@{@"version": appVersion}];
    
    [config addUrlFilter:urlFilter];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    #pragma mark - ================== 添加ytknetwork全局参数 ==================
    [self setupRequestFilters];
//    NSString *s = @"生物";
//    NSLog(@"%s",s.UTF8String);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
