//
//  ZHLAudioPlayer.m
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#import "ZHLAudioPlayer.h"

#define TimeSecPlay 0.1 //播放更新进度时间

@interface ZHLAudioPlayer () <AVAudioPlayerDelegate>

@end

@implementation ZHLAudioPlayer {
    /**播放结束*/
    void(^_playerFinishBlock)(BOOL success,AVAudioPlayer* player);
    /**暂停播放*/
    void(^_pausePlayCompletion)(AVAudioPlayer* player);
    /**继续播放*/
    void(^_resumePlayCompletion)(AVAudioPlayer* player);
    /**结束播放*/
    void(^_stopPlayCompletion)(AVAudioPlayer* player);
    /**播放时间更新*/
    void(^_playerTimerBlock)(AVAudioPlayer* player);
    
    AVAudioPlayer *audioPlayer;
    NSTimer* _playerTime;
    BOOL _playPause;
    
    NSString *_playPath;
}

static ZHLAudioPlayer *instance=nil;

+ (ZHLAudioPlayer *)sharePlayer
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[[ZHLAudioPlayer alloc] init];
    });
    return instance;
}

- (BOOL)isPlaying
{
    return [audioPlayer isPlaying];
}

- (BOOL)isPlayPause
{
    return _playPause;
}

//播放录音文件
- (void)playFile:(NSString*)filePath didFinishedBlock:(void(^)(BOOL success,AVAudioPlayer* player))completion updateTimeBlock:(void(^)(AVAudioPlayer* player))updateTimerBlock
{
    if ([self isPlaying]) {
        [audioPlayer stop];
    }
    _playerFinishBlock = completion;
    _playerTimerBlock = updateTimerBlock;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    NSURL *url = [NSURL URLWithString:filePath];
    NSError *error;
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.numberOfLoops = 0;
    audioPlayer.delegate = self;
    
    BOOL FLAG= [audioPlayer play];
    if (FLAG) {
        if (_playerTime) {
            [_playerTime invalidate];
        }
        _playerTime = [NSTimer scheduledTimerWithTimeInterval:TimeSecPlay target:self selector:@selector(playTimeUpdateAction) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_playerTime forMode:NSRunLoopCommonModes];
    }
    
    NSLog(@"播放成功:%d",FLAG);
}

//暂停播放
- (void)pausePlayingCompletion:(void(^)(AVAudioPlayer* player))completionBlock
{
    if (!_playPause && audioPlayer) {
        [audioPlayer pause];
        _playPause = YES;
        if (completionBlock) {
            completionBlock(audioPlayer);
        }
    }else
    {
        _playPause =NO;
    }
    
}

//继续播放
- (void)resumePlayingCompletion:(void(^)(AVAudioPlayer* player))completionBlock
{
    if (audioPlayer) {
        [audioPlayer play];
        if (completionBlock) {
            completionBlock(audioPlayer);
        }
    }
    _playPause = NO;
}

//停止播放 结束播放
- (void) stopPlayingCompletion:(void(^)(AVAudioPlayer* player))completionBlock
{
    if (_playerTime) {
        [_playerTime invalidate];
    }
    if (audioPlayer) {
        [audioPlayer stop];
    }
    _playPause = NO;
    //    _stopPlayCompletion = completionBlock;
    
    if (completionBlock) {
        completionBlock(audioPlayer);
    }
    
}

//设置新的
- (void)setPlayUpdateTimeBlock:(void(^)(AVAudioPlayer* player))updateTimerBlock
{
    _playerTimerBlock = updateTimerBlock;
    
}

#pragma mark 播放时间 更新
- (void)playTimeUpdateAction
{
    if (_playPause) {
        return;
    }
    if (_playerTimerBlock) {
        _playerTimerBlock(audioPlayer);
    }
}

//正在播放的录音文件
- (NSString*)playingPath
{
    if (audioPlayer) {
        return [audioPlayer.url absoluteString];
    }
    return nil;
}

//取得播放进度百分比
- (float)getPlayingProgress
{
    if (audioPlayer) {
        float pro =audioPlayer.currentTime / audioPlayer.duration;
        if (pro > 1) {
            pro = 1;
        }
        return pro;
        
    }else
    {
        return 0;
    }
}

//是否为循环播放
- (BOOL)isRepeatPlaying
{
    if (audioPlayer) {
        NSInteger num = [audioPlayer numberOfLoops];
        if (num < 0) {
            return YES;
        }else
        {
            return NO;
        }
    }else
    {
        return NO;
    }
}

//设置循环播放
- (void)setRepeatPlay:(BOOL)flag
{
    if (audioPlayer) {
        if (flag) {
            [audioPlayer setNumberOfLoops:-1];
        }else
        {
            [audioPlayer setNumberOfLoops:1];
        }
    }
}

//该文件是否正在播放
- (BOOL)isPlayingData:(NSData*)data
{
    if (data && audioPlayer) {
        return [audioPlayer.data isEqualToData:data];
        
    }
    return NO;
}

- (void)setPlayPath:(NSString *)path {
    _playPath = path;
}

#pragma mark - play delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (_playerTime) {
        [_playerTime invalidate];
    }
    _playPause = NO;
    if (_playerFinishBlock) {
        _playerFinishBlock(flag,player);
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    if (_playerTime) {
        [_playerTime invalidate];
    }
    _playPause = NO;
    if (_playerFinishBlock) {
        _playerFinishBlock(NO,player);
    }
}

#pragma mark - MaterialPlayProtocol
/**
 *  开始播放
 */
- (void)beginPlay {
    if (![self isPlaying]) {
        if (_playPause) {
            [self resumePlayingCompletion:nil];
        } else {
            [self playFile:_playPath didFinishedBlock:nil updateTimeBlock:nil];
            NSLog(@"beginplay");
        }
    }
}

/**
 *  播放暂停
 */
- (void)pausePlay {
    [self pausePlayingCompletion:nil];
}

/**
 *  停止播放
 */
- (void)stopPlay {
    [self stopPlayingCompletion:nil];
}

/**
 * 播放指定的时间 , 快进，快退
 */
- (void)playTime:(long)millisecond {
    if (millisecond/1000 < audioPlayer.duration) {
        audioPlayer.currentTime = millisecond;
    }
}

@end
