//
//  TweetViewController.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/19/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "TweetTableViewController.h"
#import "TweetViewController.h"
#import "ComposeViewController.h"
#import "TweetCell.h"
#import "TwitterClient.h"
#import "User.h"
#import "Tweet.h"

@interface TweetTableViewController () <UITableViewDataSource, UITableViewDelegate, TweetCellDelegate>

@property (strong, nonatomic) TwitterClient *twitterClient;
@property (strong, nonatomic) NSArray *tweets;
@property (weak, nonatomic) IBOutlet UITableView *tweetTableView;

@end

@implementation TweetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.twitterClient = [TwitterClient sharedInstance];
    
    [self.twitterClient getHomeTimeline:^(NSArray *tweets) {
        self.tweets = tweets;
        [self.tweetTableView reloadData];
    }];
    
    self.tweetTableView.delegate = self;
    self.tweetTableView.dataSource = self;
    self.tweetTableView.rowHeight = UITableViewAutomaticDimension;
    self.tweetTableView.estimatedRowHeight = 200.0;
    
    [self setUpNavigationBar];
}

- (void)setUpNavigationBar {
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(onLogoutButtonClick:)];
    self.navigationItem.leftBarButtonItem = logoutButton;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    UIBarButtonItem *tweetButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweetButtonClick:)];
    self.navigationItem.rightBarButtonItem = tweetButton;
}

- (void)onLogoutButtonClick:(id)sender {
    [self.twitterClient logout];
}

- (void)onTweetButtonClick:(id)sender {
    ComposeViewController *composeVC = [[ComposeViewController alloc] initWithNibName:@"ComposeViewController" bundle:nil];
    [self.navigationController pushViewController:composeVC animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"tweetCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell"];
    }
    Tweet *tweet = self.tweets[indexPath.row];

    cell.nameLabel.text = tweet.user.name;
    if (tweet.user.screenName != nil) {
        cell.screenNameLabel.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    } else {
        cell.screenNameLabel.text = @"";
    }
    cell.createdAtLabel.text = tweet.createdAt;
    cell.tweetTextLabel.text = tweet.text;
    
    cell.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", tweet.retweetCount];
    cell.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", tweet.favoriteCount];
    
    if (tweet.retweeted) {
        [cell.retweetButton setImage:[UIImage imageNamed:@"retweetOn.png"] forState:UIControlStateNormal];
    }
    if (tweet.favorited) {
        [cell.favoriteButton setImage:[UIImage imageNamed:@"favoriteOn.png"] forState:UIControlStateNormal];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:tweet.user.profileImageUrl]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        cell.profileImage.image = [UIImage imageWithData:data];
    }];
    
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Tweet *tweet = self.tweets[indexPath.row];
    
    TweetViewController *tweetVC = [[TweetViewController alloc] initWithNibName:@"TweetViewController" bundle:nil];
    tweetVC.tweet = tweet;
    [self.navigationController pushViewController:tweetVC animated:YES];
}

- (void)tweetCell:(TweetCell *)cell didClickReplyButton:(BOOL)value {
    
}
- (void)tweetCell:(TweetCell *)cell didClickRetweetButton:(BOOL)value {
    NSLog(@"retweet!");
}
- (void)tweetCell:(TweetCell *)cell didClickFavoriteButton:(BOOL)value {
    NSIndexPath *indexPath = [self.tweetTableView indexPathForCell:cell];
    Tweet *tweet = self.tweets[indexPath.row];
    if (tweet.favorited) {
        [self.twitterClient unFavorite:tweet.tweetId completionHandler:^{}];
        [cell.favoriteButton setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
        tweet.favoriteCount--;
        cell.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", tweet.favoriteCount];
    } else {
        [self.twitterClient favorite:tweet.tweetId completionHandler:^{}];
        [cell.favoriteButton setImage:[UIImage imageNamed:@"favoriteOn.png"] forState:UIControlStateNormal];
        tweet.favoriteCount++;
        cell.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", tweet.favoriteCount];
    }
    tweet.favorited = !tweet.favorited;
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
