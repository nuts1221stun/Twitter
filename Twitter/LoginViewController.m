//
//  LoginViewController.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/19/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterClient.h"
#import "User.h"
#import "TweetTableViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userName;

@property (strong, nonatomic) TwitterClient *twitterClient;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.twitterClient = [TwitterClient sharedInstance];
    
    self.loginButton.layer.cornerRadius =8.0;
    self.loginButton.layer.borderWidth = 1.0;
    self.loginButton.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
    self.loginButton.clipsToBounds = YES;
    
}
- (IBAction)onLoginButtonClick:(id)sender {
    [self.twitterClient login:^(User *user) {
        if (user != nil) {
            NSLog(@"%@ has logged in", user.name);
            //[self presentViewController:[[TweetViewController alloc] init] animated:YES completion:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
