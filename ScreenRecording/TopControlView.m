//
//  TopControlView.m
//  ScreenRecording
//
//  Created by 马海江 on 2019/8/29.
//  Copyright © 2019 haijiang. All rights reserved.
//

#import "TopControlView.h"

@interface TopControlView ()

@property (nonatomic, weak) UIView *stateView;


@end

@implementation TopControlView

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
    
    UIView *stateView = [[UIView alloc] initWithFrame:CGRectMake(12, 23, 8, 8)];
    self.stateView = stateView;
    stateView.layer.cornerRadius = 4;
    [self addSubview:stateView];
    
    UILabel *timeLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(stateView.frame)+5, 10, 60, 30)];
    self.timeLab = timeLab;
    timeLab.text = @"00:00";
    timeLab.textAlignment = NSTextAlignmentLeft;
    timeLab.textColor = [UIColor darkGrayColor];
    timeLab.font = FontWithSize(15);
    [self addSubview:timeLab];
    
    NSArray *arr1 = @[@"开始录", @"暂停录", @"停止录"];
    float btnW = (ScreenWidth - CGRectGetMaxX(timeLab.frame) -30)/3;
    for (int i = 0; i < arr1.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(timeLab.frame)+(btnW+10)*i, 10, btnW, 30)];
        button.tag = i+1;
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTitle:arr1[i] forState:UIControlStateNormal];
        button.titleLabel.font = FontWithSize(14);
        button.layer.cornerRadius = 3;
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.layer.borderWidth = 0.5;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    
    NSArray *arr2 = @[@"开始播", @"橡皮擦", @"黑色", @"蓝色", @"绿色"];
    float btnW2 = (ScreenWidth -60)/5;
    for (int i = 0; i < arr2.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10+(btnW2+10)*i, 50, btnW2, 30)];
        button.tag = i+4;
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTitle:arr2[i] forState:UIControlStateNormal];
        button.titleLabel.font = FontWithSize(14);
        button.layer.cornerRadius = 3;
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        button.layer.borderWidth = 0.5;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

- (void)buttonClick:(UIButton *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(topViewBtnClickWithTag:)]) {
        [_delegate topViewBtnClickWithTag:sender.tag];
    }
}

- (void)setSetState:(NSInteger)setState{
    _setState = setState;
    if (setState == 0) {
        self.stateView.backgroundColor = [UIColor greenColor];
    }else if (setState == 1){
        self.stateView.backgroundColor = [UIColor redColor];
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
