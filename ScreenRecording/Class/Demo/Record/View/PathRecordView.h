//
//  PathRecordView.h
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZHLRecordTimeLine.h"

typedef NS_ENUM(NSInteger, PointTag) {
    // 起始点
    PointTagBegin = 0,
    
    // 除去 起始点及终点之外的点
    PointTagMiddle = 1,
    
    // 终点
    PointTagEnd = 2,
};

/**
 *  录制的画布实现
 *  1、轨迹使用UIImage的方式保存
 */

@interface PathRecordView : UIView <MaterialRecordProtocol>

/**
 *  时间轴管理器
 */
@property (nonatomic, weak) ZHLRecordTimeLine *recordTimeLine;

/**
 * 当前画笔颜色
 */
@property (nonatomic, strong) ZHLColor *color;

/**
 *  是否橡皮
 */
@property (nonatomic, assign) BOOL isEraser;

@end
