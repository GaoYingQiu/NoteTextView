

#import <UIKit/UIKit.h>
#import "NoteTextFieldDelegate.m"

@interface NoteTextFieldCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic, weak) id <NoteTextFieldCellDelegate> delegate;
@property (nonatomic ,strong) UITextField *ljTextField;
@property (nonatomic ,strong) UILabel *ljTitleLabel;
 
@end
