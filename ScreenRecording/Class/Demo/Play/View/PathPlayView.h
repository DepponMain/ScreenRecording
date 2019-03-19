//
//  PathPlayView.h
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MaterialPlayProtocol.h"
#import "PathRecordView.h"

@class ZHLPlayTimeLine;

@interface PathPlayView : UIView <MaterialPlayProtocol>

/**
 *  时间轴管理器
 */
@property (nonatomic, weak) ZHLPlayTimeLine *playTimeLine;

@end
