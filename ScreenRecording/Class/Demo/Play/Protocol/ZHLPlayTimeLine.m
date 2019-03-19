//
//  ZHLPlayTimeLine.m
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#import "ZHLPlayTimeLine.h"

@interface ZHLPlayTimeLine()

/**
 *  素材 <录音，点轨迹，图片>
 */
@property (nonatomic, strong) NSMutableArray *arrayMaterial;

@end

@implementation ZHLPlayTimeLine{
    
    LKDBHelper *_dbHelp;
    
    /** 开始播放的时间 */
    long _beginPlayTime;
    /** 当前已经播放的时间 */
    long _durationTime;
    
    // 定时器
    NSTimer *_timerScheduled;
    
    // 0 表示未判断 ；1，表示delegate未实现代理方法； 2，表示delegate实现了代理方法
    int delegateFlag;
}

+ (instancetype)initWithDataSavePath:(NSString *)path {
    ZHLPlayTimeLine *timeline = [[ZHLPlayTimeLine alloc] init];
    timeline.arrayMaterial = [NSMutableArray array];
    timeline->_dbHelp = [[LKDBHelper alloc] initWithDBPath:path];
    return timeline;
}

- (LKDBHelper *)dbHelp {
    return _dbHelp;
}

/**
 * 添加素材
 */
- (void)addMaterial:(id<MaterialPlayProtocol>)material {
    [self.arrayMaterial addObject:material];
    [material setPlayTimeLine:self];
    if (_timeLineState == PLAYING) {
        [material beginPlay];
    }
}

- (void)removeMaterial:(id<MaterialPlayProtocol>)material {
    [self.arrayMaterial removeObject:material];
}

/**
 *  时间轴的时间点计算
 */
- (long)time {
    if (_timeLineState == PLAYPAUSE) {
        return _durationTime;
    }
    return [self nowTime] - _beginPlayTime;
}

/**
 * 当前时间 单位为毫秒
 */
- (long)nowTime {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

/**
 *  开始播放
 */
- (void)beginPlay {
    if (_timeLineState != PLAYING) {
        _beginPlayTime = [self nowTime];
        // 被暂停过，则开始时间 = 当前时间 - 录制时间
        if (_timeLineState == PLAYPAUSE) {
            _beginPlayTime = [self nowTime] - _durationTime;
        }
        _timeLineState = PLAYING;
        // 开启定时器
        [self beginTimerScheduled];
        // 素材beginRecord
        [self.arrayMaterial makeObjectsPerformSelector:@selector(beginPlay)];
    }
}

/**
 *  暂停播放
 */
- (void)pausePlay {
    _durationTime = [self time];
    NSLog(@"----TimeLine被暂停的时间是：%ld------" , _durationTime);
    _timeLineState = PLAYPAUSE;
    // 停止定时器
    [self stopTimerScheduled];
    // 素材pause
    [self.arrayMaterial makeObjectsPerformSelector:@selector(pausePlay)];
}

/**
 *  停止播放
 */
- (void)stopPlay {
    _timeLineState = PLAYSTOP;
    // 停止定时器
    [self stopTimerScheduled];
    // 素材stop
    [self.arrayMaterial makeObjectsPerformSelector:@selector(stopPlay)];
}

/**
 *  启动定时器，用于定时播报时间
 */
- (void)beginTimerScheduled {
    if (_timerScheduled) {
        [_timerScheduled invalidate];
    }
    _timerScheduled = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timerScheduled forMode:NSRunLoopCommonModes];
}

/**
 *  停止定时器
 */
- (void)stopTimerScheduled {
    if (_timerScheduled) {
        [_timerScheduled invalidate];
    }
}

- (void)playTime:(long)millisecond {
    // 暂停当前任务
    [self pausePlay];
    // 调整时间轴时间
    _durationTime = millisecond;
    _beginPlayTime = [self nowTime] - millisecond;
    for(id<MaterialPlayProtocol> material in self.arrayMaterial) {
        [material playTime:millisecond];
    }
}

- (void)timerRun {
    if(self.time > self.maxMillisecond) {
        [self stopPlay];
    }
    
    // 避免每次 respondsToSelector 查询选择子
    if (_delegate && delegateFlag == 0) {
        if ([_delegate respondsToSelector:@selector(playTimeLineCurrentTime:)]) {
            delegateFlag = 2;
        } else {
            delegateFlag = 1;
        }
    }
    if (_delegate && delegateFlag == 2) {
        [_delegate playTimeLineCurrentTime:self.time];
    }
}

- (void)dealloc {
    DeallocLog
}

@end
