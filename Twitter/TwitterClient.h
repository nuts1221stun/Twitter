//
//  TwitterClient.h
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/19/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "User.h"


extern NSString * const UserDidLoginNotification;
extern NSString * const UserDidLogoutNotification;

@interface TwitterClient : NSObject

@property (strong, nonatomic) NSDictionary *authDataDictionary;
@property (strong, nonatomic) NSMutableArray *authData;
@property (strong, nonatomic) NSMutableArray *authDataName;
@property (strong, nonatomic) NSString *authToken;
@property (strong, nonatomic) NSString *authTokenSecret;
@property (strong, nonatomic) NSString *authAccessToken;
@property (strong, nonatomic) NSString *authAccessTokenSecret;
@property (strong, nonatomic) NSString *authVerifier;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userName;


+ (TwitterClient *)sharedInstance;

- (void)login:(void (^)(User *user))completionHandler;
- (void)logout;
- (void)openUrl:(NSURL *)url;
- (void)getHomeTimeline:(void (^)(NSArray *tweets))completionHandler;
- (void)tweet:(NSString *)status completionHandler:(void (^)())completionHandler;
- (void)replyToTweet:(NSString *)tweetId tweetAuthorScreenName:(NSString *)author withStatus:(NSString *)status completionHandler:(void (^)())completionHandler;
- (void)retweet:(NSString *)tweetId completionHandler:(void (^)())completionHandler;
- (void)favorite:(NSString *)tweetId completionHandler:(void (^)())completionHandler;
- (void)unFavorite:(NSString *)tweetId completionHandler:(void (^)())completionHandler;

@end
