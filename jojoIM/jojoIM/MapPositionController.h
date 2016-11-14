//
//  MapPositionController.h
//  WeJuBar
//
//  Created by JoyDo on 15/3/25.
//  Copyright (c) 2015年 JoyDo. All rights reserved.
//

#import "JJBaseViewController.h"
#import "PRTween.h"
#import "WeJuBarPoi.h"
#import <AMapSearchKit/AMapSearchAPI.h>

@protocol MapPositionControllerDelegate <NSObject>

@optional

- (void)onSelectedMapPosition:(WeJuBarPoi *)positionPOI;

@end

@interface MapPositionController : JJBaseViewController
{
  
    UIImageView *_locationImageView;
    UIView *_searchBgView;
    UISearchBar *_searchBar;
    UISearchDisplayController *_displayController;
    UIButton *_userLocationButton;
    
    MAMapView *_mapView;
    AMapSearchAPI *_search; //POI搜索
    CLLocation *_moveTargetLocation; //目标地经纬度
 
    //poi检索的表格
    UITableView *_chooseResultTable;
    PRTweenOperation *_activeTweenOperation;
}

@property (nonatomic, weak) id <MapPositionControllerDelegate> delegate;

@end
