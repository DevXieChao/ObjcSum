//
//  FastRecord.h
//  MLLSalesAssistant
//
//  Created by sihuan on 15/10/7.
//  Copyright © 2015年 Meilele. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

//系统色
#define Color_31bdc4           ColorFromRGBHex(0x31bdc4)

//通用字体色
#define Color_0fb1ba           ColorFromRGBHex(0x0fb1ba)

//通用边线
#define Color_d8d8d8           ColorFromRGBHex(0xd8d8d8)

//通用底色
#define Color_f4f4f4           ColorFromRGBHex(0xf4f4f4)


//传入客户信息对应的key
#define CustomerInfoNameKey @"CustomerInfoNameKey"
#define CustomerIdKey @"CustomerIdKey"

@class FastRecordCellModel;
@class FastRecordModel;

//数据类型
typedef NS_ENUM(NSUInteger, FastRecordType) {
    FastRecordTypeCustomer,//客户更进
    FastRecordTypePersonal,//个人提醒
};

//操作类型，文字，语音，选择图片等
typedef NS_ENUM(NSInteger, FastRecordActionType) {
    FastRecordActionTypeTitle = 0,  //选择标题
    FastRecordActionTypeText,       //文字输入
    FastRecordActionTypeVoice,      //语音
    FastRecordActionTypeImage,      //选择图片
    FastRecordActionTypeClock,      //设置闹铃
    FastRecordActionTypeCusomer,    //选择客户
};

@protocol FastRecordCellActionDelegate <NSObject>

- (void)fastRecordCell:(UITableViewCell *)cell didClicked:(FastRecordActionType)actionType atIndexpath:(NSIndexPath *)indexPath withObject:(id)obj;

@end

@interface FastRecord : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

+ (instancetype)shareInstance;

///*添加一条新记录*/
//+ (BOOL)addNewEntityWithCellModel:(FastRecordCellModel *)cellModel;

/*更新记录*/
+ (BOOL)updateEntity:(FastRecordModel *)entity withValue:(FastRecordCellModel *)model;

/*删除记录*/
+ (BOOL)deleteEntity:(FastRecordModel *)model;

/*
 获取指定客户的 客户更进数据，传入用户电话号码
 返回FastRecordModel的数组
 */
+ (NSArray *)getFastRecordDatasWithCustomerId:(NSString *)customerPhone;

@end
