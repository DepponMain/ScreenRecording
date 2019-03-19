//
//  ZHLRecordTimeLine.m
//  LuPing
//
//  Created by 马海江 on 2019/2/7.
//  Copyright © 2019 马海江. All rights reserved.
//

#import "ZHLRecordTimeLine.h"
#import "RecordDataHelp.h"
#import "TutorBezierVideoEntity.h"

#define MaterialActionEntiyCacheCount 100

@interface ZHLRecordTimeLine()

/**
 *  素材 <录音，点轨迹>
 */
@property (nonatomic, strong) NSMutableArray *arrayMaterial;

/**
 *  时间轴的状态
 */
@property (nonatomic, assign) RecordTimeLineState lineState;

@end

@implementation ZHLRecordTimeLine{
    
    RecordDataHelp *_dataHelp;
    
    /** 开始录制的时间---时间轴1 */
    long _beginRecordTime;
    /** 当前已经录制的时间---时间轴2 */
    long _durationTime;
    // 定时器
    NSTimer *_timerScheduled;
}

+ (instancetype)initWithDataSavePath:(NSString *)path {
    ZHLRecordTimeLine *timeline = [[ZHLRecordTimeLine alloc] init];
    timeline.arrayMaterial = [NSMutableArray array];
    timeline->_dataHelp = [RecordDataHelp initWithDBPath:path];
    
    timeline.videoEntity = [[TutorBezierVideoEntity alloc] init];
    return timeline;
}

/**
 * 添加素材
 */
- (void)addMaterial:(id<MaterialRecordProtocol>)material {
    [self.arrayMaterial addObject:material];
    [material setRecordTimeLine:self];
    if (_lineState == RECORDING) {
        [material beginRecord];
    }
}

- (void)removeMaterial:(id<MaterialRecordProtocol>)material {
    [self.arrayMaterial removeObject:material];
}

/**
 *  时间轴的时间点计算
 */
- (long)time {
    if (_lineState == RECORDPAUSE) {
        return _durationTime;
    }else{
        return [self nowTime] - _beginRecordTime;
    }
}

/**
 * 当前时间 单位为毫秒
 */
- (long)nowTime {
    return [[NSDate date] timeIntervalSince1970] * 1000;
}

/**
 *  开始录屏
 */
- (void)beginRecord {
    _beginRecordTime = [self nowTime];
    // 被暂停过，则开始时间 = 当前时间 - 录制时间
    if (_lineState == RECORDPAUSE) {
        _beginRecordTime = [self nowTime] - _durationTime;
    }
    _lineState = RECORDING;
    // 开启定时器
    [self beginTimerScheduled];
    // 素材beginRecord
    [self.arrayMaterial makeObjectsPerformSelector:@selector(beginRecord)];
    
}

/**
 *  录屏暂停
 */
- (void)pauseRecord {
    _durationTime = [self time];
    _lineState = RECORDPAUSE;
    // 停止定时器
    [self stopTimerScheduled];
    // 素材pause
    [self.arrayMaterial makeObjectsPerformSelector:@selector(pauseRecord)];
    
}

/**
 *  停止录屏
 */
- (void)stopRecord {
    if (_lineState != RECORDSTOP) {
        // 停止录屏生成录屏最终信息实体
        self.videoEntity.videoTime =  [self time];
        
        _lineState = RECORDSTOP;
        // 停止定时器
        [self stopTimerScheduled];
        // 素材stop
        [self.arrayMaterial makeObjectsPerformSelector:@selector(stopRecord)];
        
        // 停止录屏，最后的缓存数据全部入库
        for (id<MaterialRecordProtocol> material in self.arrayMaterial) {
            NSMutableArray *actionArray = [material getSaveData];
            if (actionArray && actionArray.count >0) {
                NSArray *temp = [actionArray copy];
                [actionArray removeAllObjects];
                // 入库
                [_dataHelp saveDataWithArray:temp];
            }
        }
        
        [_dataHelp saveDataWithModel:self.videoEntity];
        
    }
}

/**
 *  启动定时器，用于定时存储数据
 */
- (void)beginTimerScheduled {
    if (_timerScheduled) {
        [_timerScheduled invalidate];
    }
    _timerScheduled = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
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

- (void)timerRun {
    // 自定义实现数据存储
    for (id<MaterialRecordProtocol> material in self.arrayMaterial) {
        [material saveRecord];
    }
    
    // timeLine提供的统一数据存储
    for (id<MaterialRecordProtocol> material in self.arrayMaterial) {
        NSMutableArray *actionArray = [material getSaveData];
        // 记录缓存100条，超过100则入库
        if (actionArray && actionArray.count >= MaterialActionEntiyCacheCount) {
            NSRange range = NSMakeRange(0, 100);
            NSArray *temp = [actionArray subarrayWithRange:range];
            [actionArray removeObjectsInRange:range];
            // 入库
            [_dataHelp saveDataWithArray:temp];
        }
    }
}

- (RecordTimeLineState)timeLineState{
    return _lineState;
}

@end
