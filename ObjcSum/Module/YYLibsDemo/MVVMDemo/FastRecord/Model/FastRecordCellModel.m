//
//  FastRecordCellModel.m
//  MLLSalesAssistant
//
//  Created by sihuan on 15/9/28.
//  Copyright © 2015年 Meilele. All rights reserved.
//

#import "FastRecordCellModel.h"
#import "FastRecordModel.h"

#import "DateTools.h"

#define DateFormatDefault @"MM-dd HH:mm"

@implementation FastRecordCellModel

- (void)setType:(FastRecordType)type {
    switch (type) {
        case FastRecordTypeCustomer:
            _title = @"客户跟进";
            break;
        case FastRecordTypePersonal:
            _title = @"个人提醒";
            break;
        default:
            _title = @"-";
            break;
    }
    _type = type;
}

- (void)setRecordDate:(NSDate *)recordDate {
    _recordDate = recordDate;
    _recordDateStr = recordDate != nil ? [recordDate formattedDateWithFormat:DateFormatDefault] : nil;
}

- (void)setClockDate:(NSDate *)clockDate {
    _clockDate = clockDate;
    _clockDateStr = clockDate != nil ? [clockDate formattedDateWithFormat:DateFormatDefault] : nil;

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.recordImages = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithFastRecordModel:(FastRecordModel *)model {

    self = [super init];
    if (self) {
        self.managedObjectID = [[model objectID] URIRepresentation].absoluteString;
        self.type = [model.type intValue];
        
        self.recordDate = model.recordDate;
        self.clockDate = model.clockDate;
        
        self.recordText = model.recordText;
        self.recordVoicePath = model.recordVoicePath != nil ?  [NSURL URLWithString:model.recordVoicePath] : nil;
        self.recordVoiceDuration = [model.recordVoiceDuration stringValue];
        
        
        self.recordImages = model.recordImages != nil ? [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:model.recordImages]] : [NSMutableArray array];
        self.customerName = model.customerName;
        self.customerId = model.customerId;
    }
    return self;

}

/*
 将FastRecordModel数组转换成FastRecordCellModel数组
 */
+ (NSMutableArray *)arrayFromFastRecordModels:(NSArray *)fastRecordModels {
    NSMutableArray *fastRecordCellModels = [NSMutableArray arrayWithCapacity:fastRecordModels.count];
    
    for (FastRecordModel *model in fastRecordModels) {
        FastRecordCellModel *cellModel = [[FastRecordCellModel alloc] initWithFastRecordModel:model];
        [fastRecordCellModels addObject:cellModel];
    }
    return fastRecordCellModels;
}


@end
