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

#import "PathPlayVC.h"

@interface ViewController ()

/**
 *  笔记录制view
 */
@property (nonatomic, strong) PathRecordView *pathRecordView;

/**
 *  时间轴
 */
@property (nonatomic, strong) ZHLRecordTimeLine *recordTimeLine;

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

#pragma mark -- UI
- (void)setupUI{
    NSArray *data1 = @[@"开始录",@"暂停录",@"停止录",@"开始播"];
    for (int i = 0; i < data1.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/45+i*ScreenWidth/data1.count, 20, ScreenWidth/(data1.count+1), 25)];
        button.tag = i;
        [button setTitle:data1[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor lightGrayColor]];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    NSArray *data2 = @[@"黑色",@"紫色",@"绿色",@"橡皮擦"];
    for (int i = 0; i < data2.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/45+i*ScreenWidth/data2.count, 55, ScreenWidth/(data2.count+1), 25)];
        button.tag = i+10;
        [button setTitle:data2[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor lightGrayColor]];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
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
    }
    else if (sender.tag == 10) {
        [self black];
    }else if (sender.tag == 11) {
        [self red];
    }else if (sender.tag == 12) {
        [self blue];
    }else if (sender.tag == 13)  {
        [self eraser];
    }
}
//开始录屏
- (void)startRecord{
    // --- temp ----
    NSFileManager *m = [NSFileManager defaultManager];
    NSString *dbPath = [LKDBUtils getPathForDocuments:@"guiji.db" inDir:@"RecordFile"];
    [m removeItemAtPath:dbPath error:nil];
    
    // 新建时间轴
    _recordTimeLine = [ZHLRecordTimeLine initWithDataSavePath:dbPath];
    
    // 录制素材一：画图view
    [_pathRecordView removeFromSuperview];
    _pathRecordView = [[PathRecordView alloc] initWithFrame:CGRectMake(0, StatusBarHeight, ScreenWidth, ScreenHeight-StatusBarHeight)];
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
    if (_recordTimeLine.timeLineState == RECORDSTOP) {
        PathPlayVC *play = [[PathPlayVC alloc] init];
        [self.navigationController pushViewController:play animated:YES];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
