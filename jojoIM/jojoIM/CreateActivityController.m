//
//  CreateActivityController.m
//  WeJuBar
//
//  Created by JoyDo on 15/3/23.
//  Copyright (c) 2015年 JoyDo. All rights reserved.
//

#import "CreateActivityController.h"
#import "RegistItem.h"
#import "WJBarNavigationController.h"
#import "WJSandbox.h"
#import "ApplyField.h"
#import "PreviewActivityController.h"


@interface CreateActivityController () <LBSServiceDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {

    NSMutableArray *registItemsArr;         //自定义项
    NSInteger needRemoveRegistItemIndex;    //需要移除的自定义项 index
    RegistItem *operateRegistItem;          //操作的item
    
    BOOL textViewEditing;                   //去预览，还是完成
    BOOL bTextHeightMoreCellHeight;         //textView内容 高度是否超过cell 原有高度
    CGFloat keyboardheight;                 //键盘高度
    CGFloat textMoreHeight;                 //textView内容高度
    NSIndexPath *_selectedIndexPath;        //选中的indexPath
    NSIndexPath *_lastSelectedIndexPath;    //选中的indexPath
    NSMutableArray *attachImages ;          //图片数组
    NSInteger uploadImageIndex;             //上传的图片索引
    NSMutableArray *contentArr;             //分割的图文数组
    
    double  _keyboardAnimationDuration;
    NSInteger _keyboardAnimationCurve;
    
    UITapGestureRecognizer *clickPointGes;

}

@end

@implementation CreateActivityController
@synthesize toolBar;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bAddHeader = NO;
        self.bAddFooter = NO;
        registItemsArr = [[NSMutableArray alloc]init];
        attachImages = [[NSMutableArray alloc]init];
        uploadImageIndex = 0;
        self.limitSignPeopleCount = @"0";
        [self addKeyboardNotification];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _bFromActivityManageFlag ? NSLocalizedString(@"Update Activity", @"修改活动") : NSLocalizedString(@"Organize Activity", @"组织活动");
    UIColor *greenColor = WJBarGreenColor;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithTitle:_bFromActivityManageFlag ?NSLocalizedString(@"Save", @"保存") :NSLocalizedString(@"Publish", @"发布") target:self action:@selector(clickRightActionButton) textColor:greenColor  positionLeft:NO];
    
    //initDatas
    //不是来自活动管理
    if(!_bFromActivityManageFlag){
        //设置默认时间
        [self setDefaultTime];
        //自定义项
        NSArray *defaultItems =  [self writeDefaultItems];
        [registItemsArr addObjectsFromArray:defaultItems];
        _activityTitle = @"";
    }
    
    //tableView
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
    self.tableView.showsVerticalScrollIndicator = NO;
    [self createToolBarForTextView];
    [self createToolBarForTextField];
    
    //手势
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    
    //来自管理
    if(_bFromActivityManageFlag){
        [self requestActivityDetail];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0: return 2;   break;
        case 1: return 2;   break;
        case 2: return 2;   break;
        case 3: return 1;   break;
        default:
            return 1;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 44.0f;
    switch (indexPath.section) {
        case 0:
        {
            if(indexPath.row == 1){
                height = [ActivityTextViewCell cellHeight];
                
                if(bTextHeightMoreCellHeight){
                    height = textMoreHeight + 51.0;
                }
            }else {
                height = 50.0f;
            }
            break;
        }
        
        case 1:
        {
            if(indexPath.row == 0 ){
                height = 44.0f;
            }else if(indexPath.row == 1){
                 if(_selectedIndexPath && _selectedIndexPath.row == indexPath.row && _selectedIndexPath.section == indexPath.section){
                     height = [SignTimeCell cellHeightWithFlag:YES];
                 }else{
                     height = [SignTimeCell cellHeightWithFlag:NO];
                 }
            }
            break;
        }
        
        case 2:
        {
            if(_selectedIndexPath && _selectedIndexPath.row == indexPath.row && _selectedIndexPath.section == indexPath.section){
                height = [SignTimeCell cellHeightWithFlag:YES];
            }else{
                height = [SignTimeCell cellHeightWithFlag:NO];
            }
            break;
        }
            
        case 4:
        {
            if(indexPath.row == 0){
                height = [RegistrationItemsCell cellHeightByItems:registItemsArr];
            }
            break;
        }
        default:
            break;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
 
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    NSInteger row  = indexPath.row;
    switch (indexPath.section) {
        case 0:
        {
            if(row == 0){
                cell = [self getActivityTextCell:indexPath];
            }else if(row == 1){
                cell = [self getActivityTextViewCell];
            }
            break;
        }
        case 1:
        {
            if(row == 0){
                cell = [self getActivityTextCell:indexPath];
            }else{
                cell = [self getSignTimeCellWithIndexPath:indexPath];
            }
            break;
        }
            
        case 2:
        {
            cell = [self getSignTimeCellWithIndexPath:indexPath];
            break;
        }
            
        case 3:{
            if(row == 0){
                 cell = [self getMapPositonCell];
            }
            break;
        }
            
        case 4:
        {
            if(row == 0){
                cell = [self getRegistrationItemsCell];
            }
            break;
        }
        default:
            break;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self hideKeyboard];
    NSInteger row  = indexPath.row;
    switch (indexPath.section) {
         
        case 1:
        {
            if(row != 0){
               
                [self changePickerCellHeight:indexPath];
            }
            break;
        }
            
        case 2:
        {
            [self changePickerCellHeight:indexPath];
            break;
        }
            
        case 3:{
            
            if(row == 0){
                [self selectMapPosition];
            }
            break;
        }
        default:
            break;
    }
}


-(void)changePickerCellHeight:(NSIndexPath *)indexPath{
    
    if(!_selectedIndexPath)
    {
        
        _selectedIndexPath = indexPath;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        
        BOOL isSelectSame = (_selectedIndexPath.row == indexPath.row && _selectedIndexPath.section == indexPath.section);
        
        if(isSelectSame){
            
            _selectedIndexPath = nil;
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else{
            
            
            NSIndexPath *tempIndexpath = [_selectedIndexPath copy];
            _selectedIndexPath = nil;
            
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:tempIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            _selectedIndexPath = indexPath;
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];//滚到可视区
        
        if(indexPath.section == 2 && indexPath.row == 0){
            
            NSIndexPath *endTimeIndexPath  = [NSIndexPath  indexPathForRow:1 inSection:2];
            [self.tableView reloadRowsAtIndexPaths:@[endTimeIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark - UITableViewCells

- (ActivityTextFieldCell *)getActivityTextCell:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row  = indexPath.row;
    static NSString *CellIdentifier = @"ActivityTextCell";
    ActivityTextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[ActivityTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
  
    //标记textField的tag
    if(section == 0 && row == 0){
        cell.activityField.tag = 1024;
        cell.activityField.text = self.activityTitle;
        cell.activityField.placeholder = NSLocalizedString(@"input activity title", @"输入活动主题");
        cell.activityField.keyboardType = UIKeyboardTypeDefault;
        cell.activityField.returnKeyType = UIReturnKeyDone;
    }else if(section == 1 && row == 0){
        
        cell.activityField.tag = 1025;
        cell.activityField.keyboardType = UIKeyboardTypeNumberPad;
        if([_limitSignPeopleCount integerValue] > 0){
            cell.activityField.text = [NSString stringWithFormat:NSLocalizedString(@"Admit Sign People Count" , "允许%@人报名"),_limitSignPeopleCount];
        }else{
            cell.activityField.text = nil;
        }
        cell.activityField.placeholder = NSLocalizedString(@"Not limit apply people count", @"不限报名人数");
    }
    
    return cell;
}

- (SignTimeCell *)getSignTimeCellWithIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    static NSString *CellIdentifier = @"SignTimeCell";
    SignTimeCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[SignTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
   
    if(section == 1){
        
        cell.datePicker.tag = 1000 + indexPath.row;
        if(indexPath.row == 1){
            
            cell.signLabel.text = NSLocalizedString(@"Sign cut-off time", @"报名截止");
            cell.signTime = self.activityCutOffTime;
        }
    }else if(section == 2){
        
        cell.datePicker.tag = 2000 + indexPath.row;
        if(indexPath.row == 0){
            
            cell.signLabel.text = NSLocalizedString(@"Activity start time", @"活动开始");
            cell.signTime = self.activityStartTime;
        }else if(indexPath.row == 1){
            
            cell.signLabel.text = NSLocalizedString(@"Activity end time", @"结束");
            cell.signTime = self.activityEndTime;
            cell.datePicker.minimumDate = [self timeIntervalToDate:self.activityStartTime]; //结束最小时间为活动开始时间
           
        }
    }
    
    //高亮字体颜色
    if(_selectedIndexPath && _selectedIndexPath.row == indexPath.row){
        cell.signTimeLabel.textColor = WJBarGreenColor;
    }else {
        cell.signTimeLabel.textColor = WJBarBlackColor;
    }
    
    return cell;
}

- (MapPositionCell *)getMapPositonCell
{
    static NSString *CellIdentifier = @"MapPositionCell";
    MapPositionCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[MapPositionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell  updateChoosePlaceLabelText:_selectedMapPositionStr];
    return cell;
}

- (RegistrationItemsCell *)getRegistrationItemsCell
{
    static NSString *CellIdentifier = @"RegistrationItemsCell";
    RegistrationItemsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[RegistrationItemsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    [cell updateWithRegistItems:registItemsArr];
    
     return cell;
}

- (ActivityTextViewCell *)getActivityTextViewCell
{
    static NSString *CellIdentifier = @"ActivityTextViewCell";
    ActivityTextViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[ActivityTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.bottomView.tag = 1100;
        cell.delegate = self;
    }
    cell.contentView.clipsToBounds = YES;
    cell.bTextHeightMoreCellHeight = bTextHeightMoreCellHeight;
    if(textViewEditing){
        cell.bottomView.hidden = YES;
    }else{
        cell.bottomView.hidden = NO;
    }
    cell.textView.delegate = self;
    cell.textViewAttributeStr= _textViewAttribute;
    
    return cell;
}


#pragma mark - RegistrationItemsCellDelegate

-(void)editRegistButton:(NSInteger)buttonTag
{

    if(buttonTag == registItemsArr.count -1){
        //点击加号
          [self goCustomerItemController:nil];
        
    }else{
    
        operateRegistItem  = [registItemsArr objectAtIndex:buttonTag];
        
        if(operateRegistItem.removeStatu == 1){
            //移除或编辑
            needRemoveRegistItemIndex = buttonTag;
            UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"customer registItem", @"自定义项") delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Edit", @"编辑"), NSLocalizedString(@"Remove", @"删除"),nil];
            sheet.tag = 1009;
            [sheet showInView:self.view];
            
        }else{
            //选择
            if (operateRegistItem.mustSelect == 1){ //必选项
                return ;
            }else{
                operateRegistItem.selectStatu =  operateRegistItem.selectStatu==1 ? 0 : 1;
            }
            [registItemsArr replaceObjectAtIndex:buttonTag withObject:operateRegistItem];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
         //操作相册或图片
            case 1024:
            {
                switch (buttonIndex)
                {
                    case 0:
                    {
                        [self showCamera];
                        break;
                    }
                    case 1:
                    {
                        [self showPhoto];
                        break;
                    }
                    default:
                        break;
                }
                break;
            }
        
            //操作自定义选择项
            case 1009:
            {
                switch (buttonIndex)
                {
                    case 0:
                    {
                        //编辑
                        [self goCustomerItemController:operateRegistItem];
                        break;
                    }
                    case 1:
                    {
                        //删除
                        [registItemsArr removeObjectAtIndex:needRemoveRegistItemIndex];
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
                        break;
                    }
                    default:
                        break;
                }
                break;
            }
                
            default:
                break;
    }
}



#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    //originalImage = [originalImage fixOrientationImage];
    
    UIImage *image = [originalImage image:IPHONE_WIDTH * 2.0];
    [self sendImages:[NSArray arrayWithObject:image]]; //拍照

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self hideKeyboard];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


//创建一个图片属性
-(NSAttributedString *)createPictureAttributedStr:(UIImage *)image{
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    CGFloat scaleFactor =  9;
    textAttachment.image = [UIImage imageWithCGImage:image.CGImage scale:scaleFactor orientation:UIImageOrientationUp];
    return [NSAttributedString attributedStringWithAttachment:textAttachment];
}

//根据图片宽高创建一个NSTextAttachment
-(NSAttributedString *)createPictureAttributeStr:(NSString *)imageUrl Width:(CGFloat)width Height:(CGFloat) height {
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]] scale:9];
    return [NSAttributedString attributedStringWithAttachment:textAttachment];
}


//设置图片
- (void)sendImages:(NSArray *)images
{
    NSIndexPath *textViewPath = [NSIndexPath indexPathForRow:1  inSection:0];
    ActivityTextViewCell *cell = (ActivityTextViewCell *)[self.tableView cellForRowAtIndexPath:textViewPath]; //得到本次点击的cell
    _textViewAttribute = [[NSMutableAttributedString alloc]initWithAttributedString:cell.textView.attributedText];
    NSMutableAttributedString *attributedString = _textViewAttribute;
 
    //插入图片的时候，遍历是否有图片，如果没有，则判断文字是否相等于空，如果相等，则清空。
    __block BOOL bHasImage = NO;
    [_textViewAttribute enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, _textViewAttribute.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        //检查类型是否是自定义NSTextAttachment类
        if (value && [value isKindOfClass:[NSTextAttachment class]]) {
            bHasImage = YES;
            
            *stop = YES; //马上停止
        }
    }];
    
    //字体颜色
    UIColor *realColor = WJBarBlackColor;
    [attributedString addAttributes:@{NSForegroundColorAttributeName : realColor,   NSFontAttributeName : [UIFont systemFontOfSize:15]} range:NSMakeRange(0, attributedString.length)];
    
   
    if(bHasImage == NO){
        NSString *textStr =  [_textViewAttribute string];
        if([textStr isEqualToString:NSLocalizedString(@"Activity detail time,place,event", @"活动详情，详细说明时间、地点、事件")])
        {
            attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:[[NSAttributedString alloc]initWithString:@""]];
     
            //插入图片
            NSUInteger loc = 0;
            UIImage *img = nil;
            for (int i= 0; i< images.count; i++) {
                img = images[i];
                
                 NSUInteger needInsertLoc = loc;
                if(i > 0){
                    BOOL bHasPic = [self hasBeforePictureProcess:loc-1 InAttributeStr:attributedString];
                    attributedString = [self checkHasBeforePictureProcess:loc-1 InAttributeStr:attributedString];
                    if(bHasPic){
                        needInsertLoc ++;
                    
                    } else{
                        loc ++;
                    }
                }else{
                      loc ++;
                }
                
                [attributedString insertAttributedString:[self createPictureAttributedStr:img] atIndex:needInsertLoc];
                
            }
            
        }else{
            
            NSUInteger loc = cell.textView.selectedRange.location;
            UIImage *img = nil;
            for (int i= 0; i< images.count; i++) {
                img = images[i];
                 BOOL bHasPic = [self hasBeforePictureProcess:loc-1 InAttributeStr:attributedString];
                 attributedString = [self checkHasBeforePictureProcess:loc-1 InAttributeStr:attributedString];
                NSUInteger needInsertLoc = loc;
                if(bHasPic){
                    needInsertLoc ++;
                }else{
                    loc ++;
                }
                [attributedString insertAttributedString:[self createPictureAttributedStr:img] atIndex:needInsertLoc];
            }
        }
    }else{
        NSUInteger loc = cell.textView.selectedRange.location;
        UIImage *img = nil;
        for (int i= 0; i< images.count; i++) {
              img = images[i];
              BOOL bHasPic = [self hasBeforePictureProcess:loc-1 InAttributeStr:attributedString];
              attributedString = [self checkHasBeforePictureProcess:loc-1 InAttributeStr:attributedString];
              NSUInteger needInsertLoc = loc;
              if(bHasPic){
                   needInsertLoc ++;
              }else{
                  loc ++;
              }
             [attributedString insertAttributedString:[self createPictureAttributedStr:img] atIndex:needInsertLoc];
            
        }
    }
    
    
     cell.textView.attributedText = attributedString;
    //选择完图片后，重新计算高度
    [self countTextViewCellHeight: cell.textView];
    [self hideKeyboard];
}


//判断光标前一个loc 是否为图片,如果是图片增加一换行
-(NSMutableAttributedString *)checkHasBeforePictureProcess:(NSUInteger ) loc InAttributeStr:(NSMutableAttributedString *)attributeString{
    

    
    NSMutableAttributedString *plainString = attributeString ;
    
    [plainString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(loc, 1) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        //检查类型是否是自定义NSTextAttachment类
        if (value && [value isKindOfClass:[NSTextAttachment class]]) {
            
             NSMutableAttributedString *changLineStr = [[NSMutableAttributedString alloc]initWithString:@"\n"]; //替换下标的偏移量
            [plainString insertAttributedString:changLineStr  atIndex:loc+1];
        }
    }];
    
    return plainString;
}

-(BOOL)hasBeforePictureProcess:(NSUInteger ) loc InAttributeStr:(NSMutableAttributedString *)attributeString{
    
    __block BOOL bHasPic = NO;
    NSMutableAttributedString *plainString = attributeString ;
    
    [plainString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(loc, 1) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        //检查类型是否是自定义NSTextAttachment类
        if (value && [value isKindOfClass:[NSTextAttachment class]]) {
            bHasPic = YES;
        }
    }];
    
    return bHasPic;
}




//分割成数组
- (NSMutableArray *)getPlainString {
    
    //要返回的保存的数据
    NSMutableArray *dataArr = [[NSMutableArray alloc]init];
    
    //目的文本
    NSIndexPath *textViewPath = [NSIndexPath indexPathForRow:1  inSection:0];
    ActivityTextViewCell *cell = (ActivityTextViewCell *)[self.tableView cellForRowAtIndexPath:textViewPath]; //得到本次点击的cell
    //AttributedString
    NSMutableAttributedString *plainString = [[NSMutableAttributedString alloc]initWithAttributedString:cell.textView.attributedText]; //替换下标的偏移量
    NSUInteger length = plainString.length;
    if (length == 0) {
        
        //没有输入任何内容，返回空
        return nil;
    }else{
        NSString *textString=[plainString string];
        if([textString isEqualToString:NSLocalizedString(@"Activity detail time,place,event", @"活动详情，详细说明时间、地点、事件")])
        {
            return nil;
        }
    }
    
    [attachImages removeAllObjects];
    //用来存储图片range位置
    NSMutableArray *pictureRangeArr = [[NSMutableArray alloc]init];
    //遍历，寻找图片Range
    [plainString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        //检查类型是否是自定义NSTextAttachment类
        if (value && [value isKindOfClass:[NSTextAttachment class]]) {
            
            NSString *locationStr = [NSString stringWithFormat:@"%lu",(unsigned long)range.location];
            [pictureRangeArr addObject:locationStr];
            
            //保留图片
            NSTextAttachment *attach =  (NSTextAttachment *)value;
            UIImage *image = attach.image;
            if(image){
                [attachImages addObject:image];
            }else{ //附近图片为Nil时，放一张空图片，防止奔溃
                [attachImages addObject:[UIImage imageNamed:@"activityEmpty.png"]];
            }
        }
    }];
    
    
    //根据图片来截取文本
    NSString *textString=[plainString string];
    
    __block NSUInteger startLocation = 0;
    __block NSUInteger textLength = 0;
    __block NSUInteger lastLength = 0; //前一个长度
    for (int index = 0; index < pictureRangeArr.count ; index ++) {
        
        NSString *locationStr = [pictureRangeArr objectAtIndex:index];
        __block NSUInteger location = [locationStr integerValue];
        
        // 要截取文本内容长度
        if(location > 0){ //第一张为图片的时候，文字长度为0
            
            textLength = location  - 1 - lastLength; //1为图片的长度
            if(index == 0){
                textLength ++;
            }
            
            //截取文本内容
            NSRange textRange =  NSMakeRange (startLocation, textLength);
            NSString *text = [textString substringWithRange:textRange];
            NSMutableDictionary *dic1 = [[NSMutableDictionary alloc]init];
            [dic1 setObject:@"1" forKey:@"type"];
            [dic1 setObject:text forKey:@"value"]; //添加文本内容
            [dataArr addObject:dic1];
            
            NSMutableDictionary *dic2 = [[NSMutableDictionary alloc]init];
            [dic2 setObject:@"2" forKey:@"type"];
            [dic2 setObject:@"" forKey:@"value"]; //添加一个标识图片
            [dataArr addObject:dic2];
   
            startLocation = location + 1; //下一个文本的开始位置
            lastLength = location; //记录前一个文本的长度
            
        }else{
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:@"2" forKey:@"type"];
            [dic setObject:@"" forKey:@"value"]; //添加一个标识图片
            [dataArr addObject:dic];
        }
    }
    
    
    
    //再处理最后一张图片后面是否还有文本
    if(pictureRangeArr.count > 0){
        NSString *locationStr = [pictureRangeArr objectAtIndex:pictureRangeArr.count - 1];
        
        __block NSUInteger lastOnelocation = [locationStr integerValue];
        textLength = textString.length  - (lastOnelocation + 1);
        if(textLength > 0 ){
            
            NSRange textRange =  NSMakeRange (lastOnelocation+1, textLength);
            NSString *text = [textString substringWithRange:textRange];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:@"1" forKey:@"type"];
            [dic setObject:text forKey:@"value"]; //添加文本内容
            [dataArr addObject:dic];
        }
    }else{
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:@"1" forKey:@"type"];
        [dic setObject:textString forKey:@"value"]; //添加文本内容
        [dataArr addObject:dic];
    }
    
    return dataArr;
}

#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerController2:(QBImagePickerController *)imagePickerController didFinishPickingMediaWithInfo:(id)info
{
    if(imagePickerController.allowsMultipleSelection)
    {
        NSArray *mediaInfoArray = (NSArray *)info;
        NSMutableArray *images = [NSMutableArray array];
        for (NSInteger i = 0; i < mediaInfoArray.count; i++)
        {
            NSDictionary *item = [mediaInfoArray objectAtIndex:i];
            UIImage *originalImage = [item objectForKey:UIImagePickerControllerOriginalImage];
            UIImage *targetImage = [originalImage imageByScalingToWidth:IPHONE_WIDTH * 2.0];
            [images addObject:targetImage];
        }
        [self sendImages:images]; //相册
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)imagePickerControllerDidCancel2:(QBImagePickerController *)imagePickerController
{
    [self hideKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)imagePickerController:(QBImagePickerController *)imagePickerController descriptionForNumberOfPhotos:(NSUInteger)numberOfPhotos
{
    return [NSString stringWithFormat:NSLocalizedString(@"Photo %d", @"图片%d张"), numberOfPhotos];
}



#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
   [self countTextViewCellHeight:textView];
    textView.font = [UIFont systemFontOfSize:15];
    
    NSUInteger len1=textView.text.length;
    textView.selectedRange = NSMakeRange(len1, 0);
    //需要用一下滚动操作的方法，并且把selectedRange属性值作为Range值传递进去
    [textView scrollRangeToVisible:textView.selectedRange];
}


//计算textView的高度
-(void)countTextViewCellHeight :(UITextView *)textView {
    _textViewAttribute = [[NSMutableAttributedString alloc]initWithAttributedString:textView.attributedText];
    
    CGRect rect = textView.frame;
    CGFloat changeHeight = [ToolUtil calculating_Text_Height_1_Width:(IPHONE_WIDTH - 30) WithString:textView.attributedText];
    //textView.contentSize.height;
    
    //记录高度
    if( changeHeight >= [ActivityTextViewCell cellHeight] - 51 ){
        
        bTextHeightMoreCellHeight = YES; //文字高度超过cellHeight
        textMoreHeight = changeHeight + 32; //记录文字超过cell的高度
        rect.size.height = textMoreHeight;
        textView.frame = rect;
        
        UITableView *tableView = self.tableView;
        [tableView beginUpdates];
        [tableView endUpdates];
        
    }else{
        bTextHeightMoreCellHeight = NO;
    }
  
    
    //设置bottomView
     NSIndexPath *textViewPath = [NSIndexPath indexPathForRow:1  inSection:0];
    //改变bottomViewFrame
    ActivityTextViewCell *cell = (ActivityTextViewCell *)[self.tableView cellForRowAtIndexPath:textViewPath];
    cell.bottomView.frame = CGRectMake(cell.bottomView.frame.origin.x, CGRectGetMaxY(textView.frame), cell.bottomView.frame.size.width, cell.bottomView.frame.size.height);
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.textView = textView;
    
    NSArray *cellArr = self.tableView.visibleCells;
    ActivityTextFieldCell  *firstCell = (ActivityTextFieldCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if([cellArr containsObject:firstCell]){
        if(bTextHeightMoreCellHeight){
            [self moveToTextViewPosition:textView];
        }
    }else{
         [self moveToTextViewPosition:textView];
    }
   
    //隐藏cell 里面的toolBar
    UIView *contentView = textView.superview;
    UIView *bottomView = [contentView viewWithTag:1100];
    bottomView.hidden = YES;
    textViewEditing = YES;
    
    //调整toolBar 在键盘之上
    toolBar.hidden = NO;
    _toolFinishBar.hidden = YES;
    
    /* Move the toolbar to above the keyboard */
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:_keyboardAnimationDuration];
    [UIView setAnimationCurve:_keyboardAnimationCurve];
    [self autoMovekeyBoard:keyboardheight];
    [UIView commitAnimations];
 
    
    //比较文本
    NSAttributedString *textViewAttribute = textView.attributedText;
    NSString *textString=[textViewAttribute string];
    if([textString isEqualToString:NSLocalizedString(@"Activity detail time,place,event", @"活动详情，详细说明时间、地点、事件")])
    {
        textView.attributedText = [[NSAttributedString alloc]initWithString:@""];
        textView.textColor = WJBarBlackColor;
    }
}

-(void)moveToTextViewPosition:(UITextView *)textView
{
    NSUInteger location =  textView.selectedRange.location;
    NSRange range = NSMakeRange(0, location);
    NSAttributedString *attr = [textView.attributedText attributedSubstringFromRange:range];
    CGFloat moveY = [ToolUtil calculating_Text_Height_1_Width:IPHONE_WIDTH - 30 WithString:attr];
    if(moveY > 214){
        moveY = moveY - 214 + 32;
    }else{
        moveY = 0;
    }
    [self.tableView setContentOffset:CGPointMake(0,  moveY ) animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
   
    //显示cell 里面的toolBar
    UIView *contentView = textView.superview;
    UIView *bottomView = [contentView viewWithTag:1100];
    bottomView.hidden = NO;
    textViewEditing = NO; //标记已经编辑完
    toolBar.hidden = YES;
    
    //检查textView 是否填写
    NSAttributedString *textViewAttribute = textView.attributedText;
    NSString *textString=[textViewAttribute string];
    if(textString.length == 0){
        textView.text = NSLocalizedString(@"Activity detail time,place,event", @"活动详情，详细说明时间、地点、事件");
        textView.textColor = WJBarLightGrayColor;
    }
}

#pragma mark - MapPositionControllerDelegate
- (void)onSelectedMapPosition:(WeJuBarPoi *)positionPOI{
    
    _selectedMapPositionStr = positionPOI.bPositionFlag ? positionPOI.address : positionPOI.placeTitle;
    self.lat = positionPOI.latitude;
    self.lng = positionPOI.longitude;
    
    //局部刷新
    NSIndexPath *mapIndexPath  = [NSIndexPath  indexPathForRow:0 inSection:3];
    [self.tableView reloadRowsAtIndexPaths:@[mapIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -  CustomerItemControllerDelegate
- (void)addCustomerItem:(RegistItem *) customerItem editType:(NSInteger) editType{
    
    if(editType == 0){  //添加回来的
        NSInteger insertIndex = registItemsArr.count - 1;
        [registItemsArr insertObject:customerItem atIndex:insertIndex];
    }else{
        //编辑回来的
         [registItemsArr replaceObjectAtIndex:needRemoveRegistItemIndex withObject:customerItem];
    }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - ActivityTextViewCellDelegate
//插入图片
-(void)addPhotoToTextView
{
    [self insertPhotoToTextView];
}

//预览
-(void)lookActivityEditEffect{
    
    NSMutableArray *activityDataArr = [self getPlainString];
    
    //把内容为图片类型的value 填写图片的index ,以供预览显示
    NSInteger findPictureCount = 0;
    for (int i = 0; i < activityDataArr.count; i++) {
        
        NSMutableDictionary *dic = [activityDataArr objectAtIndex:i];
        NSString *type = [dic objectForKey:@"type"];
        NSString *value = [dic objectForKey:@"value"];
        if([type isEqualToString:@"2"]){ //找到图片
            
            if(value.length == 0){ //判断是第几张图片
                
                NSString *imageIndexStr = [NSString stringWithFormat:@"%ld",(long)findPictureCount];
                //设置URL
                [dic setObject:imageIndexStr forKey:@"value"];
                [activityDataArr replaceObjectAtIndex:i withObject:dic];
                findPictureCount ++ ;
            }
        }
    }

    PreviewActivityController *viewController = [[PreviewActivityController alloc] init];
    viewController.activityDataArr = activityDataArr;
    viewController.imageDataArr = attachImages;
    [self pushViewController:viewController animated:YES];
    
}

#pragma mark ActivityTextCellDelegate

-(void)activityTextShouldBeginEdit:(UITextField *)textField
{
    if(textField.tag == 1025){
        textField.placeholder = NSLocalizedString(@"input activity limit people", @"输入活动限制报名人数");
    }
}

-(void)activityTextBeginEdit:(UITextField *)textField{
    
     if(textField.tag == 1024){
         _activityTitleField = textField;
     }else if(textField.tag == 1025){
         _limitSignPeopleField = textField;
         if(self.limitSignPeopleCount.integerValue > 0){
             textField.text = self.limitSignPeopleCount;
         }
         
         //调整toolBar 在键盘之上
         toolBar.hidden = YES;
         _toolFinishBar.hidden = NO;
         
         /* Move the toolbar to above the keyboard */
         [UIView beginAnimations:nil context:NULL];
         [UIView setAnimationDuration:_keyboardAnimationDuration];
         [UIView setAnimationCurve:_keyboardAnimationCurve];
         [self autoMovekeyBoard:keyboardheight];
         [UIView commitAnimations];
         
         //调整屏幕键盘遮挡高度
         [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
     }
    
    //pan事件
    [self.tableView addGestureRecognizer:self.tapGestureRecognizer];
    [self.tableView addGestureRecognizer:self.panGestureRecognizer];
}

//结束编辑
-(void)activityTextDidEndEdit:(UITextField *)textField{
    if(textField.tag == 1025){
        if(textField.text && textField.text.length >0)
        {
            NSString *peopleStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if(peopleStr.length > 0){
                self.limitSignPeopleCount = peopleStr;
                if([peopleStr integerValue] > 0){
                    textField.text = [NSString stringWithFormat:NSLocalizedString(@"Admit Sign People Count" , "允许%@人报名"),peopleStr];
                }
                else{
                    textField.text = @"";
                    textField.placeholder = NSLocalizedString(@"Not limit apply people count", @"不限报名人数");
                }
            }
        }else{
             textField.placeholder = NSLocalizedString(@"Not limit apply people count", @"不限报名人数");
        }
    }
    
    [self hideKeyboard];
    [self.tableView removeGestureRecognizer:self.tapGestureRecognizer];
    [self.tableView removeGestureRecognizer:self.panGestureRecognizer];
}

//绑定内容
-(void)bindTextField:(UITextField *)textField{
    
    if(textField.tag == 1024){
        self.activityTitle = textField.text;
    }
}


#pragma mark  - SignTimeCellDelegate
-(void)changeValuePickerFlag:(NSInteger )tag DateTime:(double)time{
    
    switch (tag) {
        case 2000:{ //活动开始
            
            self.activityStartTime = time;
            break;
        }
        case 2001:{ //活动结束
            
            self.activityEndTime = time;
            break;
        }
        case 1001:{ //报名截止
            
           self.activityCutOffTime = time;
            break;
        }
        default:
            break;
    }
    
    if( self.activityEndTime < self.activityStartTime){
        
        //结束时间设置为起始时间的当天18点
        NSDate *startDate = [self timeIntervalToDate:self.activityStartTime];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitHour| NSCalendarUnitMinute | NSCalendarUnitSecond;
        //start时间
        NSDateComponents *startComps = [calendar components:unitFlags fromDate:startDate];
        
        //需要的时间 如果小于当天18:00
        NSDateComponents *resultComps = [[NSDateComponents alloc] init];
        [resultComps setYear:[startComps year]];
        [resultComps setMonth:[startComps month]];
        [resultComps setDay:[startComps day]];
        [resultComps setHour:18];
        time = [[calendar dateFromComponents:resultComps] timeIntervalSince1970]*1000;
        self.activityEndTime = time;
    }
}

//毫秒转成date
-(NSDate *)timeIntervalToDate:(double) timeInterval{
    NSString *chooseTimeStr = [ToolUtil FormatTime:@"yyyy-MM-dd hh:mmaaa" timeInterval:timeInterval];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd hh:mmaaa"];
    NSDate *startDate =  [dateformatter dateFromString:chooseTimeStr];
    return startDate;
}

#pragma mark -  ActivityDetailControllerDelegate
- (void)returnBackToUpdateActivity
{
    UIColor *greenColor = WJBarGreenColor;
    self.bUpdateActivityFlag = YES; //标识为修改活动
    uploadImageIndex = 0; //重新上传图片
     self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Save", @"保存") target:self action:@selector(clickRightActionButton) textColor:greenColor  positionLeft:NO];
}

-(void)backToActivity{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Methods
//初始化自定义填写项
-(NSArray *)writeDefaultItems{
    //test
    RegistItem *i1 = [[RegistItem alloc]init];
    i1.selectStatu = 1;
    i1.mustSelect = 1;
    i1.removeStatu = 0;
    i1.text = NSLocalizedString(@"Name", @"姓名");
    
    RegistItem *i2 = [[RegistItem alloc]init];
    i2.selectStatu = 1;
    i2.removeStatu = 0;
    i2.mustSelect = 1;
    i2.text =  NSLocalizedString(@"Sex", @"性别");
    
    RegistItem *i3 = [[RegistItem alloc]init];
    i3.selectStatu = 1;
    i3.removeStatu = 0;
    i3.mustSelect = 1;
    i3.text =  NSLocalizedString(@"Mobile", @"手机");
    
    RegistItem *i4 = [[RegistItem alloc]init];
    i4.selectStatu = 0;
    i4.removeStatu = 0;
    i4.mustSelect = 0;
    i4.text =  NSLocalizedString(@"Weather Partner", @"是否带人");
    
    RegistItem *i5 = [[RegistItem alloc]init];
    i5.selectStatu = 0;
    i5.removeStatu = 0;
    i5.mustSelect = 0;
    i5.text =  NSLocalizedString(@"Remark", @"备注");
    
    
    RegistItem *i7 = [[RegistItem alloc]init];
    i7.selectStatu = 0;
    i7.removeStatu = 0;
    i7.mustSelect = 0;
    i7.text = @"+";
    
    NSArray *testArr = @[i1,i2,i3,i4,i5,i7];
    return testArr;
}

//绑定活动数据
-(void)assignmentActivity
{
    self.activityTitle = _activityDetail.title;
    self.limitSignPeopleCount = [NSString stringWithFormat:@"%ld",(long)_activityDetail.maxApplyCount];
    self.selectedMapPositionStr = _activityDetail.address;
    self.activityCutOffTime = _activityDetail.deadline;
    self.activityStartTime = _activityDetail.begin;
    self.activityEndTime = _activityDetail.end;
    self.lat = _activityDetail.lat / 1000000;
    self.lng = _activityDetail.lat / 1000000;
    
    [self assignmentCustomerItems];
    [self assignmentActivityContent];
}

//绑定活动内容
-(void)assignmentActivityContent
{
    
    NSIndexPath *textViewPath = [NSIndexPath indexPathForRow:1  inSection:0];
    ActivityTextViewCell *cell = (ActivityTextViewCell *)[self.tableView cellForRowAtIndexPath:textViewPath]; //得到本次点击的cell
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:[[NSAttributedString alloc]initWithString:@""]];
    
    for(NSDictionary *dic in _activityDetail.content)
    {
        NSString *content = [dic objectForKey:@"value"];
        NSInteger type = [[dic objectForKey:@"type"] integerValue];
        
        if(type == 1){
            
            if(content.length == 0){
                content = @"\n";
            }
            
            //内容
            NSMutableAttributedString *contentText = [[NSMutableAttributedString alloc]initWithString:content]; //替换下标的偏移量
            [attributedString insertAttributedString:contentText  atIndex:attributedString.length];
        }else{
            //图片
            CGFloat height = [[dic objectForKey:@"height"] floatValue];
            CGFloat width = [[dic objectForKey:@"width"] floatValue];
            
            [attributedString insertAttributedString:[self createPictureAttributeStr:content Width:width Height:height] atIndex:attributedString.length];
        }
    }
    
    cell.textView.attributedText = attributedString;
    cell.textView.font = [UIFont systemFontOfSize:15];
    //选择完图片后，重新计算高度
    [self countTextViewCellHeight: cell.textView];
}

//绑定自定义项
-(void)assignmentCustomerItems
{
    
    [registItemsArr removeAllObjects];
    
    //test
    RegistItem *i1 = [[RegistItem alloc]init];
    i1.selectStatu = 1;
    i1.mustSelect = 1;
    i1.removeStatu = 0;
    i1.text = NSLocalizedString(@"Name", @"姓名");
    
    RegistItem *i2 = [[RegistItem alloc]init];
    i2.selectStatu = 1;
    i2.removeStatu = 0;
    i2.mustSelect = 1;
    i2.text =  NSLocalizedString(@"Sex", @"性别");
    
    RegistItem *i3 = [[RegistItem alloc]init];
    i3.selectStatu = 1;
    i3.removeStatu = 0;
    i3.mustSelect = 1;
    i3.text =  NSLocalizedString(@"Mobile", @"手机");
    
    [registItemsArr addObjectsFromArray:@[i1,i2,i3]];
    
    RegistItem *i4 = [[RegistItem alloc]init];
    i4.removeStatu = 0;
    i4.selectStatu = 0;
    i4.mustSelect = 0;
    i4.text =  NSLocalizedString(@"Weather Partner", @"是否带人");
    
    RegistItem *i5 = [[RegistItem alloc]init];
    i5.selectStatu = 0;
    i5.removeStatu = 0;
    i5.mustSelect = 0;
    i5.text =  NSLocalizedString(@"Remark", @"备注");
    
    
    ApplyField *applyField = nil;
    NSArray *applyFieldsArr = _activityDetail.applyFields;
    NSMutableArray *customerItems = [[NSMutableArray alloc]init];
    for (int i = 0; i < applyFieldsArr.count; i++) {
        applyField = [applyFieldsArr objectAtIndex:i];
        
        
        if(applyField.isReserved == 1){ //系统的
            if([applyField.fieldName isEqualToString:NSLocalizedString(@"Partner", @"带人")]){
                 i4.selectStatu = 1;
            }else if([applyField.fieldName isEqualToString:NSLocalizedString(@"Remark", @"备注")]){
                 i5.selectStatu = 1;
            }
        }else if(applyField.isReserved == 0){ //自定义的
            
            RegistItem *customerItem = [[RegistItem alloc]init];
            customerItem.selectStatu = 1; //选中
            customerItem.removeStatu = 1; //可移除
            customerItem.mustSelect = 0;  //不是必须选的
            customerItem.text = applyField.fieldName;
            if(applyField.option && applyField.option.length > 0){
                customerItem.childNodeItems = [[NSMutableArray alloc]init]; //初始化数组
                [customerItem.childNodeItems addObjectsFromArray:[applyField.option componentsSeparatedByString:@","]];
            }
            [customerItems addObject:customerItem];
        }
    }
    
    [registItemsArr addObject:i4];
    [registItemsArr addObject:i5];
    [registItemsArr addObjectsFromArray:customerItems];
    
    RegistItem *lastItem = [[RegistItem alloc]init];
    lastItem.selectStatu = 0;
    lastItem.removeStatu = 0;
    lastItem.mustSelect = 0;
    lastItem.text = @"+";
    [registItemsArr addObject:lastItem];
}

//拍照
- (void)showCamera
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
    }
    else
    {
        [self showMessage:NSLocalizedString(@"Camara can not be used", @"摄像头不可用")];
    }
}

//选择照片
- (void)showPhoto
{
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.limitsMaximumNumberOfSelection = YES;
    imagePickerController.maximumNumberOfSelection = 9;
    imagePickerController.bUseFullScreenImage = YES;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:nil];
}


//键盘通知
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    keyboardheight = keyboardRect.size.height;
    
    _keyboardAnimationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    _keyboardAnimationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    
    /* Move the toolbar to above the keyboard */
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:_keyboardAnimationDuration];
      [UIView setAnimationCurve:_keyboardAnimationCurve];
    [self autoMovekeyBoard:keyboardheight];
    [UIView commitAnimations];
}

- (void)addKeyboardNotification
{
    //键盘相关通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // 键盘高度变化通知，ios5.0新增的   主要用于中文输入的时候 覆盖的问题
#ifdef __IPHONE_5_0
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
#endif
 
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


-(void)createToolBarForTextView{
    
    NSMutableArray *items = [NSMutableArray array];
    UIBarButtonItem *cameraButtonItem = [UIBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"camera.png"] target:self action:@selector(insertPhotoToTextView) newDot:NO ];

    [items addObject:cameraButtonItem];
    
    UIBarButtonItem *flexibleSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexibleSpaceBarButtonItem];

    
    UIColor *textColor =WJBarGreenColor;
    UIBarButtonItem *saveItem = [UIBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Finish", @"完成") target:self action:@selector(clickRightButtonItem) textColor:textColor  positionLeft:NO];
    [items addObject:saveItem];
    
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, IPHONE_HEIGHT - 44, self.view.frame.size.width, 44)];
    toolBar.items = items;
    [self setToolbarBg:toolBar];
    toolBar.hidden = YES;
    [self.view addSubview:toolBar];
}

-(void)createToolBarForTextField{
    
    NSMutableArray *items = [NSMutableArray array];

    UIBarButtonItem *cameraButtonItem = [UIBarButtonItem barButtonItemWithImage:nil target:self action:nil newDot:NO ];
    [items addObject:cameraButtonItem];
    
    UIBarButtonItem *flexibleSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexibleSpaceBarButtonItem];
    
    UIColor *textColor =WJBarGreenColor;
    UIBarButtonItem *saveItem = [UIBarButtonItem barButtonItemWithTitle:NSLocalizedString(@"Finish", @"完成") target:self action:@selector(clickRightButtonItem) textColor:textColor  positionLeft:NO];
    [items addObject:saveItem];
    
    _toolFinishBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, IPHONE_HEIGHT - 44, self.view.frame.size.width, 44)];
    _toolFinishBar.items = items;
    [self setToolbarBg:_toolFinishBar];
    _toolFinishBar.hidden = YES;
    [self.view addSubview:_toolFinishBar];
}


//插入照片
-(void)insertPhotoToTextView{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", @"取消")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Take A Picture", @"拍照"), NSLocalizedString(@"Select Photo from Library", @"从手机相册选择"), nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag = 1024;
    [actionSheet showInView:self.view];
}

-(void)clickRightButtonItem{
 
    [self hideKeyboard];
}

- (void)autoMovekeyBoard:(float)boardHeight
{
    CGRect frame = toolBar.frame;
    frame.origin.y = IPHONE_HEIGHT - frame.size.height - boardHeight;
    toolBar.frame = frame;
    _toolFinishBar.frame = frame;
}

//设置ToolBar背景
-(void)setToolbarBg:(UIToolbar *)toolbar {
    
    UIColor *grayColor = UIColorRGB(250, 250, 250);
    UIImage * toolbarImage = [UIImage imageFromColor:grayColor size:toolBar.frame.size];
    if ([toolbar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)])
    [toolbar setBackgroundImage:toolbarImage forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
}

- (void)hideKeyboard
{
    if(self.activityTitleField)
    {
        [self.activityTitleField resignFirstResponder];
    }
    
    if(self.limitSignPeopleField)
    {
        [self.limitSignPeopleField resignFirstResponder];
    }
    
    if(self.textView)
    {
        [self.textView resignFirstResponder];
    }
    self.activityTitleField = nil;
    self.limitSignPeopleField = nil;
    self.textView = nil;
 
    //调整ToolBar回到底部
    toolBar.hidden = YES;
    _toolFinishBar.hidden = YES;
    [self autoMovekeyBoard:0];
}

//发布
-(void)clickRightActionButton{
    
    [self hideKeyboard];
    [self goPublishOrUpdateActivity];
}

//去到自定义添加项界面
-(void)goCustomerItemController:(RegistItem *)sendRegistItem{
    
    CustomerItemController *viewController = [[CustomerItemController alloc]initWithReceiveRegistItem:sendRegistItem];
    viewController.delegate = self;
    viewController.existRegistItemArr = registItemsArr;
    [self pushViewController:viewController animated:YES];
}

//选地图位置
- (void)selectMapPosition
{
    MapPositionController *controller = [[MapPositionController alloc] init];
    controller.delegate = self;
    [self pushViewController:controller animated:YES];
}

//默认时间
- (void)setDefaultTime
{
    NSDate *currentDate = [NSDate date];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitHour| NSCalendarUnitMinute | NSCalendarUnitSecond;
    //当前时间
    NSDateComponents *currentComps = [calendar components:unitFlags fromDate:currentDate];
    
    //需要的时间 如果小于当天18:00 设置成当天19:00 如果大于18:00 设置成次日19:00
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    [resultComps setYear:[currentComps year]];
    [resultComps setMonth:[currentComps month]];
    
    //截止报名时间
    [resultComps setDay:[currentComps day] + 6];
    [resultComps setHour:0];
     NSTimeInterval time = [[calendar dateFromComponents:resultComps] timeIntervalSince1970]*1000;
    self.activityCutOffTime = time;
    
    //活动开始时间，
    [resultComps setDay:[currentComps day] + 7];
    [resultComps setHour:9];
    time = [[calendar dateFromComponents:resultComps] timeIntervalSince1970]*1000;
    self.activityStartTime = time;
    
    //结束时间。
    [resultComps setDay:[currentComps day] + 7];
    [resultComps setHour:18];
    time = [[calendar dateFromComponents:resultComps] timeIntervalSince1970]*1000;
    self.activityEndTime = time;
}


//去到活动详情
-(void)goActivityDetailController
{
    //数据保存成功的时候去到活动详情
    ActivityDetailController *viewController = [[ActivityDetailController alloc]init];
    viewController.bfromPublishActivityController = YES;
    viewController.delegate = self;
    viewController.activity_id = self.activityId;
    WJBarNavigationController *navigationController = [[WJBarNavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - request
-(void)requestActivityDetail{
    
    [self showProgressHUD];
    _activityDetailRequest = [[ActivityDetailRequest alloc]init];
    _activityDetailRequest.delegate = self;
    _activityDetailRequest.activity_id = self.activityId;
    [_activityDetailRequest start];
}

//点击右上角保存或发布
-(void)goPublishOrUpdateActivity
{
    
    if(_activityTitle){
        _activityTitle = [self trimCharacters:_activityTitle];
        if(_activityTitle.length == 0 ){
             [self showMessage:NSLocalizedString(@"Please Input activity title", @"请填写活动主题")];
             return;
        }
    }
    
    //内容，图片切割成数组
    contentArr = [self getPlainString];
    if(contentArr.count == 0  || contentArr == nil ){
        [self showMessage:NSLocalizedString(@"Please Input activity detail", @"请填写活动详情")];
        return ;
    }
    
    [self showProgressHUD];
    //填写项数组
    NSMutableArray *fieldsArr = [[NSMutableArray alloc]init];
    NSMutableDictionary *fieldDictionary  = nil;
    for (RegistItem *item in registItemsArr) {
        if(item.selectStatu == 1 && item.mustSelect == 0){ //排除必选项和未选项
            fieldDictionary  = [[NSMutableDictionary alloc]init];
            [fieldDictionary setValue:item.text  forKey:@"field_name"];
            if(item.childNodeItems.count > 0){
                NSString * options = [item.childNodeItems componentsJoinedByString:@"," ];
                [fieldDictionary setValue:options  forKey:@"option"];
            }
            [fieldsArr addObject:fieldDictionary];
        }
    }
    self.fields = [fieldsArr JSONString];
    
    
    //如果有图片，则进行上传流程
    if(attachImages.count > 0){
         [self uploadImages:uploadImageIndex];
    }else{
        
        //图文格式
        self.content = [contentArr JSONString];
        
        //更新
        if(self.bUpdateActivityFlag){
            [self sendUpdateActivity];
        }else{
            //发布
            [self sendActivityContent];
        }
    }
}

//上传图片
-(void)uploadImages:(NSInteger)imageIndex{
    
    UIImage *image = [attachImages objectAtIndex:imageIndex];
    NSString *imageFile = [[WJSandbox tmpPath] stringByAppendingPathComponent:@"UploadActivityImage.jpg"];
    if([image writeToFile:imageFile forRepresentation:0.6])
    {
        _uploadHttpRequest = [[UploadHttpRequest alloc] init];
        _uploadHttpRequest.uploadUrlType = UploadUrlTypeActivity;
        _uploadHttpRequest.delegate = self;
        _uploadHttpRequest.filePath = imageFile;
        [_uploadHttpRequest start];
    }else
    {
        [self hideProgressHUD];
        [self showMessage:NSLocalizedString(@"Upload fail, try again", @"上传失败，请重试!")];
    }
}


//上传完图片后发布活动
-(void)sendActivityContent{
    
    _publishActivityRequest = [[PublishActivityReqeust alloc]init];
    _publishActivityRequest.delegate = self;
    
    _publishActivityRequest.title = self.activityTitle;
    _publishActivityRequest.max_apply_count = [self.limitSignPeopleCount integerValue];
    _publishActivityRequest.address = self.selectedMapPositionStr;
    _publishActivityRequest.content = self.content; //json格式 图文字符串
    _publishActivityRequest.fields = self.fields; //json格式 自定义选项 字符串
    _publishActivityRequest.deadline = self.activityCutOffTime;
    _publishActivityRequest.begin = self.activityStartTime;
    _publishActivityRequest.end = self.activityEndTime;
    _publishActivityRequest.lat = self.lat;
    _publishActivityRequest.lng = self.lng;
    
    [_publishActivityRequest start];
}

//上传完图片后更新活动
-(void)sendUpdateActivity
{
    _activityUpdateReqeust = [[ActivityUpdateReqeust alloc]init];
    _activityUpdateReqeust.delegate = self;
    
    _activityUpdateReqeust.activity_id = self.activityId;
    _activityUpdateReqeust.title = self.activityTitle;
    _activityUpdateReqeust.max_apply_count = [self.limitSignPeopleCount integerValue];
    _activityUpdateReqeust.address = self.selectedMapPositionStr;
    _activityUpdateReqeust.content = self.content; //json格式 图文字符串
    _activityUpdateReqeust.fields = self.fields; //json格式 自定义选项 字符串
    _activityUpdateReqeust.deadline = self.activityCutOffTime;
    _activityUpdateReqeust.begin = self.activityStartTime;
    _activityUpdateReqeust.end = self.activityEndTime;
    _activityUpdateReqeust.lat = self.lat * 1000000;
    _activityUpdateReqeust.lng = self.lng * 1000000;
    
    [_activityUpdateReqeust start];
}


#pragma mark - WJBarHttpRequestDelegate
-(void)onGetHttpRequest:(WJBarHttpRequest *)httpRequest
{
    [self endRefreshData];
    
    WJBarHttpRequestInfo *requestInfo = httpRequest.requestInfo;
    switch (requestInfo.tag) {
            
        case WJBarHttpRequestTagActivityDetail:
        {
            [self hideProgressHUD];
            if (requestInfo.status == 1) {
                   _activityDetail = requestInfo.object;
                  [self assignmentActivity];
                  [self.tableView reloadData];
            }
            else {
                
                [self showErrorString:NSLocalizedString(@"Activity detail get fail", @"活动详情获取失败") errorCode:requestInfo.errorCode errorString:requestInfo.message];
            }
            break;
        }
            
        case WJBarHttpRequestTagActivityCreate:
        {
            [self hideProgressHUD];
            if (requestInfo.status == 1) {
                
                self.activityId = _publishActivityRequest.activityId;
                
                //跳转
                [self goActivityDetailController];
            }
            else {
                
                 [self showErrorString:NSLocalizedString(@"Publish Activity Fail", @"发布活动失败") errorCode:requestInfo.errorCode errorString:requestInfo.message];
                 uploadImageIndex = 0;
            }
            break;
        }
            
        case WJBarHttpRequestTagActivityUpdate:
        {
            [self hideProgressHUD];
            if (requestInfo.status == 1) {
                
                if(_bFromActivityManageFlag){ //回到管理活动页面
                    [self showMessage:NSLocalizedString(@"update Activity Success", @"修改成功")];
                    [self.navigationController popViewControllerAnimated:NO];
                    
                    if (_delegate && [_delegate conformsToProtocol:@protocol(ManageUpdateActivityDelegate)] && [_delegate respondsToSelector:@selector(onManageUpdateActivitySuccess)]) {
                        
                        [_delegate onManageUpdateActivitySuccess];
                    }
                }else{
                    //跳转
                    [self goActivityDetailController];
                }
            }
            else {
                
                [self showErrorString:NSLocalizedString(@"update Activity Fail", @"修改活动失败") errorCode:requestInfo.errorCode errorString:requestInfo.message];
            }
            break;
        }
          
        case WJBarHttpRequestTagUpload:
        {
            if (requestInfo.status == 1) {
                
                //上传成功
                UploadInfo *info = requestInfo.object;
                
                //替换url
                NSInteger findPictureCount = 0;
                for (int i = 0; i < contentArr.count; i++) {
                    NSMutableDictionary *dic = [contentArr objectAtIndex:i];
                    NSString *type = [dic objectForKey:@"type"];
                    if([type isEqualToString:@"2"]){ //找到图片
                        
                        findPictureCount ++ ;
                        if((uploadImageIndex+1) == findPictureCount){ //判断是第几张图片
                            
                            //设置URL
                            [dic setObject:info.url forKey:@"value"];
                            
                            //设置图片大小
                            UIImage *image = [attachImages objectAtIndex:uploadImageIndex];
                            NSString *height = [NSString stringWithFormat:@"%.0f",image.size.height];
                            NSString *width = [NSString stringWithFormat:@"%.0f",image.size.width];
                            [dic setObject:height forKey:@"height"];
                            [dic setObject:width forKey:@"width"];
                            
                            [contentArr replaceObjectAtIndex:i withObject:dic];
                            break;
                        }
                        
                    }
                }
                
                //准备下一张上传
                uploadImageIndex ++ ;
                if(uploadImageIndex < attachImages.count){
                    [self uploadImages:uploadImageIndex];
                }else{
                    //图文格式
                    self.content = [contentArr JSONString];
                    
                    //更新
                    if(self.bUpdateActivityFlag){
                        [self sendUpdateActivity];
                    }else{
                        //发布
                        [self sendActivityContent];
                    }
                }
            }
            else {
                [self showErrorString:NSLocalizedString(@"Upload Image Fail", @"上传图片失败") errorCode:requestInfo.errorCode errorString:requestInfo.message];
                uploadImageIndex = 0;
            }

            break;
        }
            
        default:
            break;
    }
}


-(NSString *)trimeSpace:(NSString *)string {
    return [string stringByReplacingOccurrencesOfString:@" " withString:@""];
}

-(NSString *)trimCharacters:(NSString *)string{
    return [string  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
