//
//  ViewController.m
//  jojoIM
//
//  Created by jojo on 16/11/7.
//  Copyright © 2016年 jojo. All rights reserved.
//

#import "ViewController.h"
#import "CreateNoteController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Note TextView";
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"click me" forState:UIControlStateNormal];
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
   
}


-(void)editNoteTextViewAction
{
    CreateNoteController *noteTextViewVC = [[CreateNoteController alloc]init];
    
    [self pushViewController:noteTextViewVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
