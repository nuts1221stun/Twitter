//
//  MainViewController.m
//  Twitter
//
//  Created by Li-Erh å¼µåŠ›å…’ Chang on 12/29/15.
//  Copyright (c) 2015 Li-Erh Chang. All rights reserved.
//

#import "MainViewController.h"
#import "MenuViewController.h"
#import "TweetTableViewController.h"
#import "ProfileViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) TweetTableViewController *tweetTableViewController;
@property (strong, nonatomic) MenuViewController *menuViewController;
@property (strong, nonatomic) ProfileViewController *profileViewController;

@end

@implementation MainViewController

float const kMenuWidth = 300.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpMenu];
    [self setUpTable];
}

- (void)setUpTable {
    self.tweetTableViewController = [[TweetTableViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.tweetTableViewController];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.6745098 blue:0.9294118 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    [self addChildViewController:self.navigationController];
    self.tweetTableViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.navigationController.view];
    [self.navigationController didMoveToParentViewController:self];
}

- (void)setUpMenu {
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    
    [self.view addGestureRecognizer:panRecognizer];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    float navBarHeight = self.navigationController.navigationBar.frame.size.height + 20;
    
    self.menuViewController = [[MenuViewController alloc] init];
    [self.menuViewController setUpMainViewController:self];
    [self addChildViewController:self.menuViewController];
    self.menuViewController.view.frame = CGRectMake(0, navBarHeight, kMenuWidth, screenHeight - navBarHeight);
    [self.view addSubview:self.menuViewController.view];
    [self.menuViewController didMoveToParentViewController:self];
    [self.view bringSubviewToFront:self.menuViewController.view];
}


- (void)movePanel:(UIPanGestureRecognizer *)sender {
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        if(velocity.x > 0) {
            [self showMenu];
        } else {
            //NSLog(@"pan to left");
        }
    }
    
    // collapse menu
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            [self hideMenu];
        }
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {    }
}

- (void)showMenu {
    if (self.navigationController.view.frame.origin.x < kMenuWidth) {
        self.navigationController.view.center = CGPointMake(self.navigationController.view.center.x + kMenuWidth, self.navigationController.view.center.y);
    }
}

- (void)hideMenu {
    if (self.navigationController.view.frame.origin.x > 0) {
        self.navigationController.view.center = CGPointMake(self.navigationController.view.center.x - kMenuWidth, self.navigationController.view.center.y);
    }
}

- (void)showHomePage {
    [self hideMenu];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showProfile {
    [self hideMenu];
    NSArray *viewControllers = [self.navigationController viewControllers];
    if (self.profileViewController == nil) {
        self.profileViewController = [[ProfileViewController alloc] init];
    }
    
    for (int i; i < [viewControllers count]; i++) {
        if ([self.profileViewController isEqual:viewControllers[i]]) {
            [self.navigationController popToViewController:self.profileViewController animated:YES];
            return;
        }
    }
    [self.navigationController pushViewController:self.profileViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
