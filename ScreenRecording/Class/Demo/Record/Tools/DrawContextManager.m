//
//  DrawContextManager.m
//  LuPing
//
//  Created by 马海江 on 2019/2/7.
//  Copyright © 2019 马海江. All rights reserved.
//

#import "DrawContextManager.h"
#import "TutorBezierPointEntity.h"

@implementation DrawContextManager{
    
    CGContextRef _context;
}

/**
 * 开始编辑
 */
- (CGContextRef)beginImageContext:(CGSize)size {
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    _context = context;
    [self configContext];
    return _context;
}

/**
 * 设置画笔属性
 */
- (void)configContext {
    CGContextSetLineCap(_context, kCGLineCapRound);
    CGContextSetLineJoin(_context, kCGLineJoinRound);
    CGContextSetBlendMode(_context,kCGBlendModeNormal);
    CGContextSetLineWidth(_context, 2);
}

- (void)configFromTutorBezierPointEntity:(TutorBezierPointEntity *)entity {
    if (entity.isEraser) {
        CGContextSetBlendMode(_context, kCGBlendModeClear);
        CGContextSetLineWidth(_context, 10);
    }else{
        CGContextSetBlendMode(_context, kCGBlendModeNormal);
        CGContextSetLineWidth(_context, 2);
    }
    CGContextSetStrokeColorWithColor(_context, [UIColor colorWithHex:entity.color alpha:1].CGColor);
}

/**
 * 画线
 */
- (void)drawPaht:(CGPathRef)path {
    CGContextAddPath(_context, path);
    CGContextDrawPath(_context, kCGPathStroke);
}
/**
 * 结束编辑
 */
- (UIImage *)endImageContext {
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _context = nil;
    return img;
}

/**
 * 从DrawRect中创建画布视图
 */
- (CGContextRef)beginContextFromDrawRect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    _context = context;
    [self configContext];
    return _context;
}

/**
 * 从DrawRect中结束画布视图
 */
- (void)endContextFromDrawRect {
    _context = nil;
}

- (void)dealloc {
    DeallocLog
}


@end
