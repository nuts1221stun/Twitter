//
//  MenuViewController.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 10/13/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "MenuViewController.h"
#import "TweetTableViewController.h"
#import "TwitterClient.h"


@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@property (strong, nonatomic) NSArray *menuItems;

@property (strong, nonatomic) MainViewController *mainVC;
@property (strong, nonatomic) TweetTableViewController *tweetTableVC;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    
    self.menuItems = @[
        @"home",
        @"profile",
        @"mentions",
        @"logout"
    ];
    
    self.nameLabel.text = [User currentUser].name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", [User currentUser].screenName];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[User currentUser].profileImageUrl]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        UIImage *downloadedImage = [UIImage imageWithData:data];
        self.profileImage.image = downloadedImage;
    }];
}

- (void)setUpMainViewController:(MainViewController *)mainVC {
    self.mainVC = mainVC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"menuCell"];
    }
    cell.textLabel.text = self.menuItems[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 0) {
        [self.mainVC showHomePage];
    }
    if (indexPath.row == 1) {
        [self.mainVC showProfile];
    }
    if (indexPath.row == 3) {
        [[TwitterClient sharedInstance] logout];
    }
    // [self.navigationController pushViewController:tweetVC animated:YES];
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
