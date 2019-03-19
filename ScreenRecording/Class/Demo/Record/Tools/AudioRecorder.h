//
//  AudioRecorder.h
//  LuPing
//
//  Created by 马海江 on 2019/2/7.
//  Copyright © 2019 马海江. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MaterialRecordProtocol.h"

@interface AudioRecorder : NSObject <MaterialRecordProtocol>

/**
 *  时间轴管理器
 */
@property (nonatomic, weak) ZHLRecordTimeLine *recordTimeLine;

+(AudioRecorder *)shareRecorder;

//正在录音
-(BOOL)isRecording;

//录音暂停
-(BOOL)isRecordPause;

//开始录音
-(void)startRecordingUpdateTimeBlock:(void(^)(AVAudioRecorder* recorder))updateTimerBlock;

//暂停录音
-(void)pauseRecordingCompletion:(void(^)(AVAudioRecorder* recorder))completionBlock;

//继续录音
-(void)resumeRecordCompletion:(void(^)(AVAudioRecorder* recorder))completionBlock;

//停止录音 结束录音
-(void)stopRecordingCompltion:(void(^)(BOOL success,AVAudioRecorder* recorder))recordCompletion;

-(void)setRecordPath:(NSString *)path;

@end
