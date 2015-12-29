//
//  TweetCell.h
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/24/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TweetCell;

@protocol TweetCellDelegate <NSObject>

- (void)tweetCell:(TweetCell *)cell didClickProfileButton:(BOOL)value;
- (void)tweetCell:(TweetCell *)cell didClickReplyButton:(BOOL)value;
- (void)tweetCell:(TweetCell *)cell didClickRetweetButton:(BOOL)value;
- (void)tweetCell:(TweetCell *)cell didClickFavoriteButton:(BOOL)value;

@end

@interface TweetCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *replayButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;



@property (weak, nonatomic) id<TweetCellDelegate> delegate;

@end
