//
//  Config.h

//
//  Created by 杨康 on 16/2/1.
//  Copyright © 2016年 CN. All rights reserved.
//

//#ifndef Config_h
#define Config_h

#define SCREEN_W [UIScreen mainScreen].bounds.size.width
#define SCREEN_H  [UIScreen mainScreen].bounds.size.height
#define WIDTH [[UIScreen mainScreen]bounds].size.width/320
#define HEIGHT [[UIScreen mainScreen]bounds].size.width/320

#define iOS7 ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0)
#define iOS8 ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)
#define iOS9 ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 9.0)
#define iOS10 ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 10.0)

#define NAV_TITLE_FONT 22
#define COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define  DocumentPath(d) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:d]


#ifdef DEBUG // 调试状态, 打开LOG功能
#define NSLog(...) NSLog(__VA_ARGS__)
#else // 发布状态, 关闭LOG功能
#define NSLog(...)

#endif
