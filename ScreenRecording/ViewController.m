//
//  ViewController.m
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#import "ViewController.h"

#import "TutorBezierVideoEntity.h"

#import "PathRecordView.h"
#import "AudioRecorder.h"
#import "ZHLRecordTimeLine.h"

#import "PathPlayView.h"
#import "ZHLAudioPlayer.h"
#import "ZHLPlayTimeLine.h"

#import "TopControlView.h"
#import "BottonControlView.h"

@interface ViewController () <ZHLPlayTimeLineDelegate, TopControlViewDelegate, BottonControlViewDelegate>

@property (nonatomic, copy) NSString *videoPath;
@property (nonatomic, weak) TopControlView *topView;
@property (nonatomic, weak) BottonControlView *bottomView;

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

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark -- Delegate

/**
 顶部按钮点击
 
 @param tag 1：开始录  2：暂停录  3：停止录  4：开始播  5：橡皮擦  6：黑色  7：蓝色  8：绿色
 */
- (void)topViewBtnClickWithTag:(NSInteger)tag{
    self.topView.setState = 0;
    if (tag == 1) {
        [self startRecord];
    }else if (tag == 2) {
        [self pause];
    }else if (tag == 3) {
        [self stopRecord];
    }else if (tag == 4) {
        [self play];
    }
    else if (tag == 5) {
        [self eraser];
    }else if (tag == 6) {
        [self black];
    }else if (tag == 7) {
        [self blue];
    }else if (tag == 8)  {
        [self green];
    }
}

/**
 重新录制按钮点击
 */
- (void)reRecordBtnClick{
    self.topView.hidden = NO;
    self.bottomView.hidden = YES;
}

/**
 拖动进度条
 */
static int oldSliderValue;
- (void)sliderValueChanged:(UISlider *)sender{
    if (ABS(sender.value - oldSliderValue) >= 1) {
        oldSliderValue = sender.value;
        _bottomView.currentTimeLab.text = [NSString stringWithFormat:@"%.2d:%.2ld" ,(int)(sender.value/1000/60) , lroundf(sender.value/1000)%60];
        [_playTimeLine playTime:sender.value];
    } else {
        return;
    }
}

/**
 进度条更新
 */
static long oldTimeMillisecond;
- (void)playTimeLineCurrentTime:(long)millisecond{
    _bottomView.slider.value = millisecond;
    if (ABS(oldSliderValue - millisecond) > 1000) {
        oldTimeMillisecond = millisecond;
        _bottomView.currentTimeLab.text = [NSString stringWithFormat:@"%.2ld:%.2ld" ,millisecond/1000/60 , millisecond/1000%60 ];
    }
}

#pragma mark -- UI
- (void)setupUI{
    
    TopControlView *topView = [[TopControlView alloc] initWithFrame:CGRectMake(0, StatusBarHeight, ScreenWidth, 100)];
    self.topView = topView;
    topView.delegate = self;
    [self.view addSubview:topView];
    topView.setState = 0;
    
    BottonControlView *bottomView = [[BottonControlView alloc] initWithFrame:CGRectMake(0, ScreenHeight-40, ScreenWidth, 40)];
    self.bottomView = bottomView;
    bottomView.delegate = self;
    [self.view addSubview:bottomView];
    bottomView.hidden = YES;
    
}

#pragma mark -- 私有方法

//开始录屏
- (void)startRecord{
    if ((self.recordTimeLine.timeLineState==RECORDINIT||self.recordTimeLine.timeLineState==RECORDSTOP)) {//重新录制
        // --- temp ----
        _videoPath = [NSString stringWithFormat:@"%ld",(long)[self getNowTimeTimestamp]];
        
        NSFileManager *m = [NSFileManager defaultManager];
        NSString *dbPath = [LKDBUtils getPathForDocuments:@"guiji.db" inDir:_videoPath];
        [m removeItemAtPath:dbPath error:nil];
        
        // 新建时间轴
        _recordTimeLine = [ZHLRecordTimeLine initWithDataSavePath:dbPath];
        
        // 录制素材一：画图view
        [_pathRecordView removeFromSuperview];
        [_pathPlayView removeFromSuperview];
        _pathRecordView = [[PathRecordView alloc] initWithFrame:CGRectMake(0, StatusBarHeight, ScreenWidth, ScreenHeight-StatusBarHeight)];
        [self.view insertSubview:_pathRecordView atIndex:0];
        
        // 录制素材二：声音
        AudioRecorder *record = [AudioRecorder shareRecorder];
        NSString *recordPath = [LKDBUtils getPathForDocuments:@"luyin.caf" inDir:_videoPath];
        [record setRecordPath:recordPath];
        
        
        [record setRecordTimeLine:_recordTimeLine];
        [_recordTimeLine addMaterial:record];
        
        [_pathRecordView setRecordTimeLine:_recordTimeLine];
        [_recordTimeLine addMaterial:_pathRecordView];
        
        [_recordTimeLine beginRecord];
    }else if (_recordTimeLine.timeLineState == RECORDPAUSE){//继续录制
        [_recordTimeLine beginRecord];
    }
    [self updateTimeLab];
    self.topView.setState = 1;
}
//更新 录制时间
- (void)updateTimeLab{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //页面存在  并且录制中  才更新时间
        if (self.recordTimeLine.timeLineState==RECORDING) {
            long second = self.recordTimeLine.time;
            self.topView.timeLab.text = [NSString stringWithFormat:@"%.2ld:%.2ld" ,second/1000/60, second/1000%60];
            [self updateTimeLab];
        }
    });
}
//暂停录制
- (void)pause{
    [_recordTimeLine pauseRecord];
}
//停止录制
- (void)stopRecord {
    [_recordTimeLine stopRecord];
}
//开始播放
- (void)play {
    if (_recordTimeLine.timeLineState == RECORDSTOP) {
        self.topView.hidden = YES;
        self.bottomView.hidden = NO;
        // 新建时间轴
        NSString *dbPath = [LKDBUtils getPathForDocuments:@"guiji.db" inDir:_videoPath];
        
        _playTimeLine = [ZHLPlayTimeLine initWithDataSavePath:dbPath];
        
        // ------------- 总时间
        LKDBHelper *dbHelp =  [_playTimeLine dbHelp];
        TutorBezierVideoEntity *temp = [dbHelp searchSingle:[TutorBezierVideoEntity class]  where:nil orderBy:nil];
        NSLog(@"视频总时间是：%ld" , temp.videoTime);
        [_playTimeLine setMaxMillisecond:temp.videoTime];
        [_bottomView.slider setMaximumValue:temp.videoTime];
        _bottomView.maxTimeLab.text = [NSString stringWithFormat:@"%.2d:%.2ld" ,(int)(temp.videoTime/1000/60) , lroundf(temp.videoTime/1000)%60];
        //--------------
        
        _playTimeLine.delegate = self;
        
        // 录制素材一：画图view
        [_pathPlayView removeFromSuperview];
        [_pathRecordView removeFromSuperview];
        _pathPlayView = [[PathPlayView alloc] initWithFrame:CGRectMake(0, StatusBarHeight, ScreenWidth, ScreenHeight-StatusBarHeight)];
        [_playTimeLine addMaterial:_pathPlayView];
        [self.view insertSubview:_pathPlayView atIndex:0];
        
        // 录制素材二：声音
        ZHLAudioPlayer *player = [ZHLAudioPlayer sharePlayer];
        NSString *playPath = [LKDBUtils getPathForDocuments:@"luyin.caf" inDir:_videoPath];
        [player setPlayPath:playPath];
        [_playTimeLine addMaterial:player];
        
        [_playTimeLine beginPlay];
    }
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
//当前时间戳
- (NSInteger)getNowTimeTimestamp{
    return [[NSDate date] timeIntervalSince1970];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
