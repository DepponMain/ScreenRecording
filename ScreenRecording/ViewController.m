//
//  ViewController.m
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#import "ViewController.h"

#import "PathRecordView.h"
#import "AudioRecorder.h"
#import "ZHLRecordTimeLine.h"

#import "PathPlayView.h"
#import "ZHLAudioPlayer.h"
#import "ZHLPlayTimeLine.h"

#import "TutorBezierVideoEntity.h"

@interface ViewController () <ZHLPlayTimeLineDelegate>

/**
 *  笔记录制view
 */
@property (nonatomic, strong) PathRecordView *pathRecordView;

/**
 *  时间轴
 */
@property (nonatomic, strong) ZHLRecordTimeLine *recordTimeLine;

/**
 *  笔记播放view
 */
@property (nonatomic, strong) PathPlayView *pathPlayView;

/**
 *  播放时间轴
 */
@property (nonatomic, strong) ZHLPlayTimeLine *playTimeLine;

@end

@implementation ViewController{
    
    UILabel  *_labelTimeCurrent;
    UILabel  *_labelTimeMax;
    UISlider *_slider;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupUI];
}

#pragma mark -- UI
- (void)setupUI{
    NSArray *data1 = @[@"开始录",@"暂停录",@"停止录",@"开始播",@"暂停播"];
    for (int i = 0; i < data1.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/60+i*ScreenWidth/data1.count, 20, ScreenWidth/(data1.count+1), 25)];
        button.tag = i;
        [button setTitle:data1[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor lightGrayColor]];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    NSArray *data2 = @[@"黑色",@"红色",@"绿色",@"蓝色",@"橡皮擦"];
    for (int i = 0; i < data2.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/60+i*ScreenWidth/data2.count, 55, ScreenWidth/(data2.count+1), 25)];
        button.tag = i+10;
        [button setTitle:data2[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor lightGrayColor]];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    float frameY = 90;
    _labelTimeCurrent = [[UILabel alloc] initWithFrame:CGRectMake(0, frameY, 50, 25)];
    _labelTimeCurrent.text = @"00:00";
    _labelTimeCurrent.font = [UIFont systemFontOfSize:14];
    _labelTimeCurrent.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_labelTimeCurrent];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(50, frameY, ScreenWidth - 100 , 25)];
    [_slider setMaximumValue:9957];
    [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_slider];
    
    _labelTimeMax = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 50, frameY, 50, 25)];
    _labelTimeMax.text = @"00:00";
    _labelTimeMax.font = [UIFont systemFontOfSize:14];
    _labelTimeMax.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_labelTimeMax];
}

#pragma mark -- Action
//按钮点击
- (void)buttonClick:(UIButton *)sender{
    if (sender.tag == 0) {
        [self startRecord];
    }else if (sender.tag == 1) {
        [self pause];
    }else if (sender.tag == 2) {
        [self stopRecord];
    }else if (sender.tag == 3) {
        [self play];
    }else if (sender.tag == 4) {
        [self playPause];
    }
    else if (sender.tag == 10) {
        [self black];
    }else if (sender.tag == 11) {
        [self red];
    }else if (sender.tag == 12) {
        [self green];
    }else if (sender.tag == 13) {
        [self blue];
    }else if (sender.tag == 14) {
        [self eraser];
    }
}
//开始录屏
- (void)startRecord{
    [_playTimeLine stopPlay];
    // --- temp ----
    NSFileManager *m = [NSFileManager defaultManager];
    NSString *dbPath = [LKDBUtils getPathForDocuments:@"guiji.db" inDir:@"RecordFile"];
    [m removeItemAtPath:dbPath error:nil];
    
    // 新建时间轴
    _recordTimeLine = [ZHLRecordTimeLine initWithDataSavePath:dbPath];
    
    // 录制素材一：画图view
    _pathRecordView = [[PathRecordView alloc] initWithFrame:CGRectMake(0, StatusBarHeight, ScreenWidth, ScreenHeight-StatusBarHeight)];
    if (_pathPlayView) {
        [_pathPlayView removeFromSuperview];
        _pathPlayView = nil;
    }
    [self.view insertSubview:_pathRecordView atIndex:0];
    
    // 录制素材二：声音
    AudioRecorder *record = [AudioRecorder shareRecorder];
    NSString *recordPath = [LKDBUtils getPathForDocuments:@"luyin.caf" inDir:@"RecordFile"];
    [record setRecordPath:recordPath];
    
    
    [record setRecordTimeLine:_recordTimeLine];
    [_recordTimeLine addMaterial:record];
    
    [_pathRecordView setRecordTimeLine:_recordTimeLine];
    [_recordTimeLine addMaterial:_pathRecordView];
    
    [_recordTimeLine beginRecord];
}
//暂停录制
- (void)pause{
    [_recordTimeLine pauseRecord];
}
//停止录制
- (void)stopRecord {
    [_recordTimeLine stopRecord];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSLog(@"path==%@", path);
}
//开始播放
- (void)play {
    [_recordTimeLine stopRecord];
    // 新建时间轴
    NSString *dbPath = [LKDBUtils getPathForDocuments:@"guiji.db" inDir:@"RecordFile"];
    
    _playTimeLine = [ZHLPlayTimeLine initWithDataSavePath:dbPath];
    
    // ------------- 总时间
    LKDBHelper *dbHelp =  [_playTimeLine dbHelp];
    TutorBezierVideoEntity *temp = [dbHelp searchSingle:[TutorBezierVideoEntity class]  where:nil orderBy:nil];
    NSLog(@"视频总时间是：%ld" , temp.videoTime);
    [_playTimeLine setMaxMillisecond:temp.videoTime];
    [_slider setMaximumValue:temp.videoTime];
    _labelTimeMax.text = [NSString stringWithFormat:@"%.2d:%.2ld" ,(int)(temp.videoTime/1000/60) , lroundf(temp.videoTime/1000)%60];
    //--------------
    
    _playTimeLine.delegate = self;
    
    // 录制素材一：画图view
    _pathPlayView = [[PathPlayView alloc] initWithFrame:CGRectMake(0, StatusBarHeight, ScreenWidth, ScreenHeight-StatusBarHeight)];
    [_playTimeLine addMaterial:_pathPlayView];
    if (_pathRecordView) {
        [_pathRecordView removeFromSuperview];
        _pathRecordView = nil;
    }
    [self.view insertSubview:_pathPlayView atIndex:0];
    
    // 录制素材二：声音
    ZHLAudioPlayer *player = [ZHLAudioPlayer sharePlayer];
    NSString *playPath = [LKDBUtils getPathForDocuments:@"luyin.caf" inDir:@"RecordFile"];
    [player setPlayPath:playPath];
    [_playTimeLine addMaterial:player];
    
    [_playTimeLine beginPlay];
}
//暂停播放
- (void)playPause{
    [_playTimeLine pausePlay];
}
//黑色
- (void)black {
    _pathRecordView.isEraser = NO;
    [_pathRecordView setColor:[ZHLColor colorWithRed:0 green:0 blue:0]];
}
//红色
- (void)red {
    _pathRecordView.isEraser = NO;
    [_pathRecordView setColor:[ZHLColor colorWithRed:255 green:0 blue:0]];
}
//绿色
- (void)green {
    _pathRecordView.isEraser = NO;
    [_pathRecordView setColor:[ZHLColor colorWithRed:0 green:255 blue:0]];
}
//蓝色
- (void)blue {
    _pathRecordView.isEraser = NO;
    [_pathRecordView setColor:[ZHLColor colorWithRed:0 green:0 blue:255]];
}
//橡皮擦
- (void)eraser {
    _pathRecordView.isEraser = YES;
}

//进度条拖动
static int oldSliderValue;
- (void)sliderValueChanged:(UISlider *)sender {
    if (ABS(sender.value - oldSliderValue) >= 1) {
        oldSliderValue = sender.value;
        _labelTimeCurrent.text = [NSString stringWithFormat:@"%.2d:%.2ld" ,(int)(sender.value/1000/60) , lroundf(sender.value/1000)%60];
        [_playTimeLine playTime:sender.value];
    } else {
        return;
    }
}
//进度条更新
static long oldTimeMillisecond;
- (void)playTimeLineCurrentTime:(long)millisecond {
    _slider.value = millisecond;
    if (ABS(oldSliderValue - millisecond) > 1000) {
        oldTimeMillisecond = millisecond;
        _labelTimeCurrent.text = [NSString stringWithFormat:@"%.2ld:%.2ld" ,millisecond/1000/60 , millisecond/1000%60 ];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
