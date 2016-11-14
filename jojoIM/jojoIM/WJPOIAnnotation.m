//
//  POIAnnotation.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-16.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "WJPOIAnnotation.h"

@interface WJPOIAnnotation ()

@property (nonatomic, readwrite, strong) WeJuBarPoi *poi;

@end

@implementation WJPOIAnnotation
@synthesize poi = _poi;

#pragma mark - MAAnnotation Protocol

- (NSString *)title
{
    return self.poi.placeTitle;
}

- (NSString *)subtitle
{
    return self.poi.address;
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.poi.latitude, self.poi.longitude);
}

#pragma mark - Life Cycle

- (id)initWithPOI:(WeJuBarPoi *)poi
{
    if (self = [super init])
    {
        self.poi = poi;
        
    }
    
    return self;
}

@end
