//
//  BottonControlView.h
//  ScreenRecording
//
//  Created by 马海江 on 2019/8/29.
//  Copyright © 2019 haijiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BottonControlViewDelegate <NSObject>

/**
 重新录制按钮点击
 */
- (void)reRecordBtnClick;

/**
 拖动进度条

 @param sender 进度条
 */
- (void)sliderValueChanged:(UISlider *)sender;

@end

@interface BottonControlView : UIView

@property (nonatomic, weak) id<BottonControlViewDelegate>delegate;

@property (nonatomic, weak) UILabel *currentTimeLab;//当前时间

@property (nonatomic, weak) UILabel *maxTimeLab;//总时间

@property (nonatomic, weak) UISlider *slider;

@end

NS_ASSUME_NONNULL_END
