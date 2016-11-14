//
//  JJBaseViewController.m
//  HealthRecord
//
//  Created by jojo on 16/6/25.
//  Copyright © 2016年 com.jojo.HealthRecord. All rights reserved.
//

#import "JJBaseViewController.h"

@implementation JJBaseViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor =  LJBackgroundColor;
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithHexString:@"#171717"]];
    self.navigationController.navigationBar.translucent = NO;//设置为不透明
    self.navigationController.navigationBar.barTintColor= [UIColor colorWithHexString:@"#F6B527"];
    
//    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:NaviBar_Title_Font, NSFontAttributeName,NaviBar_Title_FontColor, NSForegroundColorAttributeName,  nil]];
    
    [self addLeftBarButtonItem];
    [self addRightBarButtonItem];
    
    
    UIImageView *lineView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    lineView.hidden = YES;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

//滑动，pop
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


#pragma mark - Customer Methods

- (void)addLeftBarButtonItem {
    if ([self.navigationController respondsToSelector:@selector(popViewControllerAnimated:)] && self.navigationController.viewControllers.count >= 2) {
        [self addBackBarButtonItem];
    }
}

- (void)addRightBarButtonItem {
    
}

- (void)addBackBarButtonItem {
    
    //设置拉伸样式 图片将会用于nav的back按钮
    UIImage *backButtonImage = [NaviBar_LeftIcon_Normal resizableImageWithCapInsets:UIEdgeInsetsMake(0, NaviBar_LeftIcon_Normal.size.width, 0, 0)];
    UIImage *backButtonImageP = [NaviBar_LeftIcon_Highlighted resizableImageWithCapInsets:UIEdgeInsetsMake(0, NaviBar_LeftIcon_Highlighted.size.width, 0, 0)];
    
    //改变nav的back图片
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImageP forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
}


- (void)popViewControllerAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
  //  if (self.backBarButtontitle) {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
        backItem.title = @"";
        self.navigationItem.backBarButtonItem = backItem;
   // }
    [self.navigationController pushViewController:viewController animated:animated];
}

@end
