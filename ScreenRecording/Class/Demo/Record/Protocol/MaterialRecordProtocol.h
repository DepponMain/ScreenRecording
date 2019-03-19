//
//  MaterialRecordProtocol.h
//  LuPing
//
//  Created by 马海江 on 2019/2/7.
//  Copyright © 2019 马海江. All rights reserved.
//

#ifndef MaterialRecordProtocol_h
#define MaterialRecordProtocol_h

#define ZHLRecordLogBegin                         NSLog(@"~~~ %@ ~~~ begin" , [self class]);
#define ZHLRecordLogPause                         NSLog(@"~~~ %@ ~~~ pause" , [self class]);
#define ZHLRecordLogStop                          NSLog(@"~~~ %@ ~~~ stop" , [self class]);

@class ZHLRecordTimeLine;


/**
 *  素材需要遵循的【录屏】协议
 */
@protocol MaterialRecordProtocol <NSObject>

#pragma mark - property
// -------------------- 以下属性，为素材必须拥有的属性--------------------
/**
 *  时间轴管理器
 */
@property (nonatomic, weak) ZHLRecordTimeLine *recordTimeLine;
/**
 *  返回录屏数据是否全部存储完毕<用于判断是否销毁TimeLineManager，因为【时间轴Manager】和【Material素材】之间存在循环强引用>
 */
//@property (nonatomic, assign) BOOL isFinishRecord;


#pragma mark - method

@required

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

/**
 *  自定义存储录屏数据实现
 */
- (void)saveRecord;

/**
 *  返回需要存储的数据，可以依赖ZHLTimeLine的统一数据存储管理。 也可以自行通过【saveRecord】实现
 */
- (NSMutableArray *)getSaveData;

@end


#endif /* MaterialRecordProtocol_h */
