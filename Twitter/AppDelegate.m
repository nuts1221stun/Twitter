//
//  AppDelegate.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/18/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "TwitterClient.h"
#import "User.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:UserDidLogoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin) name:UserDidLoginNotification object:nil];
    
    User *user = [User currentUser];
    
    if (user != nil) {
        [self useTweetViewController];
    } else {
        [self useLoginViewController];
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)userDidLogout {
    [self useLoginViewController];
}

- (void)userDidLogin {
    [self useTweetViewController];
}

- (void)useLoginViewController {
    self.loginViewController = [[LoginViewController alloc] init];
    self.window.rootViewController = self.loginViewController;
}

- (void)useTweetViewController {
    //TweetTableViewController *tweetTableViewController = [[TweetTableViewController alloc] init];
    self.mainViewController = [[MainViewController alloc] init];
    //[self.mainViewController setUpTableWithViewController:tweetTableViewController];
    /*self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.6745098 blue:0.9294118 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.window.rootViewController = self.navigationController;*/
    self.window.rootViewController = self.mainViewController;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation NS_AVAILABLE_IOS(4_2) {
    [[TwitterClient sharedInstance] openUrl:url];
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
