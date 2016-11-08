//
//  AccountTextFieldDelegate.m
//  LvJinKu
//
//  Created by lvjinku on 15/9/14.
//  Copyright (c) 2015年 lvjinku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol NoteTextFieldCellDelegate <NSObject>

@optional
-(void)aljTextFieldShouldBeginEdit:(UITextField *)textField;
-(void)bindTextField:(UITextField *)textField;
-(void)ljTextFieldBeginEdit:(UITextField *)textField;
-(void)ljTextFieldDidEndEdit:(UITextField *)textField;
-(void)ljTextFieldShouldReturn:(UITextField *)textField;
-(void)textFieldTouchDown:(UITextField *)textField;


@end
