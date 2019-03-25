//
//  PathPlayVC.m
//  ScreenRecording
//
//  Created by 马海江 on 2019/3/20.
//  Copyright © 2019 haijiang. All rights reserved.
//

#import "PathPlayVC.h"

#import "PathPlayView.h"
#import "ZHLAudioPlayer.h"
#import "ZHLPlayTimeLine.h"

#import "TutorBezierVideoEntity.h"

@interface PathPlayVC () <ZHLPlayTimeLineDelegate>

/**
 *  笔记播放view
 */
@property (nonatomic, strong) PathPlayView *pathPlayView;

/**
 *  播放时间轴
 */
@property (nonatomic, strong) ZHLPlayTimeLine *playTimeLine;

@end

@implementation PathPlayVC{
    
    UILabel  *_labelTimeCurrent;
    UILabel  *_labelTimeMax;
    UISlider *_slider;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    
    [self play];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark -- UI

- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    
    float frameY = ScreenHeight - 50;
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
//开始播放
- (void)play {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
