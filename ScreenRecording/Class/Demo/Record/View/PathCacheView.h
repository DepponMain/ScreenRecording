//
//  PathCacheView.h
//  ScreenRecording
//
//  Created by hy on 2019/3/15.
//  Copyright © 2019年 haijiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TutorBezierPointEntity;

/**
 *  用于缓存一条完整的路径信息，并且显示在view上
 */

@interface PathCacheView : UIView

- (void)showPath:(CGMutablePathRef)path withPathConfig:(TutorBezierPointEntity *)configEntity;

@end
