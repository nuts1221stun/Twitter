//
//  ComposeViewController.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/24/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "ComposeViewController.h"
#import "TwitterClient.h"
#import "User.h"

@interface ComposeViewController ()

@property (strong, nonatomic) User *user;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.user = [User currentUser];
    self.nameLabel.text = self.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", self.user.screenName];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.user.profileImageUrl]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        self.profileImage.image = [UIImage imageWithData:data];
    }];
    [self setUpNavigationBar];
}

- (void)setUpNavigationBar {
    [self.navigationItem setHidesBackButton:YES animated:YES];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButtonClick:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *tweetButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweetButtonClick:)];
    self.navigationItem.rightBarButtonItem = tweetButton;
}

- (void)onCancelButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)onTweetButtonClick:(id)sender {
    NSLog(@"%@", self.editableTextView.text);
    [[TwitterClient sharedInstance] tweet:self.editableTextView.text completionHandler:^{}];
    [self.navigationController popViewControllerAnimated:YES];
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
