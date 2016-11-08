//
//  CreateActivityController.h
//  WeJuBar
//
//  Created by JoyDo on 15/3/23.
//  Copyright (c) 2015年 JoyDo. All rights reserved.
//

#import "WJBarTableViewController.h"
#import "MapPositionCell.h"
#import "ActivityTextFieldCell.h"
#import "ActivityTextViewCell.h"
#import "MapPositionController.h"
#import "CustomerItemController.h"
#import "QBImagePickerController.h"
#import "RegistrationItemsCell.h"
#import "SignTimeCell.h"
#import "PublishActivityReqeust.h"
#import "UploadHttpRequest.h"
#import "ActivityDetailController.h"
#import "ActivityUpdateReqeust.h"


@protocol ManageUpdateActivityDelegate <NSObject>

@optional
- (void)onManageUpdateActivitySuccess;

@end

@interface CreateActivityController : WJBarTableViewController<ActivityTextCellDelegate,RegistrationItemsCellDelegate,SignTimeCellDelegate,MapPositionControllerDelegate,CustomerItemControllerDelegate,QBImagePickerControllerDelegate,ActivityTextViewCellDelegate,ActivityDetailControllerDelegate,WJBarHttpRequestDelegate,UIActionSheetDelegate,UITextViewDelegate,UIImagePickerControllerDelegate>
{
    PublishActivityReqeust *_publishActivityRequest;
    ActivityUpdateReqeust *_activityUpdateReqeust;
    UploadHttpRequest *_uploadHttpRequest;
    ActivityDetailRequest *_activityDetailRequest;
}

@property (nonatomic, assign) long  activityId;

//组织活动
@property (nonatomic ,strong) NSString *activityTitle; //活动标题
@property (nonatomic ,strong) NSString *limitSignPeopleCount;//限制人数
@property (nonatomic, assign) double activityCutOffTime;//截止时间
@property (nonatomic, assign) double activityStartTime;//开始时间
@property (nonatomic, assign) double activityEndTime;//开始时间
@property (nonatomic, assign) double lat;//纬度
@property (nonatomic, assign) double lng;//经度
@property (nonatomic ,strong) NSString *content;//内容
@property (nonatomic ,strong) NSString *fields;//填写项
@property (nonatomic ,strong) NSString *selectedMapPositionStr; //选中的地图地址
@property (nonatomic ,strong) NSMutableAttributedString *textViewAttribute;//活动内容,图片


//管理活动的修改
@property (nonatomic ,assign) BOOL bUpdateActivityFlag; //表示更新
@property (nonatomic ,assign) BOOL bFromActivityManageFlag;//来自管理
@property (nonatomic ,strong) ActivityDetail  *activityDetail;
@property (nonatomic, weak) id <ManageUpdateActivityDelegate> delegate;

//UI
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic ,strong) UITextField *activityTitleField;
@property (nonatomic ,strong) UITextField *limitSignPeopleField;
@property (nonatomic ,strong)  UIToolbar *toolBar;
@property (nonatomic ,strong)  UIToolbar *toolFinishBar;
@property (nonatomic ,strong)  UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic ,strong)  UIPanGestureRecognizer *panGestureRecognizer;

@end
