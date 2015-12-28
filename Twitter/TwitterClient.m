//
//  TwitterClient.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/19/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "TwitterClient.h"
#import "User.h"
#import "Tweet.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#include "Base64Transcoder.h"

#define CALLBACK_URL @"mobiletwitter://"
#define REQUEST_TOKEN_URL @"https://api.twitter.com/oauth/request_token"
#define AUTHENTICATE_URL @"https://api.twitter.com/oauth/authenticate"
#define ACCESS_TOKEN_URL @"https://api.twitter.com/oauth/access_token"
#define ACCOUNT_CREDENTIAL_URL @"https://api.twitter.com/1.1/account/verify_credentials.json"
#define HOME_TIMELINE_URL @"https://api.twitter.com/1.1/statuses/home_timeline.json"
#define TWEET_URL @"https://api.twitter.com/1.1/statuses/update.json"
#define RETWEET_URL @"https://api.twitter.com/1.1/statuses/retweet/:id.json"
#define CREATE_FAVORITE_URL @"https://api.twitter.com/1.1/favorites/create.json"
#define DESTROY_FAVORITE_URL @"https://api.twitter.com/1.1/favorites/destroy.json"

#define OAUTH_CONSUMER_KEY @"wpkhGTWAyFSk6Gt1N6dtWxe2S"
#define OAUTH_CONSUMER_SECRET @"GVRYWCiRwg4oQ644bc6cFNtloFqs5mh2FrQv4hcjk9Ov4zm1GK"
#define OAUTH_NONCE @"42a8aa0025e89a65672aa077359365b1"
#define OAUTH_SIGNATURE_METHOD @"HMAC-SHA1"
#define OAUTH_VERSION @"1.0"

NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";
NSString * const kAccessTokenDictionary = @"kAccessTokenDictionary";
NSString * const kAccessToken = @"kAccessToken";
NSString * const kAccessTokenSecret = @"kAccessTokenSecret";
NSString * const kUserId = @"kUserId";

@implementation NSString (NSString_Extended)
- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
@end

@interface TwitterClient ()
@property (strong, nonatomic) void (^loginCompletionHandler)();
@end

@implementation TwitterClient

+ (TwitterClient *)sharedInstance {
    static TwitterClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[TwitterClient alloc] init];
        }
    });
    return instance;
}

- (void)login:(void (^)(User *user))completionHandler {
    self.loginCompletionHandler = completionHandler;
    [self requestAuthToken:^{
        NSString *authenticateUrl = [self getAuthenticateUrl];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authenticateUrl]];
    }];
}

- (void)logout {
    [User setCurrentUser:nil];
    [self removeAccessToken];
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
}

- (void)openUrl:(NSURL *)url {
    NSString *urlString = [url absoluteString];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *authVerifier;
    for (NSString *param in [urlString componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
        NSString *key = [elts objectAtIndex:0];
        if ([key isEqualToString:@"oauth_verifier"]) {
            authVerifier = [elts objectAtIndex:1];
            break;
        }
    }
    [self requestAccessToken: authVerifier completionHandler:^{
        [self getUser:^(User *user) {
            if (user != nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:user];
            }
            self.loginCompletionHandler(user);
        }];
    }];
}

- (void)getUser:(void (^)(User *user))completionHandler {
    NSURLRequest *request = [self generateAuthorizedRequest:ACCOUNT_CREDENTIAL_URL withQuery:nil withMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *userDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        User *user = [[User alloc] initWithDictionary:userDictionary];
        [User setCurrentUser:user];
        completionHandler(user);
    }];
}

- (void)getHomeTimeline:(void (^)(NSArray *tweets))completionHandler {
    int count = 20;
    NSDictionary *q = @{
        @"count": @(count)
    };
    NSString *query = [NSString stringWithFormat:@"count=%d", count];
    
    NSMutableURLRequest *request = [[self generateAuthorizedRequest:HOME_TIMELINE_URL withQuery:q withMethod:@"GET"] mutableCopy];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", HOME_TIMELINE_URL, query]]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        id tweetDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        if (![tweetDictionary isKindOfClass:[NSArray class]]) {
            completionHandler(nil);
            return;
        }

        NSArray *tweetJsons = (NSArray *)tweetDictionary;
        NSMutableArray *tweets = [[NSMutableArray alloc] init];
        for (NSDictionary *tweetJson in tweetJsons) {
            Tweet *tweet = [[Tweet alloc] initWithDictionary:tweetJson];
            [tweets addObject:tweet];
        }
        
        completionHandler(tweets);
    }];
}

- (void)tweet:(NSString *)status completionHandler:(void (^)())completionHandler {
    status = [status urlencode];
    
    NSString *whiteSpaceStatus = [status stringByReplacingOccurrencesOfString: @"+" withString:@"%20"];

    NSDictionary *q = @{
        @"status": whiteSpaceStatus
    };
    NSString *query = [NSString stringWithFormat:@"status=%@", status];
    NSMutableURLRequest *request = [[self generateAuthorizedRequest:TWEET_URL withQuery:q withMethod:@"POST"] mutableCopy];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [query dataUsingEncoding:NSUTF8StringEncoding];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        //NSDictionary *favoriteJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        //NSLog(@"%@", favoriteJson);
        completionHandler();
    }];
}

- (void)replyToTweet:(NSString *)tweetId tweetAuthorScreenName:(NSString *)author withStatus:(NSString *)status completionHandler:(void (^)())completionHandler {
    status = [NSString stringWithFormat:@"@%@ %@", author, status];
    status = [status urlencode];
    
    NSString *whiteSpaceStatus = [status stringByReplacingOccurrencesOfString: @"+" withString:@"%20"];
    
    NSDictionary *q = @{
        @"status": whiteSpaceStatus,
        @"in_reply_to_status_id": tweetId
    };
    NSString *query = [NSString stringWithFormat:@"in_reply_to_status_id=%@&status=%@", tweetId, status];
    NSMutableURLRequest *request = [[self generateAuthorizedRequest:TWEET_URL withQuery:q withMethod:@"POST"] mutableCopy];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [query dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        //NSDictionary *favoriteJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        //NSLog(@"%@", favoriteJson);
        completionHandler();
    }];
}

- (void)retweet:(NSString *)tweetId completionHandler:(void (^)())completionHandler {
    NSString *url = [RETWEET_URL stringByReplacingOccurrencesOfString: @":id" withString:tweetId];
    NSMutableURLRequest *request = [[self generateAuthorizedRequest:url withQuery:nil withMethod:@"GET"] mutableCopy];
    request.HTTPMethod = @"GET";

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *favoriteJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"%@", favoriteJson);
        completionHandler();
    }];
}

- (void)favorite:(NSString *)tweetId completionHandler:(void (^)())completionHandler {
    NSDictionary *q = @{
        @"id": tweetId
    };
    NSString *query = [NSString stringWithFormat:@"id=%@", tweetId];
    NSMutableURLRequest *request = [[self generateAuthorizedRequest:CREATE_FAVORITE_URL withQuery:q withMethod:@"POST"] mutableCopy];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [query dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        //NSDictionary *favoriteJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        //NSLog(@"%@", favoriteJson);
        completionHandler();
    }];
}

- (void)unFavorite:(NSString *)tweetId completionHandler:(void (^)())completionHandler {
    NSDictionary *q = @{
        @"id": tweetId
    };
    NSString *query = [NSString stringWithFormat:@"id=%@", tweetId];
    NSMutableURLRequest *request = [[self generateAuthorizedRequest:DESTROY_FAVORITE_URL withQuery:q withMethod:@"POST"] mutableCopy];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [query dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        //NSDictionary *favoriteJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        //NSLog(@"%@", favoriteJson);
        completionHandler();
    }];
}

- (NSString *)getAuthenticateUrl {
    NSString *callbackUrl = CALLBACK_URL;
    NSString *authenticateUrl = [NSString stringWithFormat:@"%@?oauth_token=%@&oauth_callback=%@", AUTHENTICATE_URL, self.authToken, callbackUrl];
    return authenticateUrl;
}

- (void)requestAccessToken:(NSString *)authVerifier completionHandler:(void (^)())completionHandler {
    self.authVerifier = authVerifier;
    NSString *accessTokenUrl = [NSString stringWithFormat:@"%@?oauth_token=%@&oauth_verifier=%@", ACCESS_TOKEN_URL, self.authToken, self.authVerifier];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:accessTokenUrl]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        for (NSString *param in [str componentsSeparatedByString:@"&"]) {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if([elts count] < 2) continue;
            [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
            NSString *key = [elts objectAtIndex:0];
            if ([key isEqualToString:@"oauth_token"]) {
                self.authAccessToken = [elts objectAtIndex:1];
            }
            if ([key isEqualToString:@"oauth_token_secret"]) {
                self.authAccessTokenSecret = [elts objectAtIndex:1];
            }
            if ([key isEqualToString:@"user_id"]) {
                self.userId = [elts objectAtIndex:1];
            }
            if ([key isEqualToString:@"screen_name"]) {
                self.userScreenName = [elts objectAtIndex:1];
            }
        }
        
        NSMutableDictionary *accessTokenDictionary = [[NSMutableDictionary alloc] init];
        [accessTokenDictionary setObject:self.authAccessToken forKey:kAccessToken];
        [accessTokenDictionary setObject:self.authAccessTokenSecret forKey:kAccessTokenSecret];
        [accessTokenDictionary setObject:self.userId forKey:kUserId];
        [self storeAccessToken:accessTokenDictionary];
        
        completionHandler();
    }];
}

- (void)storeAccessToken:(NSDictionary *)accessTokenDictionary {
    NSData *data = [NSJSONSerialization dataWithJSONObject:accessTokenDictionary options:0 error:NULL];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kAccessTokenDictionary];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)readAccessToken {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenDictionary];
    if (data != nil) {
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        if ([dictionary objectForKey:kAccessToken] != nil && [dictionary objectForKey:kAccessTokenSecret] != nil) {
            NSString *userId = [dictionary objectForKey:kUserId];
            if (userId) {
                self.userId = userId;
            }
            return dictionary;
        }
    }
    return nil;
}

- (void)removeAccessToken {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kAccessTokenDictionary];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSURLRequest *)generateAuthorizedRequest:(NSString *)url withQuery:(NSDictionary *)query withMethod:(NSString *)method {
    NSMutableURLRequest *request;

    NSString *signatureBase = [NSString stringWithFormat:@"%@&%@", method, url];

    if (self.authAccessToken == nil) {
        NSDictionary *accessTokenDictionary = [self readAccessToken];
        self.authAccessToken = [accessTokenDictionary objectForKey:kAccessToken];
        self.authAccessTokenSecret = [accessTokenDictionary objectForKey:kAccessTokenSecret];
    }
    NSMutableDictionary *q = [[NSMutableDictionary alloc] init];
    if (query != nil) {
        [q setValuesForKeysWithDictionary:query];
    }
    [q setValue:self.authAccessToken forKey:@"oauth_token"];
    
    [self initAuthData:signatureBase query:q];
    
    NSString *header = [self generateRequestHeader];
    
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    
    return request;
}

- (void)requestAuthToken:(void (^)())completionHandler {
    NSString *signatureBase = [NSString stringWithFormat:@"GET&%@", REQUEST_TOKEN_URL];
    
    NSString *escapedCallbackUrl = [CALLBACK_URL stringByReplacingOccurrencesOfString: @":" withString:@"%253A"];
    escapedCallbackUrl = [escapedCallbackUrl stringByReplacingOccurrencesOfString: @"/" withString:@"%252F"];
    NSDictionary *query = @{
        @"oauth_callback": escapedCallbackUrl
    };
    [self initAuthData:signatureBase query:query];
    
    NSString *requestTokenHeader;
    requestTokenHeader = [self generateRequestHeader];
    
    escapedCallbackUrl = [CALLBACK_URL stringByReplacingOccurrencesOfString: @":" withString:@"%3A"];
    escapedCallbackUrl = [escapedCallbackUrl stringByReplacingOccurrencesOfString: @"/" withString:@"%2F"];
    
    NSString *requestTokenUrl = [NSString stringWithFormat:@"%@?oauth_callback=%@", REQUEST_TOKEN_URL, escapedCallbackUrl];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestTokenUrl]];
    
    [request setValue:requestTokenHeader forHTTPHeaderField:@"Authorization"];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self parseAuthTokenAndTokenSecretFromString:str];
        completionHandler();
    }];
}

- (void)parseAuthTokenAndTokenSecretFromString:(NSString *)string {
    NSError *error = nil;
    NSString *pattern = @"oauth_token=([^&]*)&oauth_token_secret=([^&]*)&oauth_callback_confirmed=(true|false)";
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    
    NSArray *matches = [reg matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match rangeAtIndex:1];
        self.authToken = [string substringWithRange:matchRange];
        matchRange = [match rangeAtIndex:2];
        self.authTokenSecret = [string substringWithRange:matchRange];
    }
}

- (NSString *)generateRequestHeader {
    NSString *requestHeader = @"OAuth ";
    
    NSArray *sortedKeys = [[self.authDataDictionary allKeys] sortedArrayUsingSelector: @selector(compare:)];
    
    for (int i = 0; i < sortedKeys.count; i++) {
        NSString *key = sortedKeys[i];
        if ([key isEqualToString:@"oauth_callback"]) {
            continue;
        }
        NSString *comma = (i == sortedKeys.count - 1) ? @"" : @", ";
        requestHeader = [NSString stringWithFormat:@"%@%@=\"%@\"%@", requestHeader, key, [self.authDataDictionary valueForKey:key], comma];
    }
    
    return requestHeader;
}

- (void)initAuthData:(NSString *)url query:(NSDictionary *)query {
    self.authDataDictionary = [[NSMutableDictionary alloc] init];
    
    [self.authDataDictionary setValue:OAUTH_CONSUMER_KEY forKey:@"oauth_consumer_key"];
    
    [self.authDataDictionary setValue:OAUTH_NONCE forKey:@"oauth_nonce"];
    
    [self.authDataDictionary setValue:OAUTH_SIGNATURE_METHOD forKey:@"oauth_signature_method"];

    [self.authDataDictionary setValue:[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]] forKey:@"oauth_timestamp"];

    [self.authDataDictionary setValue:OAUTH_VERSION forKey:@"oauth_version"];
    
    [self.authDataDictionary setValuesForKeysWithDictionary:query];

    NSString *signature = [self generateSignature: url];
    
    [self.authDataDictionary setValue:signature forKey:@"oauth_signature"];
}

- (NSString *)generateSignature:(NSString *)url {
    NSString *signatureBase = [NSString stringWithFormat:@"%@", [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSArray *sortedKeys = [[self.authDataDictionary allKeys] sortedArrayUsingSelector: @selector(compare:)];
    
    for (int i = 0; i < sortedKeys.count; i++) {
        NSString *key = sortedKeys[i];
        NSString *data = [self.authDataDictionary valueForKey:key];
        if ([key isEqualToString:@"oauth_signature"]) {
            continue;
        }
        NSString *amp = (i == 0) ? @"&" : @"%26";
        if ([key isEqualToString:@"status"]) {
            data = [data urlencode];
        }
        signatureBase = [NSString stringWithFormat:@"%@%@%@=%@", signatureBase, amp, key, data];
    }
    
    signatureBase = [signatureBase stringByReplacingOccurrencesOfString: @":" withString:@"%3A"];
    signatureBase = [signatureBase stringByReplacingOccurrencesOfString: @"/" withString:@"%2F"];
    signatureBase = [signatureBase stringByReplacingOccurrencesOfString: @"=" withString:@"%3D"];
    
    if (!self.authAccessTokenSecret) {
        self.authAccessTokenSecret = @"";
    }
    NSString *signingKey = [NSString stringWithFormat:@"%@&%@", OAUTH_CONSUMER_SECRET, self.authAccessTokenSecret];
    NSString *signature =[self hmacsha1:signatureBase key:signingKey];
    
    signature = [signature urlencode];

    return signature;
}

- (NSString *)hmacsha1:(NSString *)text key:(NSString *)secret {
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
    CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSASCIIStringEncoding];
    
    return base64EncodedResult;
}


@end
