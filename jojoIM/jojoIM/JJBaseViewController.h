//
//  JJBaseViewController.h
//  HealthRecord
//
//  Created by jojo on 16/6/25.
//  Copyright © 2016年 com.jojo.HealthRecord. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SVProgressHUD.h"

@interface JJBaseViewController : UIViewController

@property (nonatomic, strong) NSString *backBarButtontitle;

- (void)addLeftBarButtonItem;
- (void)addRightBarButtonItem;
- (void)addBackBarButtonItem;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)popViewControllerAction;

@end
