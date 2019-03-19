//
//  UIColor+ZHL.m
//  测试轨迹
//
//  Created by 沧海小鱼 on 15-1-12.
//  Copyright (c) 2015年 Ilou.inc. All rights reserved.
//

#import "UIColor+ZHL.h"

@implementation UIColor (ZHL)

+ (ZHLColor *)colorRGBWithHex:(long)hexColor
{
    ZHLColor *color = [[ZHLColor alloc] init];
    
    color.red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    color.green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    color.blue = ((float)(hexColor & 0xFF))/255.0;
    
    return color;
}

+ (UIColor*) colorWithHex:(long)hexColor;
{
    return [UIColor colorWithHex:hexColor alpha:1.];
}

+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity
{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}

+ (long)colorToLongValueWithRed:(int)red green:(int)green blue:(int)blue {
    //NSString *redHex = [NSString stringWithFormat:@"%02x" , red];
    //NSString *greenHex = [NSString stringWithFormat:@"%02x" , green];
    //NSString *blueHex = [NSString stringWithFormat:@"%02x" , blue];
    //NSString *colorHex = [NSString stringWithFormat:@"FF%@%@%@" , redHex,greenHex,blueHex];
    
    long _aph = (long)255 << 24; // 默认颜色不透明
    long _red = (long)red << 16;
    long _green = (long)green << 8;
    long _blue = (long)blue;
    
    return _aph + _red + _green + _blue;
}

@end

@implementation ZHLColor

+ (instancetype)colorWithRed:(int)red green:(int)green blue:(int)blue {
    ZHLColor *color = [[ZHLColor alloc] init];
    color.red = red;
    color.green = green;
    color.blue = blue;
    
    return color;
}

@end