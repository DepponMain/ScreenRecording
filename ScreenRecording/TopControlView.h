//
//  TopControlView.h
//  ScreenRecording
//
//  Created by 马海江 on 2019/8/29.
//  Copyright © 2019 haijiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TopControlViewDelegate <NSObject>

/**
 按钮点击

 @param tag 1：开始录  2：暂停录  3：停止录  4：开始播  5：橡皮擦  6：黑色  7：蓝色  8：绿色
 */
- (void)topViewBtnClickWithTag:(NSInteger)tag;

@end

@interface TopControlView : UIView

@property (nonatomic, weak) id<TopControlViewDelegate>delegate;


@property (nonatomic, assign) NSInteger setState;//设置状态 0：未录制  1：录制中

@property (nonatomic, weak) UILabel *timeLab;//时间


@end

NS_ASSUME_NONNULL_END
