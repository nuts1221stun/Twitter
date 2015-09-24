//
//  AppDelegate.h
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/18/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "TweetTableViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) TweetTableViewController *tweetViewController;

@end

