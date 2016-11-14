//
//  ViewController.m
//  jojoIM
//
//  Created by jojo on 16/11/7.
//  Copyright © 2016年 jojo. All rights reserved.
//

#import "ViewController.h"
#import "CreateNoteController.h"
#import "MapViewController.h"
#import "MapPositionController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Note TextView";
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"NoteTextView" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    [button setTitleColor:[UIColor colorWithHexString:@"#171717"] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithHexString:@"#F6B527"]];
    [button addTarget:self action:@selector(editNoteTextViewAction) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 3;
    [self.view addSubview:button];
    
    UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapButton setTitle:@"Map CustomerMApoint" forState:UIControlStateNormal];
    mapButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [mapButton setTitleColor:[UIColor colorWithHexString:@"#171717"] forState:UIControlStateNormal];
    [mapButton setBackgroundColor:[UIColor colorWithHexString:@"#F6B527"]];
    mapButton.layer.cornerRadius = 3;
    [mapButton addTarget:self action:@selector(mapLocationAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mapButton];
    
    
    UIButton *mapPositionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapPositionButton setTitle:@"Map Share Position" forState:UIControlStateNormal];
    mapPositionButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [mapPositionButton setTitleColor:[UIColor colorWithHexString:@"#171717"] forState:UIControlStateNormal];
    [mapPositionButton setBackgroundColor:[UIColor colorWithHexString:@"#F6B527"]];
    mapPositionButton.layer.cornerRadius = 3;
    [mapPositionButton addTarget:self action:@selector(mapChooseLocationAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mapPositionButton];
    
    
    [mapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(@50);
        make.left.mas_equalTo(45);
        make.right.mas_equalTo(-45);
        make.centerY.mas_equalTo(self.view);
    }];
    
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(@50);
        make.left.mas_equalTo(45);
        make.right.mas_equalTo(-45);
        make.bottom.equalTo(mapButton.mas_top).offset(-30);;
    }];
    
    [mapPositionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(@50);
        make.left.mas_equalTo(45);
        make.right.mas_equalTo(-45);
        make.top.equalTo(mapButton.mas_bottom).offset(30);;
    }];
}


-(void)editNoteTextViewAction
{
    CreateNoteController *noteTextViewVC = [[CreateNoteController alloc]init];
    
    [self pushViewController:noteTextViewVC animated:YES];
}

-(void)mapLocationAction
{
    MapViewController *mapVC = [[MapViewController alloc]init];
    [self pushViewController:mapVC animated:YES];
}

-(void)mapChooseLocationAction
{
    MapPositionController *mapVC = [[MapPositionController alloc]init];
    [self pushViewController:mapVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
