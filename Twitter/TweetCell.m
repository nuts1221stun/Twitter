//
//  TweetCell.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/24/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "TweetCell.h"

@implementation TweetCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)onProfileButtonClick:(id)sender {
    [self.delegate tweetCell:self didClickProfileButton:YES];
}
- (IBAction)onReplyButtonClick:(id)sender {
    [self.delegate tweetCell:self didClickReplyButton:YES];
}
- (IBAction)onRetweetButtonClick:(id)sender {
    [self.delegate tweetCell:self didClickRetweetButton:YES];
}
- (IBAction)onFavoriteButtonClick:(id)sender {
    [self.delegate tweetCell:self didClickFavoriteButton:YES];
}

@end
