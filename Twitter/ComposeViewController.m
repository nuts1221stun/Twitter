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
#import "Tweet.h"

@interface ComposeViewController () <UITextViewDelegate>

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) Tweet *replyingTweet;

@end

NSString * const TWEET = @"Tweet";
NSString * const RETWEET = @"Retweet";
NSString * const REPLY = @"Reply";

@implementation ComposeViewController

- (instancetype)initWithNibNameAsTweetState:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.state = TWEET;
    return self;
}
- (instancetype)initWithNibNameAsReplyState:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil replyingTweet:(Tweet *)tweet {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.state = REPLY;
    self.replyingTweet = tweet;
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.state = TWEET;
    return self;
}

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

    self.editableTextView.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.composeView addGestureRecognizer:tap];
}

- (void)setUpNavigationBar {
    [self.navigationItem setHidesBackButton:YES animated:YES];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButtonClick:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    if ([self.state isEqualToString:RETWEET]) {
        UIBarButtonItem *retweetButton = [[UIBarButtonItem alloc] initWithTitle:self.state style:UIBarButtonItemStylePlain target:self action:@selector(onRetweetButtonClick:)];
        self.navigationItem.rightBarButtonItem = retweetButton;
    } else if ([self.state isEqualToString:REPLY]) {
        UIBarButtonItem *replyButton = [[UIBarButtonItem alloc] initWithTitle:self.state style:UIBarButtonItemStylePlain target:self action:@selector(onReplyButtonClick:)];
        self.navigationItem.rightBarButtonItem = replyButton;
    } else {
        UIBarButtonItem *tweetButton = [[UIBarButtonItem alloc] initWithTitle:self.state style:UIBarButtonItemStylePlain target:self action:@selector(onTweetButtonClick:)];
        self.navigationItem.rightBarButtonItem = tweetButton;
    }
}

- (void)onCancelButtonClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)onRetweetButtonClick:(id)sender {
    [[TwitterClient sharedInstance] tweet:self.editableTextView.text completionHandler:^{}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onReplyButtonClick:(id)sender {
    [[TwitterClient sharedInstance] replyToTweet:self.replyingTweet.tweetId tweetAuthorScreenName:self.replyingTweet.user.screenName withStatus:self.editableTextView.text completionHandler:^{}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onTweetButtonClick:(id)sender {
    [[TwitterClient sharedInstance] tweet:self.editableTextView.text completionHandler:^{}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Write something..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Write something...";
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}

- (void)dismissKeyboard {
    [self.editableTextView resignFirstResponder];
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
