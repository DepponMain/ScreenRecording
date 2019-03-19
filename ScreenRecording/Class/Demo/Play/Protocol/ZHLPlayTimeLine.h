//
//  ZHLPlayTimeLine.h
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MaterialPlayProtocol.h"

typedef enum {
    // 初始状态
    PLAYINIT = 0,
    // 播放中状态
    PLAYING,
    // 暂停状态
    PLAYPAUSE,
    // 已停止
    PLAYSTOP
    
} PlayTimeLineState;

@protocol ZHLPlayTimeLineDelegate <NSObject>

- (void)playTimeLineCurrentTime:(long)millisecond;

@end

@interface ZHLPlayTimeLine : NSObject

/**
 *  时间轴的状态
 */
@property (nonatomic, assign, readonly) PlayTimeLineState timeLineState;

/**
 *  代理
 */
@property (nonatomic, weak) id<ZHLPlayTimeLineDelegate> delegate;

/**
 *  时间轴时间点
 */
@property (nonatomic, assign, readonly) long time;

/**
 * 数据存储位置
 */
+ (instancetype)initWithDataSavePath:(NSString *)path;

/**
 *  时间轴最大时间(毫秒)
 */
@property (nonatomic, assign) long maxMillisecond;

/**
 * 添加素材
 */
- (void)addMaterial:(id<MaterialPlayProtocol>)material;

/**
 *  移除素材
 */
- (void)removeMaterial:(id<MaterialPlayProtocol>)material;

/**
 *  获取数据库存储工具
 */
- (LKDBHelper *)dbHelp;

/**
 *  开始播放
 */
- (void)beginPlay;

/**
 *  暂停播放
 */
- (void)pausePlay;

/**
 *  停止播放
 */
- (void)stopPlay;

/**
 * 播放指定的时间 , 快进，快退
 */
- (void)playTime:(long)millisecond;

@end
