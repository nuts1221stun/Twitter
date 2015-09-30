//
//  ComposeViewController.h
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/24/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

extern NSString * const TWEET;
extern NSString * const RETWEET;
extern NSString * const REPLY;

@interface ComposeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *composeView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *editableTextView;

@property (strong, nonatomic) NSString *state;

- (instancetype)initWithNibNameAsTweetState:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (instancetype)initWithNibNameAsReplyState:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil replyingTweet:(Tweet *)tweet;

@end
