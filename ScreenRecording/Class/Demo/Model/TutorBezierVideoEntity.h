//
//  TutorBezierVideoEntity.h
//  LuPing
//
//  Created by 马海江 on 2019/2/7.
//  Copyright © 2019 马海江. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  存储该录屏的基本信息
 */

@interface TutorBezierVideoEntity : NSObject

/**
 *  id
 */
@property (nonatomic, assign) int id;

/**
 *  录屏时间长短
 */
@property (nonatomic, assign) long videoTime;

@end
