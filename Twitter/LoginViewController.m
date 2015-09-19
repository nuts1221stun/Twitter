//
//  LoginViewController.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/19/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterClient.h"

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
}
- (IBAction)onLoginButtonClick:(id)sender {
    [self.twitterClient login:^(NSData *userRawData) {
        NSLog(@"we are loggined in!!!!!!!!!!!!");
        NSString *str = [[NSString alloc] initWithData:userRawData encoding:NSUTF8StringEncoding];
        NSLog(@"user json: %@", str);
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
