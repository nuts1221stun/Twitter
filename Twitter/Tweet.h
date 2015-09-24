//
//  Tweet.h
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/19/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (strong, nonatomic) NSString *tweetId;
@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) NSString *text;
@property (nonatomic) long retweetCount;
@property (nonatomic) long favoriteCount;

@property (nonatomic) BOOL favorited;
@property (nonatomic) BOOL retweeted;

- (id) initWithDictionary:(NSDictionary *)dictionary;

@end
