//
//  User.h
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/19/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface User : NSObject

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSString *profileImageUrl;
@property (strong, nonatomic) NSString *profileBackgroundImageUrl;
@property (nonatomic) unsigned long tweetsCount;
@property (nonatomic) unsigned long followingCount;
@property (nonatomic) unsigned long followersCount;

- (id) initWithDictionary:(NSDictionary *)dictionary;

+ (User *)currentUser;
+ (void)setCurrentUser:(User *)currentUser;

@end
