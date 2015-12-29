//
//  ProfileViewController.h
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 12/29/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil user:(User *)user;

@end
