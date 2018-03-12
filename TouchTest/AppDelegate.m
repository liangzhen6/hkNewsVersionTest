//
//  AppDelegate.m
//  TouchTest
//
//  Created by shenzhenshihua on 2018/3/12.
//  Copyright © 2018年 shenzhenshihua. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self add3DtouchItem:application];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"%@",options);
    return YES;
}



- (void)add3DtouchItem:(UIApplication *)application {
    UIApplicationShortcutItem * item1 = [[UIApplicationShortcutItem alloc] initWithType:@"item1" localizedTitle:@"每日明报" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypePlay] userInfo:nil];
    UIApplicationShortcutItem * item2 = [[UIApplicationShortcutItem alloc] initWithType:@"item2" localizedTitle:@"即时新闻" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeSearch] userInfo:nil];
    /*
     几点注意：
     1、快捷标签最多可以创建四个，包括静态的和动态的。
     
     2、每个标签的题目和icon最多两行，多出的会用...省略
     */
    
    application.shortcutItems = @[item1, item2];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    //不管APP在后台还是进程被杀死，只要通过主屏快捷操作进来的，都会调用这个方法
    NSLog(@"%@---%@--%@--",shortcutItem.type,shortcutItem.localizedTitle,shortcutItem.icon);
    completionHandler(YES);
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
