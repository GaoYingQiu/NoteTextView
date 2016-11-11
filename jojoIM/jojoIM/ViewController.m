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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Note TextView";
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"NoteTextView Button" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [button setTitleColor:[UIColor colorWithHexString:@"#428253"] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithHexString:@"#F6F6F6"]];
    [button addTarget:self action:@selector(editNoteTextViewAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.height.equalTo(@55);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.centerY.mas_equalTo(self.view);
    }];
    
    
    UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapButton setTitle:@"Map Button" forState:UIControlStateNormal];
    mapButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [mapButton setTitleColor:[UIColor colorWithHexString:@"#428253"] forState:UIControlStateNormal];
    [mapButton setBackgroundColor:[UIColor colorWithHexString:@"#F6F6F6"]];
    [mapButton addTarget:self action:@selector(mapLocationAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mapButton];
    [mapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.equalTo(@55);
        make.left.mas_equalTo(30);
        make.right.mas_equalTo(-30);
        make.top.equalTo(button.mas_bottom).offset(30);;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
