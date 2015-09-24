//
//  TweetViewController.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/19/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "TweetViewController.h"
#import "TweetCell.h"
#import "TwitterClient.h"
#import "User.h"
#import "Tweet.h"

@interface TweetViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) TwitterClient *twitterClient;
@property (strong, nonatomic) NSArray *tweets;
@property (weak, nonatomic) IBOutlet UITableView *tweetTableView;

@end

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.twitterClient = [TwitterClient sharedInstance];
    
    [self.twitterClient getHomeTimeline:^(NSArray *tweets) {
        //for (Tweet *tweet in tweets) {
            //NSLog(@"%@", tweet.text);
        //}
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
}

- (void)onLogoutButtonClick:(id)sender {
    [self.twitterClient logout];
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
    //cell.textLabel.text = tweet.text;
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
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:tweet.user.profileImageUrl]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        cell.profileImage.image = [UIImage imageWithData:data];
    }];
    return cell;
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
