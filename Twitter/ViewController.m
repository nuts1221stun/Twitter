//
//  ViewController.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 9/18/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "ViewController.h"
#import "Twitter.h"


@interface ViewController ()

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userName;

@property (strong, nonatomic) Twitter *twitter;

//@property (strong, nonatomic) NSString *authKey;

@end


@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.twitter = [[Twitter alloc] init];
        [self.twitter requestAuthToken];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.authKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"com.nuts.authkey"];

    NSString *authenticateUrl = [self.twitter getAuthenticateUrl];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authenticateUrl]];
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)backFromAuthentication:(NSString *)authVerifier {
    [self.twitter requestAccessToken: authVerifier];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
