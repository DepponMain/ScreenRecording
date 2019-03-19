//
//  PathPlayView.m
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#import "PathPlayView.h"
#import "TutorBezierPointEntity.h"
#import "ZHLPlayTimeLine.h"
#import "DrawContextManager.h"
#import "PathImageView.h"

// 当前主线程的播放状态
#define currentMainTaskStatus            [[_arrayMainTaskStatusFlag lastObject] integerValue]
// 语句执行时间打印
#define ZSTART_TIMER                                \
NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
#define ZEND_TIMER(msg)                             \
NSLog(@"%@ Time = %f", msg, [NSDate timeIntervalSinceReferenceDate]-start);

/**
 *  线程的播放状态（线程一：点击开始播放按钮所启动的主线程； 线程二：快进快退线程）
 */
typedef NS_ENUM(NSInteger, PathPlayViewTaskStatus){
    // 线程正在播放
    PathPlayViewTaskPlaying = 1,
    // 线程播放暂停
    PathPlayViewTaskPause,
    // 线程停止播放
    PathPlayViewTaskStop ,
};

@interface PathPlayView ()

/** 当前处于正在画的UIImageView */
@property (nonatomic , strong) PathImageView *pathImageView;

/** 用于[主线程]控制播放任务线程 类型：PathPlayViewMainTaskStatus */
@property (nonatomic, strong) NSMutableArray *arrayMainTaskStatusFlag;

/** 用于[快进快退线程]控制播放任务 是否停止  NO 表示未暂停，  YES 表示暂停 */
@property (nonatomic, strong) NSMutableArray *arrayOtherTaskStopFlag;

//每一次继续播放 都会去+1 目的是和上一次的任务分开
@property (nonatomic, assign) NSInteger newTag;

@property (nonatomic, strong) UIImageView *penImgV;//笔
@property (nonatomic, strong) UIImageView *eraserImgV;//橡皮
@property (nonatomic, assign) NSInteger penEraserHidetag;//笔和橡皮隐藏的tag

@end


@implementation PathPlayView {
    /**
     * 用于存储快进时/暂停时，最后一条线的颜色配置！用于后续“继续”播放
     */
    TutorBezierPointEntity *_startPoint;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        // 新建轨迹
        self.pathImageView = [[PathImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.pathImageView];
        
        _arrayMainTaskStatusFlag = [NSMutableArray array];
        _arrayOtherTaskStopFlag = [NSMutableArray array];
    }
    return self;
}

#pragma mark - MaterialPlayProtocol

/**
 *  开始播放
 */
- (void)beginPlay {
    // 当前是否有绘画任务
    BOOL hasTaskPlaying = NO;
    
    if ( _arrayMainTaskStatusFlag.count == 0) {
        hasTaskPlaying = NO;
    } else if(currentMainTaskStatus == PathPlayViewTaskPlaying) {
        hasTaskPlaying = YES;
    }
    
    if (hasTaskPlaying) {
        return;
    } else {
        // 主线程播放新的任务
        self.newTag++;
        [_arrayMainTaskStatusFlag addObject:@(PathPlayViewTaskPlaying)];
        [self beginDrawTask:(_arrayMainTaskStatusFlag.count - 1) andTag:self.newTag];
    }
}

/**
 *  播放暂停
 */
- (void)pausePlay {
    // 主线线程的播放标示为暂停运行
    if ( currentMainTaskStatus == PathPlayViewTaskPlaying) {
        [_arrayMainTaskStatusFlag replaceObjectAtIndex:_arrayMainTaskStatusFlag.count-1 withObject:@(PathPlayViewTaskPause)];
    }
    self.penImgV.hidden = YES;
    self.eraserImgV.hidden = YES;
}

/**
 *  停止播放
 */
- (void)stopPlay {
    // 主线线程的播放标示为暂停运行
    if (currentMainTaskStatus != PathPlayViewTaskStop) {
        [_arrayMainTaskStatusFlag replaceObjectAtIndex:_arrayMainTaskStatusFlag.count-1 withObject:@(PathPlayViewTaskStop)];
        // end 强制将未完成的path画到image
        [self.pathImageView endPath:PathImageViewNullPoint];
    }
    self.penImgV.hidden = YES;
    self.eraserImgV.hidden = YES;
}

/**
 * 播放指定的时间 , 快进，快退
 */
- (void)playTime:(long)millisecond {
    [self pausePlay];
    // 此处必须stop
    [self stopPlay];
    
    // 当前是否有快进、快退的绘画任务
    BOOL hasTaskPlaying = NO;
    
    if (_arrayOtherTaskStopFlag.count == 0) {
        hasTaskPlaying = NO;
    } else if([[_arrayOtherTaskStopFlag lastObject] integerValue] == PathPlayViewTaskPlaying){
        hasTaskPlaying = YES;
    }
    if (hasTaskPlaying) {
        // 线程标示为停止运行
        [_arrayOtherTaskStopFlag replaceObjectAtIndex:_arrayOtherTaskStopFlag.count-1 withObject:@(PathPlayViewTaskStop)];
    }
    // 新的任务
    [_arrayOtherTaskStopFlag addObject:@(PathPlayViewTaskPlaying)];
    // [self drawPathImageByTime:millisecond taskFlagIndex:_arrayOtherTaskStopFlag.count - 1];
    
    ZSTART_TIMER
    self.pathImageView.image = [self drawPathImageByTime:millisecond];
    ZEND_TIMER(@"---play time-- ")
}



- (void)beginDrawTask:(NSUInteger)flagIndex andTag:(NSInteger)tag {
    // 异步
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __weak typeof(self) vc = self;
    // 播放起始时间
    long beginTime = self.playTimeLine.time;
    // 查询条件
    NSString *time = [NSString stringWithFormat:@"timePoint >= %ld" , beginTime];
    NSLog(@"----被启动的时间是：%ld------" , beginTime);
    
    dispatch_async(queue, ^{
        NSInteger oldTag = tag;
        // 分页
        int offset = -1;
        // 取500条
        int count = 1000;
        // 上一次的点位置
        TutorBezierPointEntity *lastPoint;
        // 数据库工具
        LKDBHelper *dbHelp = [self.playTimeLine dbHelp];
        while (true) {
            offset++;
            NSArray *arrayDbPoint = [dbHelp search:[TutorBezierPointEntity class] where:time orderBy:@"id" offset:offset*count count:count];
            NSLog(@"count = %ld" , arrayDbPoint.count);
            if (arrayDbPoint && arrayDbPoint.count > 0) {
                
                for (TutorBezierPointEntity *currentPoint  in arrayDbPoint) {
                    // 判断该线程是否已被标示为停止(线程停止，则直接停止绘画)
                    BOOL isFlagStop = vc.arrayMainTaskStatusFlag == nil ||
                    vc.arrayMainTaskStatusFlag.count <= flagIndex ||
                    [[vc.arrayMainTaskStatusFlag objectAtIndex:flagIndex] integerValue] == PathPlayViewTaskStop;
                    if (isFlagStop) {
                        NSLog(@" stop stop  stop  ");
                        return;
                    }
                    
                    // 判断该线程是否已被标示为暂停(线程暂停，则需要将当前绘画调整至暂停的时间轴时刻)
                    BOOL isFlayPause = [[vc.arrayMainTaskStatusFlag objectAtIndex:flagIndex] integerValue] == PathPlayViewTaskPause;
                    
                    // 播放到暂停那个时刻为止！
                    if ( isFlayPause && currentPoint.timePoint >= vc.playTimeLine.time) {
                        NSLog(@"---- pause pause --- 暂停时间 %ld" , vc.playTimeLine.time);
                        // end 强制将未完成的path画到image
                        dispatch_async(dispatch_get_main_queue() , ^{
                            [vc.pathImageView endPath:[currentPoint point]];
                            //NSLog(@"---end timeline time --- :%ld" ,vc.playTimeLine.time);
                            //NSLog(@"---end time --- :%ld" ,currentPoint.timePoint );
                        });
                        return;
                    }
                    
                    // 当前的时间（如果是用下一个点时间减上一个点的时间  偏移会累积  出现声画不同步的问题）
                    long midBeginTime = self.playTimeLine.time;
                    
                    // begin
                    if (!lastPoint || currentPoint.pTag == PointTagBegin) {
                        lastPoint = currentPoint;
                        // 两条线 之间需要睡的时间
                        [NSThread sleepForTimeInterval:((float)currentPoint.timePoint - midBeginTime)/1000];
                        
                        // begin此时并不是起点，而是暂停后再次启动播放的伪起点，则需要重新设置当前线条的配置(颜色等)
                        if (currentPoint.pTag != PointTagBegin && self->_startPoint) {
                            currentPoint.color = self->_startPoint.color;
                        } else if (currentPoint.pTag == PointTagBegin){
                            self->_startPoint = currentPoint;
                        }
                        dispatch_async(dispatch_get_main_queue() , ^{
                            if (oldTag==self->_newTag) {
                                [self movePenOrEraserWithPoint:currentPoint];//橡皮和画笔
                                [vc.pathImageView beginPath:[currentPoint point] withConfigEntity:currentPoint];
                            }else{//线程停止（有新的播放任务以后 之前的点不绘制 否则会错乱）
                                return;
                            }
                        });
                        
                        continue;
                    }
                    
                    // move
                    if (currentPoint.pTag == PointTagMiddle) {
                        // 当前点画完后，变成为上一个点
                        lastPoint = currentPoint;
                        // 两个点 之间需要睡的时间
                        [NSThread sleepForTimeInterval:((float)currentPoint.timePoint - midBeginTime)/1000];
                        
                        dispatch_async(dispatch_get_main_queue() , ^{
                            if (oldTag==self->_newTag) {
                                [self movePenOrEraserWithPoint:currentPoint];//橡皮和画笔
                                [vc.pathImageView movePath:[currentPoint point]];
                            }else{//线程停止（有新的播放任务以后 之前的点不绘制 否则会错乱）
                                return;
                            }
                            [vc.pathImageView movePath:[currentPoint point]];
                        });
                        continue;
                    }
                    
                    // end
                    if (currentPoint.pTag == PointTagEnd) {
                        // 当前点画完后，变成为上一个点
                        lastPoint = currentPoint;
                        dispatch_async(dispatch_get_main_queue() , ^{
                            if (oldTag==self->_newTag) {
                                [self penEraserHideWithTag:++self->_penEraserHidetag];
                                [vc.pathImageView endPath:[currentPoint point]];
                            }else{//线程停止（有新的播放任务以后 之前的点不绘制 否则会错乱）
                                return;
                            }
                        });
                        NSLog(@"当前时间轴时间----%ld" , vc.playTimeLine.time);
                        NSLog(@"当前画得时间点----%ld" , currentPoint.timePoint);
                        continue;
                    }
                }
            } else {
                break;
            }
        }
    });
}

//隐藏 笔、橡皮 图标
- (void)penEraserHideWithTag:(NSInteger)tag{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (tag == self->_penEraserHidetag) {
            self.penImgV.hidden = YES;
            self.eraserImgV.hidden = YES;
        }
    });
}

//展示或移动 笔、橡皮 图标
- (void)movePenOrEraserWithPoint:(TutorBezierPointEntity *)point{
    CGPoint realPoint = [point point];
    
    self.penImgV.hidden = point.isEraser;
    self.eraserImgV.hidden = !point.isEraser;
    if (point.isEraser) {
        self.eraserImgV.center = CGPointMake(realPoint.x, realPoint.y);
    }else{
        self.penImgV.frame = CGRectMake(realPoint.x, realPoint.y, 27, 27);
    }
}

#pragma mark 快速画轨迹方法(去除延时)
- (UIImage *)drawPathImageByTime:(long)time {
    
    UIImage *img;
    // 分页
    int offset = -1;
    // 取500条
    int count = 1000;
    // imageContext 轨迹记录
    DrawContextManager *dcManager = [[DrawContextManager alloc] init];
    //创建线条
    CGMutablePathRef path = nil;
    // 线是否结束
    BOOL _isPathEnd = YES;
    // begin
    [dcManager beginImageContext:self.bounds.size];
    while (true) {
        offset++;
        NSArray *arrayDbPoint = [self getPointByEndTime:time pageSize:count offset:offset*count];
        NSLog(@"--count = %ld" , arrayDbPoint.count);
        if (arrayDbPoint && arrayDbPoint.count > 0) {
            for (TutorBezierPointEntity *currentPoint  in arrayDbPoint) {
                // 线的起点
                if (currentPoint.pTag == PointTagBegin) {
                    // 配置颜色等参数
                    [dcManager configFromTutorBezierPointEntity:currentPoint];
                    _startPoint = currentPoint;//保存线条颜色配置
                    path = CGPathCreateMutable();
                    _isPathEnd = NO;
                    CGPathMoveToPoint(path, nil, currentPoint.x, currentPoint.y);
                } else if (currentPoint.pTag == PointTagMiddle) {
                    // 线中间点
                    CGPathAddLineToPoint(path, nil,currentPoint.x, currentPoint.y);
                } else if (currentPoint.pTag == PointTagEnd) {
                    // 线的终点
                    [dcManager drawPaht:path];
                    CGPathRelease(path);
                    _isPathEnd = YES;
                }
            }
        } else {
            // 线的终点
            if (!_isPathEnd) {
                [dcManager drawPaht:path];
            }
            img = [dcManager endImageContext];
            break;
        }
    }
    return img;
}

/**
 *  由于 [LKDBHelper]提供的search方法在“FMResultSet-->entity”时效率比较低。造成线程延迟严重。此处使用FMDatabase进行查询
 */
- (NSArray *)getPointByEndTime:(long)time pageSize:(int)size offset:(int)offset {
    
    NSMutableArray *arrayContent = [NSMutableArray array];
    // sql
    NSString * stringQuery = [NSString stringWithFormat:@"select * from TutorBezierPointEntity where timePoint <= %ld order by id limit %d offset %d" , time, size, offset];;
    //    if (clearModl) {
    //       stringQuery = [NSString stringWithFormat:@"select * from TutorBezierPointEntity where timePoint <= %ld and timePoint >= %ld order by id limit %d offset %d", currentTimeShoot , time, size, offset];
    //    } else {
    //       stringQuery = [NSString stringWithFormat:@"select * from TutorBezierPointEntity where timePoint <= %ld and timePoint >= %ld order by id limit %d offset %d", time, currentTimeShoot , size, offset];
    //    }
    // 数据库工具
    LKDBHelper *dbHelp = [self.playTimeLine dbHelp];
    [dbHelp executeDB:^(FMDatabase *db) {
        
        FMResultSet *result = [db executeQuery:stringQuery];
        while([result next]){
            TutorBezierPointEntity *entity = [[TutorBezierPointEntity alloc] init];
            entity.id = [result intForColumn:@"id"];
            entity.timePoint = [result intForColumn:@"timePoint"];
            entity.color = [result intForColumn:@"color"];
            entity.lId = [result longForColumn:@"lId"];
            entity.pTag = [result intForColumn:@"pTag"];
            entity.x = [result doubleForColumn:@"x"];
            entity.y = [result doubleForColumn:@"y"];
            entity.isEraser = [result boolForColumn:@"isEraser"];
            
            [arrayContent addObject:entity];
        }
        [result close];
    }];
    return arrayContent;
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
