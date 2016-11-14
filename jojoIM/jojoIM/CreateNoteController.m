//
//  CreateNoteController.m
//  WeJuBar
//
//  Created by JoyDo on 15/3/23.
//  Copyright (c) 2015年 JoyDo. All rights reserved.
//

#import "CreateNoteController.h"
#import "ToolUtil.h"
#import "UIImage+NTESColor.h"
#import "UIImage+RRAPI.h"
#import "JSONKit.h"


@interface CreateNoteController ()
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UITableViewDelegate,
UIActionSheetDelegate,
UITableViewDataSource,
UITextViewDelegate,
NoteTextFieldCellDelegate,
NoteTextViewCellDelegate> {
    
    BOOL bTextHeightMoreCellHeight;         //textView内容 高度是否超过cell 原有高度
    CGFloat keyboardheight;                 //键盘高度
    CGFloat textMoreHeight;                 //textView内容高度
    NSMutableArray *attachImages;           //存放插入textView的图片数组
    NSInteger uploadImageIndex;             //上传的图片索引
    NSMutableArray *contentArr;             //存放分割的图文数组
    
    double  _keyboardAnimationDuration;
    NSInteger _keyboardAnimationCurve;
    CGFloat contentY;
}

@property(nonatomic,strong)   UIButton *itemBtn;

@end

@implementation CreateNoteController
@synthesize toolBar;

- (instancetype)init
{
    self = [super init];
    if (self) {
        attachImages = [[NSMutableArray alloc]init];
        uploadImageIndex = 0;
      
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Edit Note";
    self.view.backgroundColor = LJBackgroundColor;
    
    [self addKeyboardNotification]; //键盘监听
    
    //tableView
    [self.view addSubview:self.tableView];
    
    //ToolBar 工具条
    [self createToolBarForTextView];
    
    // 设置内容
    //[self assignmentNoteContent];
}

-(UITableView *)tableView
{
    if(!_tableView){

        CGSize size = self.view.frame.size;
        CGRect tableFrame = CGRectMake(0, 0.0, size.width, size.height);
        _tableView = [[UITableView alloc] initWithFrame:tableFrame  style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.backgroundColor = [UIColor colorWithHexString:@"#F6F6F6"];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorInset = UIEdgeInsetsMake(5, 5, 5, 5);
        _tableView.backgroundColor = LJBackgroundColor;
        
        if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            _tableView.separatorInset = UIEdgeInsetsZero;
        }
        if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            _tableView.layoutMargins = UIEdgeInsetsZero;
        }
        self.automaticallyAdjustsScrollViewInsets = YES; //自动调整scrollView的间距
        _tableView.tableFooterView = [[UIView alloc]init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        _tableView.showsVerticalScrollIndicator = YES;
    }
    return _tableView;
}


-(void)addRightBarButtonItem{
    self.itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.itemBtn.frame = CGRectMake(0, 0, 40, 35);
    self.itemBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.itemBtn setTitle:@"Save" forState:UIControlStateNormal];
    [self.itemBtn setTitleColor:[UIColor colorWithHexString:@"#171717"] forState:UIControlStateNormal];
    [self.itemBtn addTarget:self action:@selector(clickRightActionButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithCustomView:self.itemBtn];
    self.navigationItem.rightBarButtonItem = item;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 44.0f;
    if(indexPath.row == 1){
        height = [NoteTextViewCell cellHeight];
        
        if(bTextHeightMoreCellHeight){
            height = textMoreHeight + 51.0;
        }
    }else {
        height = 50.0f;
        
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
   
    if(row == 0){
        cell = [self getNoteTextCell:indexPath];
    }else if(row == 1){
        cell = [self getNoteTextViewCell];
    }
    
    return cell;
}


#pragma mark - UITableViewCells

- (NoteTextFieldCell *)getNoteTextCell:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row  = indexPath.row;
    static NSString *CellIdentifier = @"NoteTextCell";
    NoteTextFieldCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[NoteTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
       
    }
  
    //标记textField的tag
    if(section == 0 && row == 0){
        cell.ljTextField.tag = 1024;
        cell.ljTextField.text = self.noteTitle;
        cell.ljTextField.placeholder =@"Edit Note title";
        [cell.ljTextField setValue:[UIColor colorWithHexString:@"#74737C"] forKeyPath:@"_placeholderLabel.textColor"];
        cell.ljTextField.keyboardType = UIKeyboardTypeDefault;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (NoteTextViewCell *)getNoteTextViewCell
{
    static NSString *CellIdentifier = @"NoteTextViewCell";
    NoteTextViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[NoteTextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
    }
    cell.contentView.clipsToBounds = YES;
    cell.bTextHeightMoreCellHeight = bTextHeightMoreCellHeight;

    cell.textView.delegate = self;
    [cell setCellTextViewAttributeStr:_textViewAttribute];
    
    return cell;
}


#pragma mark - UITextViewDelegate

//计算textView的高度
-(void)countTextViewCellHeight :(UITextView *)textView {
    
    
    _textViewAttribute = [[NSMutableAttributedString alloc]initWithAttributedString:textView.attributedText];
    
    CGFloat changeHeight = [ToolUtil calculating_Text_Height_IOS7_Width:(SCREEN_W - 24) WithString:textView.attributedText];

    CGRect rect = textView.frame;
    //记录高度
    if(changeHeight >= [NoteTextViewCell cellHeight] - 51 ){
        
        bTextHeightMoreCellHeight = YES; //文字高度超过cellHeight
        textMoreHeight = changeHeight + 50; //记录文字超过cell的高度
        rect.size.height = textMoreHeight;
        
        textView.frame = rect;
        UITableView *tableView = self.tableView;
        [tableView beginUpdates];
        [tableView endUpdates];
        
    }else{
        bTextHeightMoreCellHeight = NO;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.textView = textView;
    
    //比较文本
    NSAttributedString *textViewAttribute = textView.attributedText;
    NSString *textString=[textViewAttribute string];
    if([textString isEqualToString:@"Edit Note Content"])
    {
        textView.attributedText = [[NSAttributedString alloc]initWithString:@""];
        textView.textColor = [UIColor colorWithHexString:@"#171717"];
    }
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    [UIView beginAnimations:@"ResizeTableViewHeight" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    self.tableView.frame = CGRectMake(0, self.tableView.frame.origin.y, self.tableView.frame.size.width,  SCREEN_H);
    [UIView commitAnimations];
    
    //显示cell 里面的toolBar
    UIView *contentView = textView.superview;
    UIView *bottomView = [contentView viewWithTag:1100];
    bottomView.hidden = NO;
    
    //检查textView 是否填写
    NSAttributedString *textViewAttribute = textView.attributedText;
    NSString *textString=[textViewAttribute string];
    if(textString.length == 0){
        textView.text =  @"Edit Note Content";
        textView.textColor = [UIColor colorWithHexString:@"#74737C"];
    }
}

#pragma mark NoteTextCellDelegate
-(void)ljTextFieldBeginEdit:(UITextField *)textField
{
     if(textField.tag == 1024){
         _noteTitleField = textField;
     }
}

//绑定内容
-(void)bindTextField:(UITextField *)textField{
    
    if(textField.tag == 1024){
        self.noteTitle = textField.text;
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

//绑定
-(void)assignmentNoteContent
{
    self.noteTitle = @"存储的笔记标题";
    NSIndexPath *textViewPath = [NSIndexPath indexPathForRow:1  inSection:0];
    NoteTextViewCell *cell = (NoteTextViewCell *)[self.tableView cellForRowAtIndexPath:textViewPath]; //得到本次点击的cell
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:[[NSAttributedString alloc]initWithString:@""]];
    
    
    NSString *contentStr = @"存储的笔记内容";
    NSMutableAttributedString *contentText = [[NSMutableAttributedString alloc]initWithString:contentStr]; //替换下标的偏移量
    [attributedString insertAttributedString:contentText  atIndex:attributedString.length];
    
    cell.textView.attributedText = attributedString;
    cell.textView.font = [UIFont systemFontOfSize:17];
    //选择完图片后，重新计算高度
    [self countTextViewCellHeight: cell.textView];
}

//键盘通知
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardFrame=[[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    
    keyboardheight = keyboardFrame.size.height;
    _keyboardAnimationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    _keyboardAnimationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    CGFloat textfieldMaxY = contentY;
    
    if(!bTextHeightMoreCellHeight){
        textfieldMaxY = 0;
    }
    
    
    //如果当前输入的框的位置低于键盘的高度就移动视图
    if ([self.textView isFirstResponder] &&  textfieldMaxY > (keyboardFrame.origin.y - 50)){
     
        CGFloat textViewHeight  = bTextHeightMoreCellHeight ? (self.textView.frame.size.height + 51 + 50): self.tableView.frame.size.height; //textView 以及textField的总高度
        CGFloat contentSizeHeight = textViewHeight + (keyboardFrame.size.height + 50)  + 64; //再加上键盘 和工具条的高度
        self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, contentSizeHeight);
        

        //被点击的文本框的底部的Y值 - 键盘的顶端的Y值 + 工具条的高度  =  要偏移的移动的距离
        CGFloat offSet = 50 + 64 + (textfieldMaxY - keyboardFrame.origin.y) + self.tableView.contentOffset.y;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:_keyboardAnimationDuration];
        [UIView setAnimationCurve:_keyboardAnimationCurve];
          [self.tableView setContentOffset:CGPointMake(0, offSet + 50) animated:YES];
        [UIView commitAnimations];
        
      
    }
    
    
    /* Move the toolbar to above the keyboard */
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:_keyboardAnimationDuration];
        [UIView setAnimationCurve:_keyboardAnimationCurve];
        [self autoMovekeyBoard:keyboardheight];
        [UIView commitAnimations];
}

-(void)backTextViewTouchPoint:(UIGestureRecognizer *)ges
{
    CGPoint touchPoint = [ges locationInView:self.view];
    
    contentY = touchPoint.y;
}

- (void)addKeyboardNotification
{
    //键盘相关通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    // 键盘高度变化通知，ios5.0新增的   主要用于中文输入的时候 覆盖的问题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)createToolBarForTextView{
    
    NSMutableArray *items = [NSMutableArray array];
 
    UIButton *pictureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pictureBtn.frame = CGRectMake(0, 0, 44, 44);
    [pictureBtn setImage:[UIImage imageNamed:@"picture_textView"] forState:UIControlStateNormal];
    [pictureBtn addTarget:self action:@selector(insertPhotoToTextView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *pictureItem = [[UIBarButtonItem alloc]initWithCustomView:pictureBtn];
    [items addObject:pictureItem];
    
    
    UIBarButtonItem *flexibleSpaceBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexibleSpaceBarButtonItem];
    

    //完成
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    finishBtn.frame = CGRectMake(0, 0, 60, 50);
    [finishBtn setTitle:@"Done" forState:UIControlStateNormal];
    finishBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [finishBtn setTitleColor:[UIColor colorWithHexString:@"#428253"] forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(clickFinishButtonItem) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *finishItem = [[UIBarButtonItem alloc]initWithCustomView:finishBtn];
    [items addObject:finishItem];
    
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, SCREEN_H - 50, self.view.frame.size.width, 50)];
    toolBar.items = items;
    toolBar.hidden = YES;
    [self setToolbarBg:toolBar];
    [self.view addSubview:toolBar];
}

-(void)clickFinishButtonItem{
 
    [self hideKeyboard];
}

- (void)autoMovekeyBoard:(float)boardHeight
{
    CGRect frame = toolBar.frame;
    frame.origin.y = self.view.frame.size.height - frame.size.height - boardHeight;
    toolBar.frame = frame;
    if(boardHeight > 0){
         toolBar.hidden = NO;
    }else {
        toolBar.hidden = YES;
    }
    
}

//设置ToolBar背景
-(void)setToolbarBg:(UIToolbar *)toolbar {
    
    UIImage * toolbarImage = [UIImage imageFromColor:[UIColor colorWithHexString:@"#FDFEFE"] size:toolBar.frame.size];
    if ([toolbar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)])
    [toolbar setBackgroundImage:toolbarImage forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
}


- (void)hideKeyboard
{
    if([self.noteTitleField isFirstResponder])
    {
        [self.noteTitleField resignFirstResponder];
    }
    
    if([self.textView isFirstResponder])
    {
        [self countTextViewCellHeight:self.textView];
        self.textView.font = [UIFont systemFontOfSize:17];
        [self.textView resignFirstResponder];
     
    }
   
    //调整ToolBar回到底部
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:_keyboardAnimationDuration];
    [UIView setAnimationCurve:_keyboardAnimationCurve];
    [self autoMovekeyBoard:0];
    [UIView commitAnimations];
}

//发布
-(void)clickRightActionButton{
    
    [self hideKeyboard];
    [self goPublishOrUpdateNote];
}


#pragma mark - request

//点击右上角保存或发布
-(void)goPublishOrUpdateNote
{
    NSIndexPath *textViewPath = [NSIndexPath indexPathForRow:1  inSection:0];
    NoteTextViewCell *cell = (NoteTextViewCell *)[self.tableView cellForRowAtIndexPath:textViewPath]; //得到本次点击的cell
    
    NSMutableAttributedString *plainString = [[NSMutableAttributedString alloc]initWithAttributedString:cell.textView.attributedText]; //替换下标的偏移量
    NSUInteger length = plainString.length;
    if (length == 0) {
  
        [SVProgressHUD showInfoWithStatus:@"You havn't input note content!"];
        return;
    }
        
    NSString *textString=[plainString string];
    if([textString isEqualToString:@"Edit Note Content"])
    {
        [SVProgressHUD showInfoWithStatus:@"You havn't input note content!"];
        return ;
    }
    
    //内容，图片切割成数组
    contentArr = [self getPlainString];
    if(contentArr.count == 0  || contentArr == nil ){
        [SVProgressHUD showInfoWithStatus:@"You havn't input note content!"];
        return ;
    }
    
    //如果有图片，则进行上传流程
    if(attachImages.count > 0){
        //上传图片 ,依次将返回的数据 替换到 type=2 的value中，一遍 最后一张上传完 将文本内容 contentArr 的json 传给服务器保存。
       //上传至最后一张时候，把json 保存到数据库。
       self.content = [contentArr JSONString];
    }else{
        //直接保存文本格式的笔记
        self.content = [contentArr JSONString];
    }
    
    NSLog(@"you input noteTextView's content is %@",self.content);
    
    [SVProgressHUD showSuccessWithStatus:@"data input correct, you can see the log of self.content，you can save it to your server!"];
}

//分割成数组
- (NSMutableArray *)getPlainString {
    
    //要返回的保存的数据
    NSMutableArray *dataArr = [[NSMutableArray alloc]init];
    
    //目的文本
    NSIndexPath *textViewPath = [NSIndexPath indexPathForRow:1  inSection:0];
    NoteTextViewCell *cell = (NoteTextViewCell *)[self.tableView cellForRowAtIndexPath:textViewPath];
    //AttributedString
    NSMutableAttributedString *plainString = [[NSMutableAttributedString alloc]initWithAttributedString:cell.textView.attributedText]; //替换下标的偏移量
    NSUInteger length = plainString.length;
    if (length == 0) {
        
        //没有输入任何内容，返回空
        return nil;
    }else{
        NSString *textString=[plainString string];
        if([textString isEqualToString:@"You havn't input note content!"])
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
                [attachImages addObject:[UIImage imageNamed:@"emptyPcture"]];
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


-(void)insertPhotoToTextView{
    
    [self hideKeyboard];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照",@"从相册选择", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
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
}


- (void)showPhoto
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
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
        [SVProgressHUD showInfoWithStatus:@"摄像头不可用"];
    }
}

#pragma mark - UIImageViewPickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    UIImage *image = [originalImage imageByCompressionQuality:0.7];
    [self sendImages:[NSArray arrayWithObject:image]]; //拍照
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
      [self dismissViewControllerAnimated:YES completion:nil];
}


//设置图片
- (void)sendImages:(NSArray *)images
{
    NSIndexPath *textViewPath = [NSIndexPath indexPathForRow:1  inSection:0];
    NoteTextViewCell *cell = (NoteTextViewCell *)[self.tableView cellForRowAtIndexPath:textViewPath];
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
    UIColor *realColor = [UIColor colorWithHexString:@"#171717"];
    [attributedString addAttributes:@{NSForegroundColorAttributeName : realColor,   NSFontAttributeName : [UIFont systemFontOfSize:17]} range:NSMakeRange(0, attributedString.length)];
    
    
    if(bHasImage == NO){
        NSString *textStr =  [_textViewAttribute string];
        if([textStr isEqualToString:@"Edit Note Content"])
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


//创建一个图片属性
-(NSAttributedString *)createPictureAttributedStr:(UIImage *)image{
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    CGFloat scaleFactor =  9;
    textAttachment.image = [UIImage imageWithCGImage:image.CGImage scale:scaleFactor orientation:UIImageOrientationUp];
    return [NSAttributedString attributedStringWithAttachment:textAttachment];
}

-(NSString *)trimeSpace:(NSString *)string {
    return [string stringByReplacingOccurrencesOfString:@" " withString:@""];
}

-(NSString *)trimCharacters:(NSString *)string{
    return [string  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
