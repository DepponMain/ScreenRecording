//
//  MaterialPlayProtocol.h
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#ifndef MaterialPlayProtocol_h
#define MaterialPlayProtocol_h

#define ZHLPlayLogBegin                         NSLog(@"~~~ %@ ~~~ begin" , [self class]);
#define ZHLPlayLogPause                         NSLog(@"~~~ %@ ~~~ pause" , [self class]);
#define ZHLPlayLogStop                          NSLog(@"~~~ %@ ~~~ stop" , [self class]);

@class ZHLPlayTimeLine;

/**
 *  素材需要遵循的【播放】协议
 */
@protocol MaterialPlayProtocol <NSObject>

#pragma mark - property
// -------------------- 以下属性，为素材必须拥有的属性--------------------
/**
 *  时间轴管理器
 */
@property (nonatomic, weak) ZHLPlayTimeLine *playTimeLine;

/**
 *  开始播放
 */
- (void)beginPlay;

/**
 *  播放暂停
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

#endif /* MaterialPlayProtocol_h */
