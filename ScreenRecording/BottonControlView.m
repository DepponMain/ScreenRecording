//
//  BottonControlView.m
//  ScreenRecording
//
//  Created by 马海江 on 2019/8/29.
//  Copyright © 2019 haijiang. All rights reserved.
//

#import "BottonControlView.h"

@interface BottonControlView ()



@end

@implementation BottonControlView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    self.backgroundColor = [UIColor clearColor];
    
    UIButton *reRecord = [[UIButton alloc] initWithFrame:CGRectMake(8, 0, 50, 30)];
    [reRecord setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [reRecord setBackgroundColor:[UIColor whiteColor]];
    [reRecord setTitle:@"重录" forState:UIControlStateNormal];
    reRecord.titleLabel.font = FontWithSize(14);
    reRecord.layer.cornerRadius = 3;
    reRecord.layer.borderColor = [UIColor lightGrayColor].CGColor;
    reRecord.layer.borderWidth = 0.5;
    [reRecord addTarget:self action:@selector(reRecored) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:reRecord];
    
    UILabel *currentTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(58, 0, 50, 30)];
    self.currentTimeLab = currentTimeLab;
    currentTimeLab.text = @"00:00";
    currentTimeLab.font = [UIFont systemFontOfSize:14];
    currentTimeLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:currentTimeLab];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(108, 0, ScreenWidth - 158 , 30)];
    self.slider = slider;
    [slider setMaximumValue:9999];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:slider];
    
    UILabel *maxTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 50, 0, 50, 30)];
    self.maxTimeLab = maxTimeLab;
    maxTimeLab.text = @"00:00";
    maxTimeLab.font = [UIFont systemFontOfSize:14];
    maxTimeLab.textAlignment = NSTextAlignmentCenter;
    [self addSubview:maxTimeLab];
}

- (void)reRecored{
    if (_delegate && [_delegate respondsToSelector:@selector(reRecordBtnClick)]) {
        [_delegate reRecordBtnClick];
    }
}

- (void)sliderValueChanged:(UISlider *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [_delegate sliderValueChanged:sender];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
