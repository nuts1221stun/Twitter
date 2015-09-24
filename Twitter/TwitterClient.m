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
            self.loginCompletionHandler(user);
        }];
    }];
}

- (void)getUser:(void (^)(User *user))completionHandler {
    NSURLRequest *request = [self generateAuthorizedRequest:ACCOUNT_CREDENTIAL_URL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *userDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        User *user = [[User alloc] initWithDictionary:userDictionary];
        [User setCurrentUser:user];
        completionHandler(user);
    }];
}

- (void)getHomeTimeline:(void (^)(NSArray *tweets))completionHandler {
    NSURLRequest *request = [self generateAuthorizedRequest:HOME_TIMELINE_URL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        NSArray *tweetJsons = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        NSMutableArray *tweets = [[NSMutableArray alloc] init];
        for (NSDictionary *tweetJson in tweetJsons) {
            Tweet *tweet = [[Tweet alloc] initWithDictionary:tweetJson];
            [tweets addObject:tweet];
            //NSLog(@"%@", tweetJson);
        }
        
        completionHandler(tweets);

        //completionHandler(nil);

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
                self.userName = [elts objectAtIndex:1];
            }
        }
        
        NSMutableDictionary *accessTokenDictionary = [[NSMutableDictionary alloc] init];
        [accessTokenDictionary setObject:self.authAccessToken forKey:kAccessToken];
        [accessTokenDictionary setObject:self.authAccessTokenSecret forKey:kAccessTokenSecret];
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
            return dictionary;
        }
    }
    return nil;
}

- (void)removeAccessToken {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kAccessTokenDictionary];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSURLRequest *)generateAuthorizedRequest:(NSString *)url {
    NSMutableURLRequest *request;
    [self initAuthData:url shouldAddCallback:false shouldAddToken:true];
    
    NSString *header = [self generateRequestHeader];
    
    request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    
    return request;
}

- (void)requestAuthToken:(void (^)())completionHandler {
    [self initAuthData:REQUEST_TOKEN_URL shouldAddCallback:true shouldAddToken:false];
    
    NSString *requestTokenHeader;
    requestTokenHeader = [self generateRequestHeader];
    
    NSString *escapedCallbackUrl = [CALLBACK_URL stringByReplacingOccurrencesOfString: @":" withString:@"%3A"];
    escapedCallbackUrl = [escapedCallbackUrl stringByReplacingOccurrencesOfString: @"/" withString:@"%2F"];
    
    NSString *requestTokenUrl = [NSString stringWithFormat:@"%@?oauth_callback=%@", REQUEST_TOKEN_URL, escapedCallbackUrl];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestTokenUrl]];
    
    [request setValue:requestTokenHeader forHTTPHeaderField:@"Authorization"];
    //NSLog(@"request auth token: url=%@", requestTokenUrl);
    //NSLog(@"request auth token: header=%@", requestTokenHeader);
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"request auth token: response=%@", str);
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
    
    for (int i = 0; i < self.authData.count; i++) {
        if ([self.authDataName[i] isEqualToString:@"oauth_callback"]) {
            continue;
        }
        NSString *comma = (i == self.authData.count - 1) ? @"" : @", ";
        requestHeader = [NSString stringWithFormat:@"%@%@=\"%@\"%@", requestHeader, self.authDataName[i], self.authData[i], comma];
    }
    
    return requestHeader;
}

- (void)initAuthData:(NSString *)url shouldAddCallback:(BOOL)shouldAddCallback shouldAddToken:(BOOL)shouldAddToken {
    self.authData = [[NSMutableArray alloc] init];
    self.authDataName = [[NSMutableArray alloc] init];
    
    int signatureIndex = 2;
    
    if (shouldAddCallback) {
        NSString *escapedCallbackUrl = [CALLBACK_URL stringByReplacingOccurrencesOfString: @":" withString:@"%253A"];
        escapedCallbackUrl = [escapedCallbackUrl stringByReplacingOccurrencesOfString: @"/" withString:@"%252F"];
        [self.authDataName addObject:@"oauth_callback"];
        [self.authData addObject:escapedCallbackUrl];
        signatureIndex = 3;
    }
    
    [self.authDataName addObject:@"oauth_consumer_key"];
    [self.authData addObject:OAUTH_CONSUMER_KEY];
    
    [self.authDataName addObject:@"oauth_nonce"];
    [self.authData addObject:OAUTH_NONCE];
    
    [self.authDataName addObject:@"oauth_signature"];
    [self.authData addObject:@""];
    
    [self.authDataName addObject:@"oauth_signature_method"];
    [self.authData addObject:OAUTH_SIGNATURE_METHOD];
    
    [self.authDataName addObject:@"oauth_timestamp"];
    [self.authData addObject:[NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]]];
    
    if (shouldAddToken) {
        if (self.authAccessToken == nil) {
            NSDictionary *accessTokenDictionary = [self readAccessToken];
            self.authAccessToken = [accessTokenDictionary objectForKey:kAccessToken];
            self.authAccessTokenSecret = [accessTokenDictionary objectForKey:kAccessTokenSecret];
        }
        [self.authDataName addObject:@"oauth_token"];
        [self.authData addObject:self.authAccessToken];
    }
    
    [self.authDataName addObject:@"oauth_version"];
    [self.authData addObject:OAUTH_VERSION];
    
    
    NSString *signature = [self generateSignature: url];
    
    self.authData[signatureIndex] = signature;
}

- (NSString *)generateSignature:(NSString *)url {
    NSString *signatureBase = [NSString stringWithFormat:@"GET&%@", [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    for (int i = 0; i < self.authData.count; i++) {
        if ([self.authDataName[i] isEqualToString:@"oauth_signature"]) {
            continue;
        }
        NSString *amp = (i == 0) ? @"&" : @"%26";
        signatureBase = [NSString stringWithFormat:@"%@%@%@=%@", signatureBase, amp, self.authDataName[i], self.authData[i]];
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
