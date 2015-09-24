//
//  Tweet.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/19/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id) initWithDictionary:(NSDictionary *)dictionary {
    self.tweetId = dictionary[@"id"];
    self.createdAt = dictionary[@"created_at"];
    self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
    self.text = dictionary[@"text"];
    self.retweetCount = [dictionary[@"retweet_count"] integerValue];
    self.favoriteCount = [dictionary[@"favorite_count"] integerValue];
    self.retweeted = [dictionary[@"retweeted"] boolValue];
    self.favorited = [dictionary[@"favorited"] boolValue];
    return self;
}

@end
