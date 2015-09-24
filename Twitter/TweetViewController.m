//
//  TweetViewController.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/24/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "TweetViewController.h"
#import "TwitterClient.h"

@interface TweetViewController ()

@property (strong, nonatomic) TwitterClient *twitterClient;

@end

NSString * const RETWEET_LABEL = @"RETWEET";
NSString * const FAVORITE_LABEL = @"FAVORITE";

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.twitterClient = [TwitterClient sharedInstance];
    
    if (self.tweet != nil) {
        self.nameLabel.text = self.tweet.user.name;
        if (self.tweet.user.screenName != nil) {
            self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", self.tweet.user.screenName];
        } else {
            self.screenNameLabel.text = @"";
        }
        self.createdAtLabel.text = self.tweet.createdAt;
        self.tweetTextLabel.text = self.tweet.text;
        
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", self.tweet.retweetCount];
        if (self.tweet.retweetCount > 1) {
            self.retweetLabel.text = [NSString stringWithFormat:@"%@s", RETWEET_LABEL];
        } else {
            self.retweetLabel.text = RETWEET_LABEL;
        }
        
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", self.tweet.favoriteCount];
        if (self.tweet.favoriteCount > 1) {
            self.favoriteLabel.text = [NSString stringWithFormat:@"%@S", FAVORITE_LABEL];
        } else {
            self.favoriteLabel.text = FAVORITE_LABEL;
        }
        
        
        if (self.tweet.retweeted) {
            [self.retweetButton setImage:[UIImage imageNamed:@"retweetOn.png"] forState:UIControlStateNormal];
        }
        if (self.tweet.favorited) {
            [self.favoriteButton setImage:[UIImage imageNamed:@"favoriteOn.png"] forState:UIControlStateNormal];
        }
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.tweet.user.profileImageUrl]];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            self.profileImage.image = [UIImage imageWithData:data];
        }];
    }
}
- (IBAction)onReplyButtonClick:(id)sender {
    
}
- (IBAction)onRetweetButtonClick:(id)sender {
    
}
- (IBAction)onFavoriteButtonClick:(id)sender {
    if (self.tweet.favorited) {
        [self.twitterClient unFavorite:self.tweet.tweetId completionHandler:^{}];
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
        if (self.tweet.favoriteCount > 0) {
            self.tweet.favoriteCount--;
        }
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", self.tweet.favoriteCount];
    } else {
        [self.twitterClient favorite:self.tweet.tweetId completionHandler:^{}];
        [self.favoriteButton setImage:[UIImage imageNamed:@"favoriteOn.png"] forState:UIControlStateNormal];
        self.tweet.favoriteCount++;
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", self.tweet.favoriteCount];
    }
    if (self.tweet.favoriteCount > 1) {
        self.favoriteLabel.text = [NSString stringWithFormat:@"%@s", FAVORITE_LABEL];
    } else {
        self.favoriteLabel.text = FAVORITE_LABEL;
    }
    self.tweet.favorited = !self.tweet.favorited;
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
