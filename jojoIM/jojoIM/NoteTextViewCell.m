

#import "NoteTextViewCell.h"
#define bottomViewHeight 43

@implementation NoteTextViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
       // self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"#F6F6F6"];
        
        //文本TextView
        CGFloat y = 8;
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(12, y, SCREEN_W - 2*12, [NoteTextViewCell cellHeight] - 2*y)];
        _textView.font = [UIFont systemFontOfSize:17];
        _textView.backgroundColor = [UIColor colorWithHexString:@"#F6F6F6"];
        [self.contentView addSubview:_textView];
 
        //此方法为关键方法
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTextViewPoint:)];
        _tapGestureRecognizer.delegate = self;
        [_textView addGestureRecognizer:_tapGestureRecognizer];
    }
    return self;
}

+ (CGFloat)cellHeight
{
    return SCREEN_H- 60 - 64;
}

-(void)setCellTextViewAttributeStr:(NSMutableAttributedString *)textViewAttributeStr
{
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;// 字体的行间距
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:17],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    if(textViewAttributeStr){
        self.textView.attributedText = [[NSAttributedString alloc] initWithString:[textViewAttributeStr string] attributes:attributes];
    }else{
         self.textView.text =  @"Edit Note Content";
         self.textView.textColor = [UIColor colorWithHexString:@"#74737C"];
    }
}


-(void)clickTextViewPoint:(UIGestureRecognizer *)ges
{
    if(_delegate){
        [_delegate backTextViewTouchPoint:ges];
    }
    
}

//可继续传递下去。
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
}

@end
