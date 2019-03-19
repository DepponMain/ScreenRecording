//
//  PathImageView.h
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TutorBezierPointEntity;

#define PathImageViewNullPoint  CGPointMake(-200, -200)

/**
 *  专门用于记录轨迹的图层
 */

@interface PathImageView : UIImageView

/**
 * configEntity 用于设置线条颜色宽度等配置
 */
- (void)beginPath:(CGPoint)beginPoint withConfigEntity:(TutorBezierPointEntity *)configEntity;


- (void)movePath:(CGPoint)movePoint;


- (void)endPath:(CGPoint)endPoint;

@end
