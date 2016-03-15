//
//  AppDelegate.m
//  Easy Hire
//
//  Created by Prasanna Ramachandra Aithal on 9/5/15.
//  Copyright (c) 2015 Prasanna Ramachandra Aithal. All rights reserved.
//

#import "AppDelegate.h"
#import "EHMainViewController.h"
#import "EHSettingsViewController.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window = window;
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.frame = CGRectMake(0, 0, 320, 568);
    self.window.bounds = CGRectMake(0, 0, 320, 568);
    EHMainViewController *frontViewController = [[EHMainViewController alloc] init];
    
//    EHSettingsViewController *rearViewController = [[EHSettingsViewController alloc] init];
//    
//    UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
//    UINavigationController *rearNavigationController = [[UINavigationController alloc] initWithRootViewController:rearViewController];
//    
//    SWRevealViewController *mainRevealController = [[SWRevealViewController alloc]
//                                                    initWithRearViewController:rearNavigationController frontViewController:frontNavigationController];
//    
//    mainRevealController.delegate = self;
//    
//    self.viewController = mainRevealController;
   
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:frontViewController];
    controller.view.frame = CGRectMake(0, 0, 320, 568);
    self.window.rootViewController = controller;
    [self.window makeKeyAndVisible];
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
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    NSUInteger supportedOrientation = UIInterfaceOrientationMaskAll;
    
    if (self.window.rootViewController) {
        UIViewController *viewController = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
        supportedOrientation = [viewController supportedInterfaceOrientations];
    }
    
    return supportedOrientation;
}



@end
