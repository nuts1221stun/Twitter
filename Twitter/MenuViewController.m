//
//  MenuViewController.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 10/13/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "MenuViewController.h"
#import "TwitterClient.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@property (strong, nonatomic) NSArray *menuItems;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.menuTableView.delegate = self;
    self.menuTableView.dataSource = self;
    
    self.menuItems = @[
        @"home",
        @"profile",
        @"mentions"
    ];
    
    self.nameLabel.text = [TwitterClient sharedInstance].userId;
    self.screenNameLabel.text = [TwitterClient sharedInstance].userScreenName;
    
    /*
    [[TwitterClient sharedInstance] getUser:^(User *user) {
        NSLog(@"========%@ %@ %@", user.name, user.profileImageUrl, user.screenName);
        self.nameLabel.text = user.name;
        self.screenNameLabel.text = [TwitterClient sharedInstance].userScreenName;
    }];*/
    self.nameLabel.text = [User currentUser].name;
    self.screenNameLabel.text = [User currentUser].screenName;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[User currentUser].profileImageUrl]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        UIImage *downloadedImage = [UIImage imageWithData:data];
        self.profileImage.image = downloadedImage;
    }];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
