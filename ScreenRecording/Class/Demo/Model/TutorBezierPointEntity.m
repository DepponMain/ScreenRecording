//
//  TutorBezierPointEntity.m
//  LuPing
//
//  Created by 马海江 on 2019/2/7.
//  Copyright © 2019 马海江. All rights reserved.
//

#import "TutorBezierPointEntity.h"

@implementation TutorBezierPointEntity

// 设置数据库主键
+ (NSString *)getPrimaryKey {
    
    return @"id";
}

// 表名
+ (NSString *)getTableName
{
    return @"TutorBezierPointEntity";
}

- (CGPoint)point {
    return CGPointMake(self.x, self.y);
}

@end
