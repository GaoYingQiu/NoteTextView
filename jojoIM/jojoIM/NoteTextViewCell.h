//
//  DynamicPublishInputCell.h
//  WeJu
//
//  Created by Rongrong Lai on 5/23/14.
//  Copyright (c) 2014 Changzhou Duoju Network Technology Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NoteTextViewCellDelegate <NSObject>

@optional
//呼出键盘
-(void)backTextViewTouchPoint:(UIGestureRecognizer *)ges;

@end

@interface NoteTextViewCell : UITableViewCell

@property (nonatomic, strong)   UITextView *textView;
@property (nonatomic, strong)   UILabel *placeHolderLabel;

@property (nonatomic, assign)  BOOL bTextHeightMoreCellHeight;

@property (nonatomic, strong)   UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, weak)     id <NoteTextViewCellDelegate> delegate;

@property (nonatomic ,strong) NSMutableAttributedString *textViewAttributeStr;

-(void)setCellTextViewAttributeStr:(NSMutableAttributedString *)textViewAttributeStr;

+ (CGFloat)cellHeight;

@end
