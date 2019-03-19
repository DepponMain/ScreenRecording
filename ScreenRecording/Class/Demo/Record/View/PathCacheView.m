//
//  PathCacheView.m
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#import "PathCacheView.h"
#import "DrawContextManager.h"

@implementation PathCacheView {
    CGMutablePathRef _path;
    
    DrawContextManager *_drawManager;
    
    TutorBezierPointEntity *_pathConifgEntity;
}

/**
 *  初始化事件
 */
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        _drawManager = [[DrawContextManager alloc] init];
    }
    return self;
}

/**
 *  显示当前正在画得线
 */
- (void)drawRect:(CGRect)rect {
    [_drawManager beginContextFromDrawRect];
    //    [_drawManager configFromTutorBezierPointEntity:_pathConifgEntity];
    [[UIColor redColor] set];
    [_drawManager drawPaht:_path];
    [_drawManager endContextFromDrawRect];
}

- (void)showPath:(CGMutablePathRef)path withPathConfig:(TutorBezierPointEntity *)configEntity{
    _path = path;
    _pathConifgEntity = configEntity;
    [self setNeedsDisplay];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
