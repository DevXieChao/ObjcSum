//
//  FastRecordListController.m
//  MLLSalesAssistant
//
//  Created by sihuan on 15/9/28.
//  Copyright © 2015年 Meilele. All rights reserved.
//

#import "FastRecordListController.h"
#import "FastRecordAddAndModifyController.h"
#import "UILocalNotification+YYExtention.h"
#import "UIViewController+Extension.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "YYHud.h"
#import "UIViewController+NoDataTip.h"


@interface FastRecordListController ()<FastRecordCellDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSMutableArray *fastRecordArray;//谁手记数据


@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation FastRecordListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
    
    self.tableView.tableHeaderView = [self headerLine];
    
    self.tableView.backgroundColor = Color_f4f4f4;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);

    [self loadData];
}

- (UIView *)headerLine {
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0.5, [UIScreen mainScreen].bounds.size.width, 0.5);
    view.backgroundColor = Color_d8d8d8;
    return view;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavagationBarTheme:NavigationControllerBarThemeTypeWhite];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.barThemeType == NavigationControllerBarThemeTypeGreen) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (void)loadData {
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    self.fastRecordArray = [FastRecordCellModel arrayFromFastRecordModels:self.fetchedResultsController.fetchedObjects];
    [self reloadData];
}

- (void)reloadData {
    [self.tableView reloadData];
    if (self.fastRecordArray.count == 0) {
        [self noDataTipShow];
    } else {
        [self noDataTipDismiss];
    }
}

#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *fastRecord = [NSEntityDescription entityForName:@"FastRecordModel" inManagedObjectContext:self.managedObjectContext];
    
    NSSortDescriptor *sortDesc = [[NSSortDescriptor alloc] initWithKey:@"recordDate" ascending:NO];
    
//    ApplicationUser *user = [[MllRegisterManager sharedManager] getLatestLogedInUser];
    NSString *userKey = @"hehe";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId=%@ AND type=%d", userKey,_fastRecordType];
    
    [fetchRequest setEntity:fastRecord];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:@[sortDesc]];

    
    NSFetchedResultsController *resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                        managedObjectContext:self.managedObjectContext
                                                                                          sectionNameKeyPath:nil cacheName:nil];
    resultsController.delegate = self;
    _fetchedResultsController = resultsController;

    return _fetchedResultsController;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [FastRecord shareInstance].managedObjectContext;
    }
    return _managedObjectContext;
}


#pragma mark - TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.fastRecordArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [tableView fd_heightForCellWithIdentifier:NSStringFromClass([FastRecordCell class]) configuration:^(FastRecordCell *cell) {
        [cell updateUI:_fastRecordArray[indexPath.row] atIndexpath:indexPath];
    }];
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FastRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FastRecordCell class]) forIndexPath:indexPath];
    [cell updateUI:_fastRecordArray[indexPath.row] atIndexpath:indexPath];
    cell.delegate = self;
    cell.separatorInset = (indexPath.row == _fastRecordArray.count-1) ? UIEdgeInsetsZero :  UIEdgeInsetsMake(0, 10, 0, 0);
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [FastRecordAddAndModifyController modifyRecordFromViewController:self withObject:_fastRecordArray[indexPath.row] andObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_fastRecordArray insertObject:[[FastRecordCellModel alloc] initWithFastRecordModel:anObject] atIndex:0];
            break;
            
        case NSFetchedResultsChangeDelete:
            _selectedIndex = nil;
            [_fastRecordArray removeObjectAtIndex:indexPath.row];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            [_fastRecordArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:newIndexPath.row];
            break;
    }
    [self reloadData];
}


#pragma mark - FastRecordCellDelegate
- (void)fastRecordCell:(FastRecordCell *)fastRecordCell didClickedDeleteIconAtIndexpath:(NSIndexPath *)indexPath {
    if (indexPath.row < _fastRecordArray.count) {
        _selectedIndex = indexPath;
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"确认删除?" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [view show];
    }
}

- (void)fastRecordCell:(FastRecordCell *)fastRecordCell didClickedRecordImageAtIndexpath:(NSIndexPath *)indexPath {
    NSLog(@"didClickedRecordImageAtIndexpath");
}

#pragma -mark UIAlertViewDelegate
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    } else {
        NSString *key = [[(FastRecordCellModel *)self.fastRecordArray[_selectedIndex.row] managedObjectID] mutableCopy];
        NSString *filePath = [[(FastRecordCellModel *)self.fastRecordArray[_selectedIndex.row] recordVoicePath].absoluteString copy];
        if (![FastRecord deleteEntity:[self.fetchedResultsController objectAtIndexPath:_selectedIndex]]) {
            [YYHud showTip:@"删除失败"];
        } else {
            [UILocalNotification cancelLocalNotificationWithKey:key];
            if (filePath) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
        }
    }
}


#pragma mark - Public
+ (instancetype)instanceFromStortyboard {
    return [[UIStoryboard storyboardWithName:@"FastRecord" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
}

@end

