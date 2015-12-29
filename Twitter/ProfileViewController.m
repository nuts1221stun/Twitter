//
//  ProfileViewController.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 12/29/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@property (strong, nonatomic) User *user;

@end

@implementation ProfileViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *)user {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.user = user;
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.text = self.user.name;
    self.screenNameLabel.text =  [NSString stringWithFormat:@"@%@", self.user.screenName];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.user.profileImageUrl]];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
