

#import "NoteTextFieldCell.h"

@implementation NoteTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"#F6F6F6"];
        
        //文本框
        CGFloat x = 15;
        CGFloat y =  12 ;
        _ljTextField = [[UITextField alloc]initWithFrame:CGRectMake(x, y, SCREEN_W - x - 15  ,50 - 2*y)];
        _ljTextField.delegate = self;
        _ljTextField.returnKeyType = UIReturnKeyDefault;
        _ljTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _ljTextField.font = [UIFont systemFontOfSize:16];
        _ljTextField.backgroundColor = [UIColor colorWithHexString:@"#F6F6F6"];
        
        //此方法为关键方法
        [_ljTextField addTarget:self action:@selector(textFieldTouchDown:) forControlEvents:UIControlEventEditingDidBegin];
        [_ljTextField addTarget:self action:@selector(textFieldWithText:) forControlEvents:UIControlEventEditingChanged];
        [self.contentView addSubview:_ljTextField];
    }
    return self;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if (_delegate && [_delegate conformsToProtocol:@protocol(NoteTextFieldCellDelegate)] && [_delegate respondsToSelector:@selector(ljTextFieldShouldReturn:)]) {
        [_delegate ljTextFieldShouldReturn:textField];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_delegate && [_delegate conformsToProtocol:@protocol(NoteTextFieldCellDelegate)] && [_delegate respondsToSelector:@selector(ljTextFieldBeginEdit:)]) {
        [_delegate ljTextFieldBeginEdit:textField];
    }
}


//绑定值
- (void)textFieldWithText:(UITextField *)textField
{
    if (_delegate && [_delegate conformsToProtocol:@protocol(NoteTextFieldCellDelegate)] && [_delegate respondsToSelector:@selector(bindTextField:)]) {
        [_delegate bindTextField:textField];
    }
}
- (void)textFieldTouchDown:(UITextField *)textField
{
    if (_delegate && [_delegate conformsToProtocol:@protocol(NoteTextFieldCellDelegate)] && [_delegate respondsToSelector:@selector(textFieldTouchDown:)]) {
        [_delegate textFieldTouchDown:textField];
    }
}


@end
