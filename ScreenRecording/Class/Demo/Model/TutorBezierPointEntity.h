//
//  TutorBezierPointEntity.h
//  LuPing
//
//  Created by 马海江 on 2019/2/7.
//  Copyright © 2019 马海江. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  轨迹点的记录
 */

@interface TutorBezierPointEntity : NSObject

/**
 * id
 */
@property (nonatomic, assign) int id;

/** 线id **/
@property (nonatomic, assign) long lId;

/** X坐标 **/
@property (nonatomic, assign) float x;

/** Y坐标 **/
@property (nonatomic, assign) float y;

/** 线的颜色 **/
@property (nonatomic, assign) long color;

///** 线的宽度 **/
//@property (nonatomic, assign) float strokeWidth;

/** 是否为橡皮擦 **/
@property (nonatomic, assign) BOOL isEraser;

/** 0表示开始，1表示中间的点，2表示结束 **/
@property (nonatomic, assign) short int pTag;

/** 时间轴上的时间点 **/
@property (nonatomic, assign) long timePoint;

- (CGPoint)point;

@end
