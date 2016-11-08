//
//  CreateNoteController.h
//  WeJuBar
//
//  Created by JoyDo on 15/3/23.
//  Copyright (c) 2015年 JoyDo. All rights reserved.
//

#import "JJBaseViewController.h"
#import "NoteTextFieldCell.h"
#import "NoteTextViewCell.h"


@interface CreateNoteController : JJBaseViewController

@property (nonatomic ,strong) NSString *noteTitle; //笔记标题
@property (nonatomic ,strong) NSString *content;//笔记内容
@property (nonatomic ,strong) NSMutableAttributedString *textViewAttribute;//活动内容,图片

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic ,strong) UITextField *noteTitleField;
@property (nonatomic ,strong) UIToolbar *toolBar;

@end
