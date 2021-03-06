//
//  FastRecordController.m
//  MLLSalesAssistant
//
//  Created by sihuan on 15/9/28.
//  Copyright © 2015年 Meilele. All rights reserved.
//

#import "FastRecordController.h"
#import "FastRecordListController.h"
#import "FastRecordAddAndModifyController.h"
#import "UIViewController+Extension.h"

#define SINGLE_LINE_WIDTH           (1 / [UIScreen mainScreen].scale)
#define SINGLE_LINE_ADJUST_OFFSET   ((1 / [UIScreen mainScreen].scale) / 2)

@interface FastRecordController ()

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *topSectionView;

@property (strong, nonatomic) UIView *indicatorView;
@property (strong, nonatomic) UIView *bottomLineView;

@end

@implementation FastRecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self envInit];
}

#pragma mark - private
- (void)envInit {
    
    self.title = @"随手记";
    _leftButton.tag = FastRecordTypeCustomer;
    _rightButton.tag = FastRecordTypePersonal;
    _leftButton.enabled = NO;
    
    [_rightButton setTitleColor:ColorFromRGBHex(0x666666) forState:UIControlStateNormal];
    [_rightButton setTitleColor:Color_0fb1ba forState:UIControlStateDisabled];
    
    [_leftButton setTitleColor:ColorFromRGBHex(0x666666) forState:UIControlStateNormal];
    [_leftButton setTitleColor:Color_0fb1ba forState:UIControlStateDisabled];
    
    
    [_headerView addSubview:self.bottomLineView];
    self.bottomLineView.frame = CGRectMake(0, CGRectGetHeight(_headerView.bounds)-SINGLE_LINE_ADJUST_OFFSET, CGRectGetWidth([UIScreen mainScreen].bounds), SINGLE_LINE_WIDTH);
    
    [_headerView addSubview:self.indicatorView];
    _headerView.clipsToBounds = NO;
    self.indicatorView.frame = CGRectMake(0, CGRectGetHeight(_headerView.bounds)-1.5, CGRectGetWidth([UIScreen mainScreen].bounds)/2, 1.5);
    self.indicatorView.clipsToBounds = NO;
    
    self.view.backgroundColor = Color_f4f4f4;
    
    UIImage *image = [UIImage imageNamed:@"fastRecordAdd"];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(userDidTapRightMenuItem:)];
    
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    FastRecordListController *customer = [FastRecordListController instanceFromStortyboard];
    customer.fastRecordType = FastRecordTypeCustomer;
    
    [self addChildViewController:customer];
    [self.containerView addSubview:customer.view];
    
    FastRecordListController *personal = [FastRecordListController instanceFromStortyboard];
    personal.fastRecordType = FastRecordTypePersonal;
    [self addChildViewController:personal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavagationBarTheme:NavigationControllerBarThemeTypeWhite];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.barThemeType == NavigationControllerBarThemeTypeGreen) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.view.frame = self.containerView.bounds;
    }];
}

- (UIView *)indicatorView {
    if (!_indicatorView) {
        UIView *view = [UIView new];
        view.backgroundColor = Color_31bdc4;
        _indicatorView = view;
    }
    return _indicatorView;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        UIView *view = [UIView new];
        view.backgroundColor = Color_d8d8d8;
        _bottomLineView = view;
    }
    return _bottomLineView;
}



- (IBAction)headerButtonDidClicked:(UIButton *)sender {
    sender.enabled = NO;
    switch (sender.tag) {
        case FastRecordTypeCustomer:
            _rightButton.enabled = YES;
            break;
        case FastRecordTypePersonal:
            _leftButton.enabled = YES;
            break;
    }
    [self changeIndicatorViewLocation:sender];
    [self changeFrom:!sender.tag to:sender.tag];
}

#pragma mark - callback

- (void)userDidTapRightMenuItem:(id)sender {
    [FastRecordAddAndModifyController presentFromViewController:self];
}


- (void)changeIndicatorViewLocation:(UIView *)alignView {
    CGPoint center = _indicatorView.center;
    center.x = alignView.center.x;
    [UIView animateWithDuration:0.3 animations:^{
        _indicatorView.center = center;
    }];
}

- (void)changeFrom:(NSInteger)from to:(NSInteger)to
{
    UIViewAnimationOptions option;
    if (to == 1) {
        option = UIViewAnimationOptionTransitionNone;
    } else {
        option = UIViewAnimationOptionTransitionNone;
    }
    [self transFrom:from to:to options:option];
}

- (void)transFrom:(NSInteger)from to:(NSInteger)to options:(UIViewAnimationOptions)option
{
    [self transitionFromViewController:self.childViewControllers[from] toViewController:self.childViewControllers[to] duration:0.6 options:option animations:^{
    } completion:^(BOOL finished) {

    }];
}

#pragma mark - Public
+ (void)pushFromViewController:(UIViewController *)vc {
    UIViewController *fastRecordVc = [[UIStoryboard storyboardWithName:@"FastRecord" bundle:nil] instantiateInitialViewController];
    [vc.navigationController pushViewController:fastRecordVc animated:YES];
}

@end
