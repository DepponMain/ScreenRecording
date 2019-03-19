//
//  ZHLRecordTimeLine.h
//  LuPing
//
//  Created by 马海江 on 2019/2/7.
//  Copyright © 2019 马海江. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MaterialRecordProtocol.h"
#import "TutorBezierVideoEntity.h"

typedef enum {
    // 初始状态
    RECORDINIT = 0,
    // 录制中状态
    RECORDING,
    // 暂停状态
    RECORDPAUSE,
    // 已停止
    RECORDSTOP
    
} RecordTimeLineState;

/**
 *  录屏时间轴管理器
 */

@interface ZHLRecordTimeLine : NSObject

/**
 *  时间轴的状态
 */
@property (nonatomic, assign, readonly) RecordTimeLineState timeLineState;

/**
 *  视频信息
 */
@property (nonatomic, strong) TutorBezierVideoEntity *videoEntity;

/**
 *  时间轴时间点
 */
@property (nonatomic, assign, readonly) long time;

/**
 * 记录数据，存储位置
 */
+ (instancetype)initWithDataSavePath:(NSString *)path;

/**
 * 添加素材
 */
- (void)addMaterial:(id<MaterialRecordProtocol>)material;

/**
 *  移除素材
 */
- (void)removeMaterial:(id<MaterialRecordProtocol>)material;

/**
 *  开始录屏
 */
- (void)beginRecord;

/**
 *  录屏暂停
 */
- (void)pauseRecord;

/**
 *  停止录屏
 */
- (void)stopRecord;


@end
