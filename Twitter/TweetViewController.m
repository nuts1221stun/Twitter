//
//  TweetViewController.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/19/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "TweetViewController.h"
#import "TwitterClient.h"
#import "User.h"

@interface TweetViewController ()

@property (strong, nonatomic) TwitterClient *twitterClient;

@end

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.twitterClient = [TwitterClient sharedInstance];
}
- (IBAction)onLogoutButtonClick:(id)sender {
    [self.twitterClient logout];
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
