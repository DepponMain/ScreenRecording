//
//  UIColor+ZHL.h
//  测试轨迹
//
//  Created by 沧海小鱼 on 15-1-12.
//  Copyright (c) 2015年 Ilou.inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZHLColor;

@interface UIColor (ZHL)

+ (UIColor *)colorWithHex:(long)hexColor;
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;

+ (long)colorToLongValueWithRed:(int)red green:(int)green blue:(int)blue;

+ (ZHLColor *)colorRGBWithHex:(long)hexColor;

@end

@interface ZHLColor : NSObject

@property (nonatomic, assign) int red;

@property (nonatomic, assign) int green;

@property (nonatomic, assign) int blue;

+(instancetype)colorWithRed:(int)red green:(int)green blue:(int)blue;

@end
