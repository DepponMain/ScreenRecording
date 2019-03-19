//
//  TutorBezierVideoEntity.m
//  LuPing
//
//  Created by 马海江 on 2019/2/7.
//  Copyright © 2019 马海江. All rights reserved.
//

#import "TutorBezierVideoEntity.h"

@implementation TutorBezierVideoEntity

// 设置数据库主键
+ (NSString *)getPrimaryKey {
    
    return @"id";
}

// 表名
+ (NSString *)getTableName
{
    return @"TutorBezierVideoEntity";
}

@end
