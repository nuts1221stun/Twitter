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
    self.tweetId = [NSString stringWithFormat:@"%@", dictionary[@"id"]];
    self.createdAt = dictionary[@"created_at"];
    self.createdAt = [self parseDateStringToRelativeFormat:self.createdAt];
    self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
    self.text = dictionary[@"text"];
    self.retweetCount = [dictionary[@"retweet_count"] integerValue];
    self.favoriteCount = [dictionary[@"favorite_count"] integerValue];
    self.retweeted = [dictionary[@"retweeted"] boolValue];
    self.favorited = [dictionary[@"favorited"] boolValue];
    return self;
}

- (NSString *)parseDateStringToRelativeFormat:(NSString *)dateString {
    //Fri Sep 25 06:05:35 +0000 2015
    NSString *formattedDateString;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    NSCalendarUnit units = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units fromDate:date toDate:[NSDate date] options:0];
    NSString *plural;
    
    if (components.year > 0) {
        plural = (components.year > 1) ? @"s" : @"";
        formattedDateString = [NSString stringWithFormat:@"%ld year%@ ago", (long)components.year, plural];
    } else if (components.month > 0) {
        plural = (components.month > 1) ? @"s" : @"";
        formattedDateString = [NSString stringWithFormat:@"%ld month%@ ago", (long)components.month, plural];
    } else if (components.weekOfYear > 0) {
        plural = (components.weekOfYear > 1) ? @"s" : @"";
        formattedDateString = [NSString stringWithFormat:@"%ld week%@ ago", (long)components.weekOfYear, plural];
    } else if (components.day > 0) {
        plural = (components.day > 1) ? @"s" : @"";
        formattedDateString = [NSString stringWithFormat:@"%ld day%@ ago", (long)components.day, plural];
    } else if (components.hour > 0){
        plural = (components.hour > 1) ? @"s" : @"";
        formattedDateString = [NSString stringWithFormat:@"%ld hour%@ ago", (long)components.hour, plural];
    } else if (components.minute > 0){
        plural = (components.minute > 1) ? @"s" : @"";
        formattedDateString = [NSString stringWithFormat:@"%ld minute%@ ago", (long)components.minute, plural];
    } else if (components.second > 0){
        plural = (components.second > 1) ? @"s" : @"";
        formattedDateString = [NSString stringWithFormat:@"%ld second%@ ago", (long)components.second, plural];
    }

    return formattedDateString;
}

@end
