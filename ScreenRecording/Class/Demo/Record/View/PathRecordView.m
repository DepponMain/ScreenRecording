//
//  PathRecordView.m
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#import "PathRecordView.h"
#import "TutorBezierPointEntity.h"
#import "PathImageView.h"

@interface PathRecordView ()

/** 点的集合 */
@property (nonatomic , strong) NSMutableArray *arrayPoint;
/** 轨迹画布 */
@property (nonatomic, strong) PathImageView *pathImageView;
/** 橡皮擦图标 */
@property (nonatomic, strong) UIImageView *eraseImgV;

@end

@implementation PathRecordView{
    /** 当前正画的线id */
    long _lineId;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        //self.layer.shouldRasterize = YES;
    }
    return self;
}

#pragma mark - 轨迹记录
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan");
    UITouch *touch = [touches anyObject];
    CGPoint beginPoint = [touch locationInView:self];
    // 新增一条线
    _lineId = [[NSDate date] timeIntervalSince1970] * 1000;
    // 新增起始点
    TutorBezierPointEntity *pathConfig = [self addPoint:beginPoint andPtag:PointTagBegin];
    if (!_pathImageView) {
        // 新建ImageView图层
        _pathImageView = [[PathImageView alloc] initWithFrame:self.bounds];
        _pathImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_pathImageView];
    }
    // 设置画笔参数、传递事件
    [_pathImageView beginPath:beginPoint withConfigEntity:pathConfig];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentlocation = [touch locationInView:self];
    // 记录轨迹点
    [self addPoint:currentlocation andPtag:PointTagMiddle];
    // 传递事件
    [_pathImageView movePath:currentlocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint endPoint = [touch locationInView:self];
    // 记录终点
    [self addPoint:endPoint andPtag:PointTagEnd];
    // 传递事件
    [_pathImageView endPath:endPoint];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 传递事件
    [_pathImageView touchesEnded:touches withEvent:event];
}


- (TutorBezierPointEntity *)addPoint:(CGPoint)point andPtag:(PointTag)pTag {
    TutorBezierPointEntity *en = [TutorBezierPointEntity new];
    en.pTag = pTag;
    en.x = point.x;
    en.y = point.y;
    en.timePoint = [self.recordTimeLine time];
    if (pTag == PointTagBegin) {
        // 开始
        en.lId = _lineId;
        en.isEraser = _isEraser;
        en.color = [UIColor colorToLongValueWithRed:self.color.red green:self.color.blue blue:self.color.red];
    }
    // 非录制状态下，不保存录制点
    if ([self.recordTimeLine timeLineState] == RECORDING) {
        [self.arrayPoint addObject:en];
    }
    return en;
}


- (NSMutableArray *)arrayPoint {
    if (!_arrayPoint) {
        _arrayPoint = [NSMutableArray array];
    }
    return _arrayPoint;
}

#pragma mark - MaterialRecordProtocol
/**
 *  开始录屏
 */
- (void)beginRecord {
    ZHLRecordLogBegin
}

/**
 *  录屏暂停
 */
- (void)pauseRecord {
    ZHLRecordLogPause
}

/**
 *  停止录屏
 */
- (void)stopRecord {
    ZHLRecordLogStop
}

/**
 *  自定义存储录屏数据实现
 */
- (void)saveRecord {
    
}

/**
 *  返回需要存储的数据，可以依赖ZHLTimeLine的统一数据存储管理。 也可以自行通过【saveRecord】实现
 */
- (NSMutableArray *)getSaveData {
    return self.arrayPoint;
}


- (void)dealloc {
    DeallocLog
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
