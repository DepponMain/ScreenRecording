//
//  RecordDataHelp.h
//  LuPing
//
//  Created by 马海江 on 2019/2/7.
//  Copyright © 2019 马海江. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  录屏数据 数据库存储类
 */

@interface RecordDataHelp : NSObject

+ (instancetype)initWithDBPath:(NSString *)dbPath;

- (void)saveDataWithArray:(NSArray *)arryActionEntity;

- (void)saveDataWithModel:(NSObject *)actionEntity;

@end
