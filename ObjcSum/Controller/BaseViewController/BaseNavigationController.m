//
//  BaseNavigationController.m
//  MLLCustomer
//
//  Created by sihuan on 15/4/28.
//  Copyright (c) 2015年 Meilele. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setTranslucent:NO];
    
    UIColor *whiteColor = [UIColor whiteColor];
    
    self.navigationBar.barTintColor = ColorFlattingBlue;
    self.navigationBar.tintColor = whiteColor;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:whiteColor};
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    if (self.viewControllers.count == 1) {
        return self.statusBarStyle;
    }
        
    return self.topViewController.preferredStatusBarStyle;
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self setNeedsStatusBarAppearanceUpdate];
}
@end
