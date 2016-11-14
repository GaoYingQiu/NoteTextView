//
//  WeJuBarPoi.h
//  WeJuBar
//
//  Created by JoyDo on 15/4/3.
//  Copyright (c) 2015年 JoyDo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeJuBarPoi : NSObject

@property (nonatomic ,strong) NSString *placeTitle;
@property (nonatomic ,strong) NSString *address;
@property (nonatomic ,assign) BOOL bPositionFlag;

@property (nonatomic, assign) double latitude;// 经纬度
@property (nonatomic, assign) double longitude;

@end
