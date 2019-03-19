//
//  AudioRecorder.m
//  LuPing
//
//  Created by 马海江 on 2019/2/7.
//  Copyright © 2019 马海江. All rights reserved.
//

#import "AudioRecorder.h"

#define TimeSecRecord                               0.1 //录音更新进度时间

enum
{
    ENC_AAC = 1,
    ENC_ALAC = 2,
    ENC_IMA4 = 3,
    ENC_ILBC = 4,
    ENC_ULAW = 5,
    ENC_PCM = 6,
    
} encodingTypes;

@interface AudioRecorder ()<AVAudioRecorderDelegate>
{
    AVAudioRecorder *audioRecorder;
    int _recordEncoding;
    
    BOOL _recordPause;
    long long _recordLen;
    NSTimer* _recordTimer;
    
    void(^_stopRecordCompletion)(BOOL success,AVAudioRecorder* recorder);//结束录音
    void(^_pauseRecordCompletion)(AVAudioRecorder* recorder);           //暂停录音
    void(^_resumeRecordCompletion)(AVAudioRecorder* recorder);           //继续录音
    void(^_recorderTimerBlock)(AVAudioRecorder* recorder);//录音时间更新
    
    NSString *_recordFilePaht;
}
@end

@implementation AudioRecorder

static AudioRecorder *instance=nil;

+ (AudioRecorder *)shareRecorder
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance =[[AudioRecorder alloc] init];
    });
    return instance;
}

- (void)setRecordPath:(NSString *)path {
    _recordFilePaht = path;
}

#pragma mark 录音 代理
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (_recordTimer) {
        [_recordTimer invalidate];
    }
    _recordPause = NO;
    if (flag) {
        //成功
        if (_stopRecordCompletion) {
            _stopRecordCompletion(YES,recorder);
        }
    }else
    {
        if (_stopRecordCompletion) {
            _stopRecordCompletion(NO,recorder);
        }
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    if (_recordTimer) {
        [_recordTimer invalidate];
    }
    _recordPause = NO;
    if (_stopRecordCompletion) {
        _stopRecordCompletion(NO,recorder);
    }
}

#pragma end

-(BOOL)isRecording{
    return [audioRecorder isRecording];
}

-(BOOL)isRecordPause
{
    return _recordPause;
}

//开始录音
-(void) startRecordingUpdateTimeBlock:(void(^)(AVAudioRecorder* recorder))updateTimerBlock
{
    if ([self isRecording]) {
        [audioRecorder stop];
    }
    
    if (!_recordFilePaht) {
        NSException *exception = [NSException exceptionWithName:@"ZHLAudioRecorderException" reason:@"The record file path is nil" userInfo:nil];
        @throw exception;
        return;
    }
    
    _recorderTimerBlock = updateTimerBlock;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setActive:YES error:nil];
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
    if(_recordEncoding == ENC_PCM)
    {
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    }
    else
    {
        NSNumber *formatObject;
        
        switch (_recordEncoding) {
            case (ENC_AAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
                break;
            case (ENC_ALAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleLossless];
                break;
            case (ENC_IMA4):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
                break;
            case (ENC_ILBC):
                formatObject = [NSNumber numberWithInt: kAudioFormatiLBC];
                break;
            case (ENC_ULAW):
                formatObject = [NSNumber numberWithInt: kAudioFormatULaw];
                break;
            default:
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
        }
        
        [recordSettings setObject:formatObject forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:8000.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    }
    
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    //[settings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];//格式
    [settings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];//格式
    [settings setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey]; //采样8000次
    [settings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];//声道
    [settings setValue :[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];//位深度
    [settings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [settings setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    //Encoder
    [settings setValue :[NSNumber numberWithInt:12000] forKey:AVEncoderBitRateKey];//采样率
    [settings setValue :[NSNumber numberWithInt:8] forKey:AVEncoderBitDepthHintKey];//位深度
    [settings setValue :[NSNumber numberWithInt:8] forKey:AVEncoderBitRatePerChannelKey];//声道采样率
    [settings setValue :@(AVAudioQualityLow)       forKey:AVEncoderAudioQualityKey];//编码质量
    
    
    NSURL *url = [NSURL fileURLWithPath:_recordFilePaht];
    NSError *error = nil;
    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    if ([audioRecorder prepareToRecord] == YES)
    {
        audioRecorder.delegate = self;
        BOOL flag = [audioRecorder record];
        NSLog(@"开始录音:%d",flag);
        if (_recordTimer) {
            [_recordTimer invalidate];
        }
        _recordTimer = [NSTimer scheduledTimerWithTimeInterval:TimeSecRecord target:self selector:@selector(recordTimeUpdateAction) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_recordTimer forMode:NSRunLoopCommonModes];
    } else {
        NSLog(@"录音初始化Error: %@" , [error localizedDescription]);
    }
}

//暂停录音
-(void)pauseRecordingCompletion:(void(^)(AVAudioRecorder* recorder))completionBlock
{
    if (audioRecorder) {
        [audioRecorder pause];
        _recordPause = YES;
        if (completionBlock) {
            completionBlock(audioRecorder);
        }
    }else
    {
        _recordPause = NO;
    }
}

//继续录音
-(void)resumeRecordCompletion:(void(^)(AVAudioRecorder* recorder))completionBlock
{
    if (audioRecorder) {
        [audioRecorder record];
        if (completionBlock) {
            completionBlock(audioRecorder);
        }
    }
    _recordPause = NO;
}

//停止录音 结束录音
-(void)stopRecordingCompltion:(void(^)(BOOL success,AVAudioRecorder* recorder))recordCompletion
{
    if (_recordTimer) {
        [_recordTimer invalidate];
    }
    _stopRecordCompletion = recordCompletion;
    _recordLen = audioRecorder.currentTime;
    [audioRecorder stop];
}

#pragma mark 录音时间 更新
-(void)recordTimeUpdateAction
{
    if (_recordPause) {
        return;
    }
    if (_recorderTimerBlock) {
        _recorderTimerBlock(audioRecorder);
    }
}

//删除录音文件
-(void)deleteRecordByPath:(NSString*)filePath
{
    
}

#pragma mark MaterialRecordProtocol

/**
 *  开始录屏
 */
- (void)beginRecord {
    if (_recordPause) {
        [self resumeRecordCompletion:nil];
    } else {
        [self startRecordingUpdateTimeBlock:nil];
    }
    
    ZHLRecordLogBegin
}

/**
 *  录屏暂停
 */
- (void)pauseRecord {
    [self pauseRecordingCompletion:nil];
    
    ZHLRecordLogPause
}

/**
 *  停止录屏
 */
- (void)stopRecord {
    [self stopRecordingCompltion:nil];
    
    ZHLRecordLogStop
}

- (void)saveRecord {
    
}

- (NSMutableArray *)getSaveData {
    return nil;
}

@end
