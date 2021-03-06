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
#import "ProfileViewController.h"


@interface TweetTableViewController () <UITableViewDataSource, UITableViewDelegate, TweetCellDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) TwitterClient *twitterClient;
@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSCache *cache;

@property (weak, nonatomic) IBOutlet UITableView *tweetTableView;


@end

@implementation TweetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.twitterClient = [TwitterClient sharedInstance];
    self.tweets = nil;
    
    // refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tweetTableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(getTweets) forControlEvents:UIControlEventValueChanged];
    
    self.tweetTableView.delegate = self;
    self.tweetTableView.dataSource = self;
    self.tweetTableView.rowHeight = UITableViewAutomaticDimension;
    self.tweetTableView.estimatedRowHeight = 200.0;
    
    [self setUpNavigationBar];
    [self getTweets];
    
    self.cache = [[NSCache alloc] init];
}

- (void)getTweets {
    [self.twitterClient getHomeTimeline:^(NSArray *tweets) {
        if (tweets != nil) {
            self.tweets = tweets;
            [self.tweetTableView reloadData];
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)setUpNavigationBar {
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(onMenuButtonClick:)];
    [menuButton setImage:[UIImage imageNamed:@"menu.png"]];
    self.navigationItem.leftBarButtonItem = menuButton;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    UIBarButtonItem *tweetButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweetButtonClick:)];
    self.navigationItem.rightBarButtonItem = tweetButton;
}

- (void)onMenuButtonClick:(id)sender {
    [self.mainViewController toggleMenu];
}
- (void)onTweetButtonClick:(id)sender {
    ComposeViewController *composeVC = [[ComposeViewController alloc] initWithNibNameAsTweetState:@"ComposeViewController" bundle:nil];
    [self.navigationController pushViewController:composeVC animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    long count = 0;
    if (self.tweets != nil) {
        count = self.tweets.count;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tweets == nil) {
        return [[UITableViewCell alloc] init];
    }

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
    
    [cell.profileButton setBackgroundImage:nil forState:UIControlStateNormal];
    UIImage *profileImage = [self.cache objectForKey:tweet.user.profileImageUrl];
    if (profileImage != nil) {
        [cell.profileButton setBackgroundImage:profileImage forState:UIControlStateNormal];
    } else {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:tweet.user.profileImageUrl]];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            UIImage *downloadedImage = [UIImage imageWithData:data];
            [cell.profileButton setBackgroundImage:downloadedImage forState:UIControlStateNormal];
            [self.cache setObject:downloadedImage forKey:tweet.user.profileImageUrl];
        }];
    }
    
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.tweets == nil) {
        return;
    }
    
    Tweet *tweet = self.tweets[indexPath.row];
    
    TweetViewController *tweetVC = [[TweetViewController alloc] initWithNibName:@"TweetViewController" bundle:nil];
    tweetVC.tweet = tweet;
    [self.navigationController pushViewController:tweetVC animated:YES];
}

- (void)tweetCell:(TweetCell *)cell didClickProfileButton:(BOOL)value {
    NSIndexPath *indexPath = [self.tweetTableView indexPathForCell:cell];
    Tweet *tweet = self.tweets[indexPath.row];
    ProfileViewController *profileVC = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil user:tweet.user];
    [self.navigationController pushViewController:profileVC animated:YES];
}
- (void)tweetCell:(TweetCell *)cell didClickReplyButton:(BOOL)value {
    NSIndexPath *indexPath = [self.tweetTableView indexPathForCell:cell];
    Tweet *tweet = self.tweets[indexPath.row];
    ComposeViewController *composeVC = [[ComposeViewController alloc] initWithNibNameAsReplyState:@"ComposeViewController" bundle:nil replyingTweet:tweet];
    [self.navigationController pushViewController:composeVC animated:YES];
}
- (void)tweetCell:(TweetCell *)cell didClickRetweetButton:(BOOL)value {
    NSIndexPath *indexPath = [self.tweetTableView indexPathForCell:cell];
    Tweet *tweet = self.tweets[indexPath.row];
    [self.twitterClient retweet:tweet.tweetId completionHandler:^{
        NSLog(@"retweeted!!!!!!!!");
    }];
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
