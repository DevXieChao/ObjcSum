//
//  FastRecordAddAndModifyController.m
//  MLLSalesAssistant
//
//  Created by sihuan on 15/9/28.
//  Copyright © 2015年 Meilele. All rights reserved.
//

#import "FastRecordAddAndModifyController.h"
#import "BaseNavigationController.h"
#import "UIViewController+Extension.h"
#import "UILocalNotification+YYExtention.h"
#import "UIViewController+UMStatistic.h"

#import "FastRecordModel.h"
#import "FastRecordCellModel.h"
#import "FastRecordTitleCell.h"
#import "FastRecordTextInputCell.h"
#import "FastRecordVoiceCell.h"
#import "FastRecordImageCell.h"
#import "FastRecordClockCell.h"
#import "FastRecordCustomerCell.h"

#import "YYHud.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "DNImagePickerController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

@interface FastRecordAddAndModifyController ()<FastRecordCellActionDelegate, DNImagePickerControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

//是否处于编辑中，修改随手记时使用
@property (nonatomic, assign) BOOL isEditing;

@end

@implementation FastRecordAddAndModifyController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self envInit];
//    [self setDefaultBackBarButtonItem];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private
- (void)envInit {
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;

    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(userDidTapRightMenuItem:)];
    rightBarButtonItem.tintColor = Color_31bdc4;
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(userDidTapLeftMenuItem:)];
    leftBarButtonItem.tintColor = [UIColor lightGrayColor];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    if (self.isAdd) {
        self.title = @"新建随手记";
        
    } else {
        self.title = @"随手记详情";
        self.isEditing = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fastRecordTextInputCellTextViewDidChangedHeigth) name:FastRecordTextInputCellTextViewDidChangedHeigthNotification object:nil];
}

- (void)fastRecordTextInputCellTextViewDidChangedHeigth {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:FastRecordActionTypeVoice] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setIsEditing:(BOOL)isEditing {
    _isEditing = isEditing;
    self.view.userInteractionEnabled = isEditing;
    self.navigationItem.rightBarButtonItem.title = isEditing ? @"完成" : @"编辑";
}

- (NSString *)getCellIdentifierAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case FastRecordActionTypeTitle: {
            return @"FastRecordTitleCell";
        }
        case FastRecordActionTypeText: {
            return @"FastRecordTextInputCell";
        }
        case FastRecordActionTypeVoice: {
            return @"FastRecordVoiceCell";
        }
        case FastRecordActionTypeImage: {
            return @"FastRecordImageCell";
        }
        case FastRecordActionTypeClock: {
            return @"FastRecordClockCell";
        }
        case FastRecordActionTypeCusomer: {
            return @"FastRecordCustomerCell";
        }
    }
    return @"FastRecordCustomerCell";
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return FastRecordActionTypeCusomer+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRowsInSection = 0;
    switch (section) {
        case FastRecordActionTypeTitle: {
            numberOfRowsInSection = 1;
            break;
        }
        case FastRecordActionTypeText: {
            if (_fastRecordCellModel.recordVoicePath == nil) {
                numberOfRowsInSection = 1;
            }
//            numberOfRowsInSection = 1;
            break;
        }
        case FastRecordActionTypeVoice: {
            if (_fastRecordCellModel.recordVoicePath) {
                numberOfRowsInSection = 1;
            }
            break;
        }
        case FastRecordActionTypeImage: {
            numberOfRowsInSection = _fastRecordCellModel.recordImages.count;
            break;
        }
        case FastRecordActionTypeClock: {
            numberOfRowsInSection = 1;
            break;
        }
        case FastRecordActionTypeCusomer: {
            if (_fastRecordCellModel.type == FastRecordTypeCustomer) {
                numberOfRowsInSection = 1;
            }
            
            break;
        }
            
        default:
            break;
    }
    return numberOfRowsInSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    switch (indexPath.section) {
        case FastRecordActionTypeTitle: {
            height = 75;
            break;
        }
        case FastRecordActionTypeText: {
            height = [tableView fd_heightForCellWithIdentifier:NSStringFromClass([FastRecordTextInputCell class]) configuration:^(FastRecordTextInputCell *cell) {
                [cell updateUI:_fastRecordCellModel atIndexpath:indexPath];
            }];
            break;
        }
        case FastRecordActionTypeVoice: {
            height = 50;
            break;
        }
        case FastRecordActionTypeImage: {
            height = [tableView fd_heightForCellWithIdentifier:NSStringFromClass([FastRecordImageCell class]) configuration:^(FastRecordImageCell *cell) {
                [cell updateUI:_fastRecordCellModel atIndexpath:indexPath];
            }];
            break;
        }
        case FastRecordActionTypeClock: {
//            height = _fastRecordCellModel.recordImages.count > 0 ? 68 : 143;
            height = 143;
            break;
        }
        case FastRecordActionTypeCusomer: {
            if (_fastRecordCellModel.type == FastRecordTypeCustomer) {
                height = 49;
            }
            
            break;
        }
            
        default:
            break;
    }

    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = [self getCellIdentifierAtIndexPath:indexPath];
    FastRecordBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.tableView = tableView;
    cell.delegate = self;
    [cell updateUI:_fastRecordCellModel atIndexpath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == FastRecordActionTypeImage) {
//        [self showImagePicker];
    } else if (indexPath.section == FastRecordActionTypeCusomer) {
    }
}

#pragma mark - FastRecordCellActionDelegate

- (void)fastRecordCell:(UITableViewCell *)cell didClicked:(FastRecordActionType)actionType atIndexpath:(NSIndexPath *)indexPath withObject:(id)obj {
    switch (actionType) {
        case FastRecordActionTypeTitle: {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:FastRecordActionTypeCusomer] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        case FastRecordActionTypeText: {

            break;
        }
        case FastRecordActionTypeVoice: {//语音删除或添加
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(FastRecordActionTypeText, 2)] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        case FastRecordActionTypeImage: {//点击+号选择图片
            [self showActionSheet];
            break;
        }
        case FastRecordActionTypeClock: {

            break;
        }
        case FastRecordActionTypeCusomer: {

            
            break;
        }
    }
}

- (void)showActionSheet {
    [self.view endEditing:YES];
    
    if (_fastRecordCellModel.recordImages.count >= 5) {
        [YYHud showTip:@"最多上传5张照片哦!"];
        return;
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选图片", nil];
    sheet.tintColor = [UIColor blackColor];
    [sheet showInView:self.view];
}

#pragma mark - Add Picture
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self addCarema];
    }else if (buttonIndex == 1){
        [self showImagePicker];
    }
}

- (void)addCarema {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:picker animated:YES completion:NULL];
        });
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有找到相机" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)showImagePicker {
    DNImagePickerController *imagePicker = [[DNImagePickerController alloc] init];
    imagePicker.filterType = DNImagePickerFilterTypePhotos;
    imagePicker.imagePickerDelegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - DNImagePickerControllerDelegate

- (void)dnImagePickerController:(DNImagePickerController *)imagePicker sendImages:(NSArray *)imageAssets isFullImage:(BOOL)fullImage {
    NSMutableArray *images = [NSMutableArray array];
    
//    if (imageAssets.count > 5) {
//        [YYHud showTip:@"最多上传5张照片哦!"];
//    }
    int i = 0;
    for (ALAsset *asset in imageAssets) {
        if (i++ >= 5) {
            break;
        }
        UIImage *image = [UIImage imageWithCGImage:[asset defaultRepresentation].fullScreenImage];
        [images addObject:image];
    }
    
    [self addImages:images];
}

- (void)dnImagePickerControllerDidCancel:(DNImagePickerController *)imagePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)addImages:(NSArray *)imagesArr {
    if (_fastRecordCellModel.recordImages.count >= 5) {
        [YYHud showTip:@"最多上传5张照片哦!"];
        return;
    }
    
    NSInteger i = _fastRecordCellModel.recordImages.count;
    
    for (UIImage *image in imagesArr) {
        [_fastRecordCellModel.recordImages addObject:image];
        if (++i >= 5) {
            [YYHud showTip:@"最多上传5张照片哦!"];
            break;
        }
    }
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(FastRecordActionTypeImage, 2)] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:^{
        if (editImage) {
            [self addImages:@[editImage]];
        }
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - actions

- (void)userDidTapLeftMenuItem:(id)sender {
    [self dismiss];
}

- (void)userDidTapRightMenuItem:(id)sender {
    
    //编辑切换判断
    if (!self.isAdd && _isEditing == NO) {
        self.isEditing = YES;
        self.title = @"编辑随手记";
        return;
    }
    
    if (_fastRecordCellModel.type == FastRecordTypeCustomer) {
        if (_fastRecordCellModel.customerId == nil || _fastRecordCellModel.customerName == nil) {
            [YYHud showTip:@"客户不能为空"];
            return;
        }
    }
    
    if (_fastRecordCellModel.recordText.length > 200) {
        _fastRecordCellModel.recordText = [_fastRecordCellModel.recordText substringToIndex:200];
        [YYHud showTip:@"请将随手记内容保持在200个字以内"];
        return;
    }
    
    [self saveToCoreDate];
}

- (void)saveToCoreDate{
    if (self.isAdd) {//新建保存
        if (!_fastRecordModel) {
            FastRecordModel *newEntity = [NSEntityDescription insertNewObjectForEntityForName:@"FastRecordModel" inManagedObjectContext:[FastRecord shareInstance].managedObjectContext];
            _fastRecordModel = newEntity;
            _fastRecordCellModel.managedObjectID =  [[newEntity objectID] URIRepresentation].absoluteString;
        }
        
    }
  
    _fastRecordCellModel.recordDate = [NSDate date];
    if ([FastRecord updateEntity:_fastRecordModel withValue:_fastRecordCellModel]) {
        if (_didCompletedBlock) {
            _didCompletedBlock(_fastRecordModel, _fastRecordCellModel);
        }
        [self setLocalNotification];
        [self dismiss];
    } else {
        //保存失败
        [self showError];
    }
    
    
}

- (void)dismiss {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self dismissViewControllerAnimated:YES completion:nil];
//    });
}

- (void)showError {
    [YYHud showTip:@"保存失败!"];
}

#pragma mark - 设置本地通知

- (void)setLocalNotification {
    [UILocalNotification cancelLocalNotificationWithKey:_fastRecordCellModel.managedObjectID];
    [self addLocalNotificationWith:_fastRecordCellModel.managedObjectID];
}


- (void)addLocalNotificationWith:(NSString *)key {
    if (!_fastRecordCellModel.clockDate) {
        return;
    }
    
    if ([_fastRecordCellModel.clockDate compare:[NSDate date]] != NSOrderedDescending) {
        return;
    }
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    NSDate *fireDate = _fastRecordCellModel.clockDate;
    
    notification.fireDate = fireDate;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.repeatInterval = 0;
    notification.alertBody = _fastRecordCellModel.recordText;
    notification.soundName = UILocalNotificationDefaultSoundName;
//    notification.soundName = AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.2) {
        notification.alertTitle = _fastRecordCellModel.title;
    }
    
    NSDictionary *value = @{
                            @"title":_fastRecordCellModel.title,
                            @"message":_fastRecordCellModel.recordText == nil ? @"" : _fastRecordCellModel.recordText
                            };
    // 通知参数
    NSDictionary *userDict = @{key:value};
    notification.userInfo = userDict;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark - Public
/*
 新建用present
 */
+ (void)presentFromViewController:(UIViewController *)fromVc {
    FastRecordAddAndModifyController *vc = [[UIStoryboard storyboardWithName:@"FastRecord" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    vc.fastRecordCellModel = [[FastRecordCellModel alloc] init];
    vc.isAdd = YES;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [fromVc presentViewController:nav animated:YES completion:nil];
}

/*
 编辑用push
 */
+ (void)pushFromViewController:(UIViewController *)fromVc withObject:(FastRecordCellModel *)item andObject:(FastRecordModel*)model {
    FastRecordAddAndModifyController *vc = [[UIStoryboard storyboardWithName:@"FastRecord" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    vc.fastRecordCellModel = item;
    vc.fastRecordModel = model;
    [fromVc.navigationController pushViewController:vc animated:YES];
}

/*
 新建随手记接口
 */
+ (void)addRecordFromViewController:(UIViewController *)fromVc customerInfo:(NSDictionary *)customerInfo completion:(FastRecordAddAndModifyControllerDidCompletedBlock)completion; {
    FastRecordAddAndModifyController *vc = [[UIStoryboard storyboardWithName:@"FastRecord" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    FastRecordCellModel *cellModel = [[FastRecordCellModel alloc] init];
    if (customerInfo) {
        cellModel.customerName = customerInfo[CustomerInfoNameKey];
        cellModel.customerId= customerInfo[CustomerIdKey];
        
    }
    vc.fastRecordCellModel = cellModel;
    vc.isAdd = YES;
    vc.didCompletedBlock = completion;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [fromVc presentViewController:nav animated:YES completion:nil];
}

/*
 编辑随手记接口
 */
+ (void)modifyRecordFromViewController:(UIViewController *)fromVc withObject:(FastRecordCellModel *)item andObject:(FastRecordModel*)model {
    FastRecordAddAndModifyController *vc = [[UIStoryboard storyboardWithName:@"FastRecord" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    vc.fastRecordCellModel = [[FastRecordCellModel alloc] init];
    vc.isAdd = NO;
    vc.fastRecordCellModel = item;
    vc.fastRecordModel = model;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [fromVc presentViewController:nav animated:YES completion:nil];
}


@end
