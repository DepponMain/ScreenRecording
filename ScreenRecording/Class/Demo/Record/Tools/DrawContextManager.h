//
//  DrawContextManager.h
//  LuPing
//
//  Created by 马海江 on 2019/2/7.
//  Copyright © 2019 马海江. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TutorBezierPointEntity;

/**
 *  统一配置画布、画笔
 */

@interface DrawContextManager : NSObject

/**
 * 开始编辑
 */
- (CGContextRef)beginImageContext:(CGSize)size;

/**
 * 设置画笔属性
 */
- (void)configFromTutorBezierPointEntity:(TutorBezierPointEntity *)entity;

/**
 * drawPath、strokePath
 */
- (void)drawPaht:(CGPathRef)path;

/**
 * 结束编辑
 */
- (UIImage *)endImageContext;

/**
 * 从DrawRect中创建画布视图
 */
- (CGContextRef)beginContextFromDrawRect;

/**
 * 从DrawRect中结束画布视图
 */
- (void)endContextFromDrawRect;


@end
