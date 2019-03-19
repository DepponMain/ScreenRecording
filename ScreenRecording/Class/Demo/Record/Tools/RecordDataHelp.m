//
//  RecordDataHelp.m
//  LuPing
//
//  Created by 马海江 on 2019/2/7.
//  Copyright © 2019 马海江. All rights reserved.
//

#import "RecordDataHelp.h"

@implementation RecordDataHelp {
    LKDBHelper *_dbHelper;
}

+ (instancetype)initWithDBPath:(NSString *)dbPath {
    RecordDataHelp *rdh = [[RecordDataHelp alloc]init];
    rdh->_dbHelper = [[LKDBHelper alloc] initWithDBPath:dbPath];
    return rdh;
}

- (void)saveDataWithArray:(NSArray *)arryActionEntity {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT , 0), ^{
        for (NSObject *actionEntity in arryActionEntity) {
            [self->_dbHelper insertToDB:actionEntity];
        }
    });
}

- (void)saveDataWithModel:(NSObject *)actionEntity {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT , 0), ^{
        [self->_dbHelper insertToDB:actionEntity];
    });
}

@end
