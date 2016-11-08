//
//  UIColor+Extension.h
//  mp_business
//
//  Created by pengkaichang on 14-10-10.
//  Copyright (c) 2014年 com.soudoushi.makepolo. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorRGB(r, g, b)             [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define UIColorRGBA(r, g, b, a)         [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define LJBackgroundColor  [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]
#define LJBlackColor       [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]
#define LJGrayColor       [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]

#define LJGray1Color      [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]
#define LJGray2Color      [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0]
#define LJGray3Color      [UIColor colorWithRed:223/255.0 green:223/255.0 blue:223/255.0 alpha:1.0]
#define LJGray4Color      [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1.0]
#define LJGray5Color      [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]


@interface UIColor (Extension)
//颜色转换 IOS中十六进制的颜色转换为UIColor
+ (UIColor*) colorWithHexString:(NSString*)color;
+ (UIColor *) colorWithHexString:(NSString *)color alpha:(float)alpha;
@end
