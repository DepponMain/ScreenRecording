//
//  ZHLAudioPlayer.h
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MaterialPlayProtocol.h"

@interface ZHLAudioPlayer : NSObject <MaterialPlayProtocol>

/**
 *  时间轴管理器
 */
@property (nonatomic, weak) ZHLPlayTimeLine *playTimeLine;


+ (ZHLAudioPlayer *)sharePlayer;

/**
 *  是否正在播放
 */
- (BOOL)isPlaying;

// 是否播放暂停
- (BOOL)isPlayPause;

//播放音频文件
- (void)playFile:(NSString*)filePath didFinishedBlock:(void(^)(BOOL success,AVAudioPlayer* player))completion updateTimeBlock:(void(^)(AVAudioPlayer* player))updateTimerBlock;

//暂停播放
- (void)pausePlayingCompletion:(void(^)(AVAudioPlayer* player))completionBlock;

//继续播放
- (void)resumePlayingCompletion:(void(^)(AVAudioPlayer* player))completionBlock;

//正在播放的录音文件
- (NSString*)playingPath;

//设置播放路径
- (void)setPlayPath:(NSString *)path;

//取得播放进度百分比
- (float)getPlayingProgress;

//是否为循环播放
- (BOOL)isRepeatPlaying;

//设置循环播放
- (void)setRepeatPlay:(BOOL)flag;

//该文件是否正在播放
- (BOOL)isPlayingData:(NSData*)data;

@end
