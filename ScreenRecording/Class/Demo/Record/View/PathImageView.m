//
//  PathImageView.m
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#import "PathImageView.h"
#import "PathCacheView.h"
#import "TutorBezierPointEntity.h"
#import "DrawContextManager.h"

@interface PathImageView() {
    
    /**用于显示 手指正在移动时当前所画得轨迹 */
    PathCacheView *_pathCacheView;
    
    CGMutablePathRef _path;
    
    BOOL _isPathRelease;
    
    // 保存起始点时 提供的线条颜色宽度等属性
    TutorBezierPointEntity *_pathConfigEntity;
    
    DrawContextManager *_dcManager;
}

@end

@implementation PathImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        _pathCacheView = [[PathCacheView alloc] initWithFrame:frame];
        [self addSubview:_pathCacheView];
        _dcManager = [[DrawContextManager alloc] init];
    }
    return self;
}

- (void)configPath:(TutorBezierPointEntity *)configEntity {
    _pathConfigEntity = configEntity;
}

#pragma mark - 轨迹记录开始

- (void)beginPath:(CGPoint)beginPoint withConfigEntity:(TutorBezierPointEntity *)configEntity
{
    _pathConfigEntity = configEntity;
    // 新建线
    _path = CGPathCreateMutable();
    _isPathRelease = NO;
    CGPathMoveToPoint(_path, nil, beginPoint.x, beginPoint.y);
    // 显示当前正在画得轨迹
    [_pathCacheView showPath:_path withPathConfig:_pathConfigEntity];
}


#pragma mark - 轨迹记录移动

- (void)movePath:(CGPoint)movePoint{
    if (!_isPathRelease) {
        CGPathAddLineToPoint(_path, nil, movePoint.x, movePoint.y);
        // 显示当前正在画得轨迹
        [_pathCacheView showPath:_path withPathConfig:_pathConfigEntity];
    }
}


#pragma mark 轨迹记录结束

- (void)endPath:(CGPoint)endPoint{
    // 防止外部两次调用endPath，野指针错误
    if(_isPathRelease) {
        return;
    }
    if(!CGPointEqualToPoint(endPoint, PathImageViewNullPoint)) {
        // 最后一个点
        CGPathAddLineToPoint(_path, nil, endPoint.x, endPoint.y);
        // 显示当前正在画得轨迹
        [_pathCacheView showPath:_path withPathConfig:_pathConfigEntity];
    }
    // 轨迹记录【由于UIGraphicsBeginImageContextWithOptions 画高清轨迹图片的效率速度极低，故不采用 touchMove的时候直接生成image】
    [_dcManager beginImageContext:self.bounds.size];
    [self.image drawInRect:self.bounds];
    [_dcManager configFromTutorBezierPointEntity:_pathConfigEntity];
    [_dcManager drawPaht:_path];
    // 保存最新的轨迹画布
    self.image = [_dcManager endImageContext];
    CGPathRelease(_path);
    _isPathRelease = YES;
    // 隐藏当前正在画的轨迹，因为当前image已经拥有了该轨迹
    [_pathCacheView showPath:nil withPathConfig:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
