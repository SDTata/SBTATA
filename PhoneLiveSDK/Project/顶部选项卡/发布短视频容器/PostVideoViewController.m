//
//  PostVideoViewController.m
//  phonelive2
//
//  Created by Co co on 2024/7/17.
//  Copyright © 2024 toby. All rights reserved.
//

#import "PostVideoViewController.h"
#import "CachePostVideo.h"
#import "AddTagsViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <Qiniu/QiniuSDK.h>
#import "TZImagePickerController.h"
#import "WMZDialog.h"
#import "MyCreateMainVC.h"
#import "FileUploadManager.h"
#import "IQTextView.h"
#import "ProgressButton.h"

#define UploadVideoProgress @"UploadVideoProgress"
#define UploadVideoFinished @"UploadVideoFinished"
#define UploadVideoCancel @"UploadVideoCancel"

@implementation RuleSection
@end


@interface PostVideoViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,AddTagsAction,TZImagePickerControllerDelegate,UITableViewDataSource, UITableViewDelegate,UITextViewDelegate>
{
    NSArray *selectedAllIds;
    BOOL can_upload;
    BOOL fee_enabled;
    BOOL is_vip;
    WMZDialog *myAlert;
    UITextField *editPriceTextField;
    BOOL is_confirm;
    
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet IQTextView *titleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *videoimgView;
@property (weak, nonatomic) IBOutlet UIView *addVideoMaskView;
@property (weak, nonatomic) IBOutlet UILabel *addVideoLabel;
@property (weak, nonatomic) IBOutlet UILabel *addTagLabel;
@property (weak, nonatomic) IBOutlet UIButton *addVideoButton;
@property (weak, nonatomic) IBOutlet ProgressButton *postVideoButton;
@property (weak, nonatomic) IBOutlet UIView *payTypeView;

@property (weak, nonatomic) IBOutlet UIButton *payTypeNomal;
@property (weak, nonatomic) IBOutlet UIButton *payTypeVIP;

@property (weak, nonatomic) IBOutlet UILabel *displayPriceLabel;



@property(nonatomic, strong) UIView *moreView;

@property(nonatomic,strong)UIView *tagsBgView;

@property(nonatomic,strong)NSArray *dataArrays;

// 短视频发布规则 UI
@property (nonatomic, strong) UIView *postRulesView;
@property (nonatomic, strong) UIView *postRulesShadowView;
@property (nonatomic, assign) CGFloat postRulesViewHeight;
@property (nonatomic, strong) NSArray<RuleSection *> *ruleSections;
@property (nonatomic, strong) UITableView *postRulesTableView;

@property (nonatomic, strong) UIView *navtion;
@end

@implementation PostVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    selectedAllIds = [[CachePostVideo sharedManager]getAllCurrentTags];
    
    [self navigation];
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        self.automaticallyAdjustsScrollViewInsets = NO;
#pragma clang diagnostic pop
    }
    
    self.titleTextField.placeholder = YZMsg(@"PostVideo_sub_title2");
    self.titleTextField.placeholderTextColor = UIColor.lightGrayColor;
    self.addVideoLabel.text = YZMsg(@"PostVideo_sub_title3");
    self.addTagLabel.text = YZMsg(@"PostVideo_sub_title5");
    [self.postVideoButton setTitle:YZMsg(@"PostVideo_sub_title6") forState:UIControlStateNormal];
    self.titleTextField.delegate = self;
    
    UIView *leftV = [UIView new];
    leftV.size = CGSizeMake(10, 40);
    leftV.backgroundColor = [UIColor clearColor];
    
    UIView *rigtV = [UIView new];
    rigtV.size = CGSizeMake(10, 40);
    rigtV.backgroundColor = [UIColor clearColor];
    
    self.videoimgView.contentMode = UIViewContentModeScaleAspectFill;
    self.tagsBgView = [UIView new];
    self.tagsBgView.backgroundColor = [UIColor clearColor];
    [self.addTagLabel.superview addSubview: self.tagsBgView];
    [self.addTagLabel.superview addSubview:self.moreView];
    
    [self.moreView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@22);
        make.centerY.mas_equalTo(self.addTagLabel.mas_centerY);
        make.right.mas_equalTo(self.view).offset(-10);
    }];
    
    [self.tagsBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(self.addTagLabel.mas_bottom);
        make.bottom.mas_equalTo(self.addTagLabel.superview.mas_bottom);
    }];
    
    [self getTagsInfo];
    
    [self setupPostRulesView];

    [self.videoimgView vk_addTapAction:self selector:@selector(addVideo:)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressUploadVideo:) name:UploadVideoProgress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressFinishUploadVideo:) name:UploadVideoFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelUploadVideo) name:UploadVideoCancel object:nil];
    
    [self loadCacheData];
    
    
    self.payTypeNomal.selected = YES;
    
    [self.payTypeNomal addTarget:self action:@selector(payTypeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.payTypeVIP addTarget:self action:@selector(payTypeAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.addVideoMaskView.bounds
                                                   byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                                         cornerRadii:CGSizeMake(20.0, 20.0)];

    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.addVideoMaskView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.addVideoMaskView.layer.mask = maskLayer;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)navigation{
    UIView *navtion = [[UIView alloc]initWithFrame:CGRectMake(0,ShowDiff>0?20:0, _window_width, (ShowDiff>0?ShowDiff:20) + 44)];
    navtion.backgroundColor = [UIColor clearColor];
    self.navtion = navtion;
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    returnBtn.frame = CGRectMake(8, ShowDiff>0?ShowDiff:20,40,44);
    [returnBtn setImage:[ImageBundle imagewithBundleName:@"person_back_black"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(doReturn) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:returnBtn];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-180)/2.0, ShowDiff>0?ShowDiff:20, 180, 44)];
    titleLabel.userInteractionEnabled = YES;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.userInteractionEnabled = YES;
    titleLabel.text = YZMsg(@"PostVideo_title");
    [navtion addSubview:titleLabel];
    [titleLabel sizeToFit];
    titleLabel.top = ShowDiff>0?ShowDiff:20;
    titleLabel.height = 44;
    [titleLabel vk_addTapAction:self selector:@selector(showIntroducePostVide)];
    
    UIImageView *imgV = [UIImageView new];
    imgV.image = [ImageBundle imagewithBundleName:@"post_video_how"];
    imgV.backgroundColor = [UIColor clearColor];
    imgV.contentMode = UIViewContentModeScaleToFill;
    imgV.userInteractionEnabled = YES;
    imgV.frame = CGRectMake(titleLabel.right, titleLabel.top+10, 24, 24);
    [navtion addSubview:imgV];
    [imgV vk_addTapAction:self selector:@selector(showIntroducePostVide)];
    
    titleLabel.left = (SCREEN_WIDTH-(titleLabel.width+imgV.width))/2.0;
    imgV.left = titleLabel.right;
    
    UIButton *deletePostVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deletePostVideoBtn.frame = CGRectMake(SCREEN_WIDTH - 50, ShowDiff>0?ShowDiff:20,40,44);
    [deletePostVideoBtn setTitle:YZMsg(@"BetCell_remove") forState:UIControlStateNormal];
    [deletePostVideoBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [deletePostVideoBtn addTarget:self action:@selector(doDeleleVideo) forControlEvents:UIControlEventTouchUpInside];
    [navtion addSubview:deletePostVideoBtn];
    
    
    [self.view addSubview:navtion];
}


-(void)showIntroducePostVide{

    [self showPostRulesView];

}

-(void)doReturn{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)doDeleleVideo
{
    [[CachePostVideo sharedManager].selectedOtherTags removeAllObjects];
    [[CachePostVideo sharedManager].selectedCurrentTags removeAllObjects];
    [CachePostVideo sharedManager].cover_aid  = @"";
    [CachePostVideo sharedManager].cover_url = @"";
    

//    self.addCoverLabel.text = YZMsg(@"PostVideo_sub_title4");
//    self.addCoverLabel.textColor = [UIColor grayColor];
//    [self addShadawn:[UIColor whiteColor] label:self.addCoverLabel];
    
//    [self.addCoverButton setImage:[ImageBundle imagewithBundleName:@"post_video_img"] forState:UIControlStateNormal];
//    self.addCoverButton.hidden = NO;
//    self.coverImgView.image = nil;
   
    [self cancelUploadVideo];
  
    
    
    [CachePostVideo sharedManager].video_title = @"";
    [CachePostVideo sharedManager].coin_cost = nil;
    [CachePostVideo sharedManager].otherPrice = nil;
    [CachePostVideo sharedManager].coin_last = nil;
    [CachePostVideo sharedManager].ticket_cost = @"1";
    [CachePostVideo sharedManager].coverisUploading = false;
  
    
    
    self.titleTextField.text = @"";
    is_vip = false;
    self.payTypeVIP.selected = false;
    self.payTypeNomal.selected = true;
    
    [self showTagsDefault:self.dataArrays];
    
    [self displayShowPrice];
    
    
    
}

-(void)cancelUploadVideo {
    [self.postVideoButton setTitle:YZMsg(@"PostVideo_sub_title6") forState:UIControlStateNormal];
    [self.postVideoButton setEnabled:NO];
    [self.postVideoButton setBackgroundColor:[UIColor grayColor]];
    self.postVideoButton.progress = 0.0;
    
    self.addVideoLabel.text = YZMsg(@"PostVideo_sub_title3");
    self.addVideoLabel.textColor = [UIColor grayColor];
    //[self addShadawn:[UIColor whiteColor] label:self.addVideoLabel];
    
    [self.addVideoButton setImage:[ImageBundle imagewithBundleName:@"post_video_img"] forState:UIControlStateNormal];
    [CachePostVideo sharedManager].videoToken = @"";
    [CachePostVideo sharedManager].video_aid = @"";
    [CachePostVideo sharedManager].asset = nil;
    [CachePostVideo sharedManager].videoImage = nil;
    self.addVideoButton.hidden = NO;
    self.videoimgView.image = nil;
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.videoimgView];
    [hud hideAnimated:YES];
    [CachePostVideo sharedManager].videoisUploading = false;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

-(void)payTypeAction:(UIButton*)payTypeButton
{
    payTypeButton.selected = YES;
    if ([payTypeButton isEqual:self.payTypeVIP]) {
        is_vip = YES;
        self.payTypeNomal.selected = NO;
    }else if ([payTypeButton isEqual:self.payTypeNomal]) {
        is_vip = NO;
        self.payTypeVIP.selected = NO;
    }
    [CachePostVideo sharedManager].is_vip = is_vip;
}



-(void)loadCacheData
{
    self.titleTextField.text = [CachePostVideo sharedManager].video_title;
    //初始化数据遮盖图
    if (![PublicObj checkNull:[CachePostVideo sharedManager].cover_url]) {
        //[self.coverImgView sd_setImageWithURL:[NSURL URLWithString:[CachePostVideo sharedManager].cover_url]];
//        self.addCoverLabel.text = YZMsg(@"PostVideo_sub_title4_1");
//        self.addCoverLabel.textColor = [UIColor whiteColor];
    }
    
    //初始化数据视频
    if ([CachePostVideo sharedManager].videoImage != nil) {
        self.videoimgView.image = [CachePostVideo sharedManager].videoImage;
        
        [self.addVideoButton setImage:[ImageBundle imagewithBundleName:@"post_video_img"] forState:UIControlStateNormal];
        self.addVideoButton.hidden = YES;
        
        self.addVideoLabel.text = YZMsg(@"PostVideo_sub_title3_1");
        self.addVideoLabel.textColor = [UIColor whiteColor];
        //[self addShadawn:[UIColor blackColor] label:self.addVideoLabel];
        
        //上传失败的缓存
        if ([CachePostVideo sharedManager].asset != nil  && [CachePostVideo sharedManager].videoToken == nil) {
            [self.addVideoButton setImage:[ImageBundle imagewithBundleName:@"post_video_error"] forState:UIControlStateNormal];
            self.addVideoButton.hidden = NO;
            self.addVideoLabel.text = YZMsg(@"PostVideo_sub_title3_1");
            self.addVideoLabel.textColor = [UIColor whiteColor];
            //[self addShadawn:[UIColor blackColor] label:self.addVideoLabel];
        }
    }
    
    //是否允许直接发布状态
    if ([CachePostVideo sharedManager].asset == nil && ![PublicObj checkNull:[CachePostVideo sharedManager].video_aid] && ![PublicObj checkNull:[CachePostVideo sharedManager].cover_aid] ) {
        [self.postVideoButton setEnabled:YES];
        [self.postVideoButton setBackgroundColor:RGB(50, 4, 56)];
    }else{
        [self.postVideoButton setEnabled:NO];
        [self.postVideoButton setBackgroundColor:[UIColor grayColor]];
    }
    
    if (is_vip) {
        self.payTypeVIP.selected = true;
        self.payTypeNomal.selected = false;
    }else{
        self.payTypeVIP.selected = false;
        self.payTypeNomal.selected = true;
    }
    
   
    [self displayShowPrice];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
-(void)progressUploadVideo:(NSNotification*)noti
{
 
    NSDictionary *prodic = (NSDictionary*)noti.object;
//    NSString *keyst = [prodic objectForKey:@"key"];
    NSString *percentSt = [prodic objectForKey:@"percent"];
    
    WeakSelf
    vkGcdMain(^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        MBProgressHUD *hud = [MBProgressHUD HUDForView:strongSelf.videoimgView];
        if (hud) {
            hud.progress = [percentSt floatValue];
        }else{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:strongSelf.videoimgView animated:YES];
            hud.mode = MBProgressHUDModeAnnularDeterminate;
            hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
            hud.bezelView.color = UIColor.clearColor;
            hud.progress = [percentSt floatValue];
        }
        [strongSelf.postVideoButton setTitle:[NSString stringWithFormat:@"%@...%.2f%%", YZMsg(@"post_video_uploading"), percentSt.doubleValue*100] forState:UIControlStateNormal];
        strongSelf.postVideoButton.progress = [percentSt floatValue];
    });
    
   
   
 
}
-(void)progressFinishUploadVideo:(NSNotification*)noti
{
    NSDictionary *finishedDic = (NSDictionary*)noti.object;
    if ([[finishedDic objectForKey:@"info"] isEqualToString:@"S3"]) {
        if ([[finishedDic objectForKey:@"isOK"] isEqualToString:@"YES"]) {
            [CachePostVideo sharedManager].asset = nil;
            [CachePostVideo sharedManager].videoToken = nil;
        } else {
            [CachePostVideo sharedManager].videoToken = nil;
        }
        WeakSelf
        vkGcdMain(^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            MBProgressHUD *hud = [MBProgressHUD HUDForView:strongSelf.videoimgView];
            [hud hideAnimated:YES];
            
            if ([[finishedDic objectForKey:@"isOK"] isEqualToString:@"YES"]) {
                [strongSelf.postVideoButton setEnabled:YES];
                [strongSelf.postVideoButton setBackgroundColor:RGB(50, 4, 56)];
                strongSelf.postVideoButton.progress = 0.0;
                [CachePostVideo sharedManager].videoisUploading = false;
                [strongSelf didFinishUploadCoverAndVideoCanPost];
                
            } else {
                [strongSelf.postVideoButton setEnabled:NO];
                [strongSelf.postVideoButton setBackgroundColor:[UIColor grayColor]];
                strongSelf.postVideoButton.progress = 0.0;
                
                if ([[finishedDic objectForKey:@"resetUpload"] isEqualToString:@"YES"]) {
                    // 重新获取token整个文件重新上传。
                    [strongSelf uploadVideo];
                } else {
                    strongSelf.addVideoLabel.text = YZMsg(@"myInfoEdit_Upload_Error");
                    strongSelf.addVideoLabel.textColor = [UIColor whiteColor];
                    //[strongSelf addShadawn:[UIColor blackColor] label:strongSelf.addVideoLabel];
                    
                    
                    [strongSelf.addVideoButton setImage:[ImageBundle imagewithBundleName:@"post_video_error"] forState:UIControlStateNormal];
                    strongSelf.addVideoButton.hidden = NO;
                }
                [MBProgressHUD hideHUD];
                [CachePostVideo sharedManager].videoisUploading = false;
            }
        });
        return;
    }
    
    QNResponseInfo *info = [finishedDic objectForKey:@"info"];
    [CachePostVideo sharedManager].videoisUploading = false;
    if (![info isKindOfClass:[QNResponseInfo class]]) {
        [self cancelUploadVideo];
        return;
    }
    if (info.isOK) {
        [CachePostVideo sharedManager].asset = nil;
        [CachePostVideo sharedManager].videoToken = nil;
    }else{
        [CachePostVideo sharedManager].videoToken = nil;
    }
    
    WeakSelf
    vkGcdMain(^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        MBProgressHUD *hud = [MBProgressHUD HUDForView:strongSelf.videoimgView];
        [hud hideAnimated:YES];
        
        if (info.isOK) {
            strongSelf.addVideoLabel.text = YZMsg(@"PostVideo_sub_title3_1");
            strongSelf.addVideoLabel.textColor = [UIColor whiteColor];
            //[strongSelf addShadawn:[UIColor blackColor] label:strongSelf.addVideoLabel];
           
            [strongSelf.postVideoButton setEnabled:YES];
            [strongSelf.postVideoButton setBackgroundColor:RGB(50, 4, 56)];
            strongSelf.postVideoButton.progress = 0.0;
            
            [strongSelf didFinishUploadCoverAndVideoCanPost];
        }else{
            [strongSelf.postVideoButton setEnabled:NO];
            [strongSelf.postVideoButton setBackgroundColor:[UIColor grayColor]];
            strongSelf.postVideoButton.progress = 0.0;
            
            strongSelf.addVideoLabel.text = YZMsg(@"myInfoEdit_Upload_Error");
            strongSelf.addVideoLabel.textColor = [UIColor whiteColor];
            //[strongSelf addShadawn:[UIColor blackColor] label:strongSelf.addVideoLabel];
            
            
            [strongSelf.addVideoButton setImage:[ImageBundle imagewithBundleName:@"post_video_error"] forState:UIControlStateNormal];
            strongSelf.addVideoButton.hidden = NO;
            
            [MBProgressHUD showError:info.message];
        }
        
    });
   
   
}


-(void)getTagsInfo{

    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"ShortVideo.getTopicList" withBaseDomian:YES andParameter:@{@"p":@"1"} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0 && [info isKindOfClass:[NSDictionary class]]) {
            NSDictionary *infodic = info;
            NSArray *arrayTags = infodic[@"topic_list"];
            strongSelf->can_upload = [infodic[@"can_upload"] boolValue];
            strongSelf->fee_enabled = [infodic[@"fee_enabled"] boolValue];
            if (arrayTags.count>0) {
                [strongSelf showTagsDefault:arrayTags];
            }
            if (!strongSelf->fee_enabled) {
                [strongSelf.payTypeView removeAllSubviews];
            }
        } else {
            
        }
    } fail:^(NSError * _Nonnull error) {
      
    }];
    
}

-(void)showTagsDefault:(NSArray*)tags
{
    self.dataArrays = tags;
    [self.tagsBgView removeAllSubviews];
    UIView *lastView;
    if ([CachePostVideo sharedManager].selectedOtherTags.count>0) {
        UILabel *labelSelected = [UILabel new];
        labelSelected.textColor = [UIColor blackColor];
        labelSelected.font = [UIFont systemFontOfSize:13];
        labelSelected.text  = YZMsg(@"post_video_other_tags");
        [self.tagsBgView addSubview:labelSelected];
        
        [labelSelected mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.addTagLabel.mas_left);
            make.top.mas_equalTo(self.addTagLabel.mas_bottom).offset(10);
        }];
        
        lastView = [self showHotTags:[CachePostVideo sharedManager].selectedOtherTags lastView:labelSelected isSelected:YES isLast:NO];
    }
    
    NSDictionary *hotDic = tags[0];
    UILabel * labelHot = [UILabel new];
    labelHot.textColor = [UIColor blackColor];
    labelHot.font = [UIFont systemFontOfSize:13];
    labelHot.text  = hotDic[@"name"];
    [self.tagsBgView addSubview:labelHot];
    
    [labelHot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.addTagLabel.mas_left);
        make.top.mas_equalTo(lastView?lastView.mas_bottom:self.addTagLabel.mas_bottom).offset(10);
    }];
    
    
    NSArray *arrayTagsHot = [hotDic objectForKey:@"children"];
    if (arrayTagsHot!= nil && arrayTagsHot.count>0) {
        [self showHotTags:arrayTagsHot lastView:labelHot isSelected:NO isLast:YES];
    }
    
   
    
}

- (UIView *)moreView {
    if (!_moreView) {
        _moreView = [[UIView alloc] init];
        _moreView.backgroundColor = RGB_COLOR(@"#F6F0FE", 1);
        _moreView.layer.cornerRadius = 11;
        _moreView.layer.masksToBounds = YES;
        [_moreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@22);
        }];

        UIImageView *arrowImageView = [[UIImageView alloc] init];
        arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
        arrowImageView.image = [ImageBundle imagewithBundleName:@"HotHeaderRightArrowIcon"];
        [_moreView addSubview:arrowImageView];
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_moreView).offset(-9);
            make.centerY.equalTo(_moreView);
            make.size.equalTo(@12);
        }];

        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        titleLabel.text = YZMsg(@"More_title");
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = RGB_COLOR(@"#4D4D4D", 1);
        [_moreView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_moreView).offset(15);
            make.top.bottom.equalTo(_moreView);
            make.right.equalTo(arrowImageView.mas_left);
        }];

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMore)];
        [_moreView addGestureRecognizer:tap];
    }
    return _moreView;
}
-(void)tapMore{

    AddTagsViewController *postVideo = [[AddTagsViewController alloc]initWithNibName:@"AddTagsViewController" bundle:[XBundle currentXibBundleWithResourceName:@"AddTagsViewController"]];
    postVideo.datas = [NSMutableArray arrayWithArray:self.dataArrays];
    postVideo.delelgate = self;
    [[MXBADelegate sharedAppDelegate] pushViewController:postVideo animated:YES];
    
}

-(UIView*)showHotTags:(NSArray*)tagsHot lastView:(UIView*)lastView isSelected:(BOOL)selected isLast:(BOOL)isLast{
    [self.view layoutIfNeeded];

    if (tagsHot != nil && tagsHot.count > 0) {
        UIView *theLastV = lastView;
        UIView *previousLabel = nil;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat horizontalPadding = 10;
        CGFloat verticalPadding = 10;
        CGFloat currentX = horizontalPadding; // 当前X坐标
        CGFloat currentY = CGRectGetMaxY(lastView.frame) + verticalPadding; // 当前Y坐标

        for (int i = 0; i < tagsHot.count; i++) {
            NSDictionary *subDicTag = tagsHot[i];
            NSString *tagName = subDicTag[@"name"];
            NSString *tagId = subDicTag[@"id"];

            UILabel *labelTag = [UILabel new];
            labelTag.font = [UIFont systemFontOfSize:12];
            labelTag.backgroundColor = [UIColor whiteColor];
            labelTag.layer.cornerRadius = 13;
            labelTag.clipsToBounds = YES;
            labelTag.layer.borderColor = [UIColor orangeColor].CGColor;
            labelTag.layer.borderWidth = 0.5;
            labelTag.userInteractionEnabled = YES;
            [labelTag vk_addTapAction:self selector:@selector(labelClick:)];
            
            labelTag.text = [NSString stringWithFormat:@"  #%@", tagName];
            labelTag.tag = [tagId integerValue];
            labelTag.textColor = [UIColor blackColor];
            [self.tagsBgView addSubview:labelTag];

            if ([selectedAllIds containsObject:tagId] || selected) {
                labelTag.backgroundColor = RGB(50, 4, 56);
                labelTag.textColor = [UIColor whiteColor];
            }
            
            // Calculate label size
            CGSize labelSize = [labelTag sizeThatFits:CGSizeMake(CGFLOAT_MAX, 26)];
            labelTag.frame = CGRectMake(0, 0, labelSize.width + 10, 26);

            // Check if the label fits in the current row
            if (currentX + labelTag.frame.size.width > screenWidth - horizontalPadding) {
                // Move to the next row
                currentX = horizontalPadding;
                currentY += labelTag.frame.size.height + verticalPadding;
            }
//            if (i == tagsHot.count - 1 && isLast) {
//                // Set label frame
//                [labelTag mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.left.mas_equalTo(currentX);
//                    make.top.mas_equalTo(currentY);
//                    make.width.mas_equalTo(labelTag.frame.size.width);
//                    make.height.mas_equalTo(labelTag.frame.size.height);
//                    make.bottom.mas_equalTo(self.tagsBgView.bottom).offset(-150);
//                }];
//            }else{
                // Set label frame
                [labelTag mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(currentX);
                    make.top.mas_equalTo(currentY);
                    make.width.mas_equalTo(labelTag.frame.size.width);
                    make.height.mas_equalTo(labelTag.frame.size.height);
                    
                }];
//            }
           

            // Update currentX for the next label
            currentX += labelTag.frame.size.width + horizontalPadding;

            previousLabel = labelTag;

            if (i == tagsHot.count - 1) {
                theLastV = labelTag;
            }
        }

        [self.view layoutIfNeeded];
        return theLastV;
    } else {
        return lastView;
    }
}

-(void)labelClick:(UITapGestureRecognizer*)subLabe
{
    // 檢查標籤數量是否已達到上限
    if ([CachePostVideo sharedManager].selectedCurrentTags.count >= 5) {
        [MBProgressHUD showError:YZMsg(@"post_video_max_tags")];
        return;
    }
    UILabel *subTpV =  (UILabel*)subLabe.view;
    NSInteger tagClick  = subTpV.tag;
    NSDictionary *subDic = @{@"name":[subTpV.text substringFromIndex:3],@"id":minnum(tagClick)};
    
    if (subTpV.backgroundColor== [UIColor whiteColor]) {
        subTpV.backgroundColor = RGB(50, 4, 56);
        subTpV.textColor = [UIColor whiteColor];
        
        [self addTagInselectedTags:subDic];
    }else{
        subTpV.backgroundColor = [UIColor whiteColor];
        subTpV.textColor = [UIColor blackColor];
        [self removeTagInselectedTags:subDic];
    }
}

-(void)addTagInselectedTags:(NSDictionary*)tagDic
{
    if([CachePostVideo sharedManager].selectedCurrentTags == nil){
        [CachePostVideo sharedManager].selectedCurrentTags = [NSMutableArray array];
    }
    
    NSInteger tagDicid = [tagDic[@"id"] integerValue];
    BOOL isContent = false;
    for (NSDictionary *subDic in [CachePostVideo sharedManager].selectedCurrentTags) {
        NSInteger tagsC = [subDic[@"id"] integerValue];
        if (tagDicid == tagsC) {
            isContent = true;
            break;
        }
    }
    if (!isContent) {
        [[CachePostVideo sharedManager].selectedCurrentTags addObject:tagDic];
    }
    selectedAllIds = [[CachePostVideo sharedManager]getAllCurrentTags];
}

-(void)removeTagInselectedTags:(NSDictionary*)tagDic
{
    if([CachePostVideo sharedManager].selectedCurrentTags == nil){
        [CachePostVideo sharedManager].selectedCurrentTags = [NSMutableArray array];
    }
    NSInteger tagDicid = [tagDic[@"id"] integerValue];
    NSDictionary *contentDIc;
    for (NSDictionary *subDic in [CachePostVideo sharedManager].selectedCurrentTags) {
        NSInteger tagsC = [subDic[@"id"] integerValue];
        if (tagDicid == tagsC) {
            contentDIc = subDic;
            break;
        }
    }
    if (contentDIc) {
        [[CachePostVideo sharedManager].selectedCurrentTags removeObject:contentDIc];
    }
    
    selectedAllIds = [[CachePostVideo sharedManager]getAllCurrentTags];
}

- (IBAction)addVideo:(UIButton *)sender {
    
    if ([CachePostVideo sharedManager].videoisUploading) {
        WeakSelf
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:YZMsg(@"public_warningAlert") message:YZMsg(@"PostVideo_sub_title_cancel") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sure = [UIAlertAction actionWithTitle:YZMsg(@"PostVideo_cancel_upload") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf cancelUploadVideo];
            [strongSelf choiseVideo];
            
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:YZMsg(@"PostVideo_continue_upload") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertC dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertC addAction:sure];
        [alertC addAction:cancel];
        [self presentViewController:alertC animated:YES completion:nil];
    }else{
        if ([CachePostVideo sharedManager].videoImage) {
            [self addCover: nil];
        } else {
            [self choiseVideo];
        }
    }
    
    
    
}

-(void)choiseVideo{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    
    imagePickerVc.isSelectOriginalPhoto = YES;
    
//    imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
    
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.allowTakeVideo = NO;   // 在内部显示拍视频按
    imagePickerVc.videoMaximumDuration = 108000; // 视频最大拍摄时间
    imagePickerVc.allowEditVideo = NO; // 允许编辑视频
  
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = NO; // 是否可以多选视频
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = NO;
    
  
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = NO;
    imagePickerVc.needCircleCrop = NO;
    // 设置竖屏下的裁剪尺寸
  
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = NO;
 
    // 自定义gif播放方案
    [[TZImagePickerConfig sharedInstance] setGifImagePlayBlock:^(TZPhotoPreviewView *view, UIImageView *imageView, NSData *gifData, NSDictionary *info) {
        SDAnimatedImage *animatedImage = [SDAnimatedImage imageWithData:gifData];
        SDAnimatedImageView *animatedImageView;
        for (UIView *subview in imageView.subviews) {
            if ([subview isKindOfClass:[SDAnimatedImageView class]]) {
                animatedImageView = (SDAnimatedImageView *)subview;
                animatedImageView.frame = imageView.bounds;
                animatedImageView.image = nil;
            }
        }
        if (!animatedImageView) {
            animatedImageView = [[SDAnimatedImageView alloc] initWithFrame:imageView.bounds];
            animatedImageView.runLoopMode = NSDefaultRunLoopMode;
            [imageView addSubview:animatedImageView];
        }
        animatedImageView.image = animatedImage;
    }];
    
    // 设置首选语言 / Set preferred language
    // imagePickerVc.preferredLanguage = @"zh-Hans";
    
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (IBAction)addCover:(id)sender {

    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing = NO;

    // 添加所有图片类型，包括 GIF 和实况照片
    NSMutableArray *mediaTypes = [NSMutableArray array];
    [mediaTypes addObject:(NSString *)kUTTypeImage];          // 静态图片
    [mediaTypes addObject:(NSString *)kUTTypeGIF];            // 动态GIF图片

    // 检查是否支持实况照片
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeLivePhoto]) {
            [mediaTypes addObject:(NSString *)kUTTypeLivePhoto]; // 实况照片
        }
    }

    imagePickerController.mediaTypes = mediaTypes;

    if (self.presentedViewController == nil) {
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }

}
- (IBAction)postVideo:(id)sender {
    if ([CachePostVideo sharedManager].coverisUploading || [CachePostVideo sharedManager].videoisUploading) {
        return;
    }
    NSString *titleSTr = self.titleTextField.text;
    if ([PublicObj checkNull:titleSTr]) {
        [MBProgressHUD showError:YZMsg(@"PostVideo_sub_title2")];
        return;
    }
    
    NSString *tagsStr = @"";
    for (NSDictionary *subDic in [CachePostVideo sharedManager].selectedOtherTags) {
        NSString *tagid = subDic[@"id"];
        tagsStr = [tagsStr stringByAppendingFormat:@"%@%@",tagsStr.length>0?@",":@"",tagid];
    }
    for (NSDictionary *subDic in [CachePostVideo sharedManager].selectedCurrentTags) {
        NSString *tagid = subDic[@"id"];
        tagsStr = [tagsStr stringByAppendingFormat:@"%@%@",tagsStr.length>0?@",":@"",tagid];
    }
    if ([PublicObj checkNull:tagsStr]) {
        [MBProgressHUD showError:YZMsg(@"PostVideo_chooseTag")];
        return;
    }
    
    if ([CachePostVideo sharedManager].videoImage) {
        UIImage *coverImage = [CachePostVideo sharedManager].videoImage;
        NSData *imgData = UIImageJPEGRepresentation(coverImage, 0.9);
        [self uploadCover:imgData fileName:@"image.jpg" mintype:@"image/jpeg" image:coverImage];
    }
}

- (void)didFinishUploadCoverAndVideoCanPost {
    if (!can_upload) {
        [MBProgressHUD showMessage:YZMsg(@"post_video_no_rule")];
        return;
    }
  
    
    [MBProgressHUD showMessage:YZMsg(@"post_video_uploading")];
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=ShortVideo.onUploadFinish&uid=%@&token=%@", [Config getOwnID], [Config getOwnToken]];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    
    NSString *titleSTr = self.titleTextField.text;
    if ([PublicObj checkNull:titleSTr]) {
        [MBProgressHUD showError:YZMsg(@"PostVideo_sub_title2")];
        return;
    }
    [paramDic setObject:titleSTr forKey:@"title"];
    [paramDic setObject:titleSTr forKey:@"description"];
    
    if ([PublicObj checkNull:[CachePostVideo sharedManager].cover_aid] ||[PublicObj checkNull:[CachePostVideo sharedManager].video_aid]||[CachePostVideo sharedManager].asset!= nil) {
        [MBProgressHUD showError:YZMsg(@"post_video_upload_wait")];
        return;
    }
    if ([PublicObj checkNull:[CachePostVideo sharedManager].video_aid]) {
        [MBProgressHUD showError:YZMsg(@"post_video_upload_retry")];
        return;
    }
    if ([PublicObj checkNull:[CachePostVideo sharedManager].cover_aid]) {
        [MBProgressHUD showError:YZMsg(@"post_video_upload_cover_again")];
        return;
    }
    
    if ([CachePostVideo sharedManager].coverisUploading) {
        [MBProgressHUD showError:YZMsg(@"PostVideo_sub_wait_cover")];
        return;
    }
    if ([CachePostVideo sharedManager].videoisUploading) {
        [MBProgressHUD showError:YZMsg(@"PostVideo_sub_wait_video")];
        return;
    }
    
    [paramDic setObject:[CachePostVideo sharedManager].video_aid forKey:@"video_aid"];
    [paramDic setObject:[CachePostVideo sharedManager].cover_aid forKey:@"cover_aid"];
    
    NSString *tagsStr = @"";
    for (NSDictionary *subDic in [CachePostVideo sharedManager].selectedOtherTags) {
        NSString *tagid = subDic[@"id"];
        tagsStr = [tagsStr stringByAppendingFormat:@"%@%@",tagsStr.length>0?@",":@"",tagid];
    }
    for (NSDictionary *subDic in [CachePostVideo sharedManager].selectedCurrentTags) {
        NSString *tagid = subDic[@"id"];
        tagsStr = [tagsStr stringByAppendingFormat:@"%@%@",tagsStr.length>0?@",":@"",tagid];
    }
    [paramDic setObject:tagsStr forKey:@"topic_ids"];
    
    [paramDic setObject:is_vip?@"1":@"0" forKey:@"is_vip"];
    
    NSString *coin_cost_value = @"";
    
    if ([CachePostVideo sharedManager].coin_cost) {
        coin_cost_value =[NSString stringWithFormat:@"%f",[[CachePostVideo sharedManager].coin_cost doubleValue]];
    }
    
    [paramDic setObject:coin_cost_value forKey:@"coin_cost"];
    [paramDic setObject:[CachePostVideo sharedManager].ticket_cost?[CachePostVideo sharedManager].ticket_cost:@"" forKey:@"ticket_cost"];
    
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:NO andParameter:paramDic data:nil  success:^(int code, NSArray *infos, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [MBProgressHUD hideHUD];
        if (code == 0) {
            
            [MBProgressHUD showSuccess:msg];
            if (strongSelf.fromMyCreatVC) {
                [strongSelf doDeleleVideo];
                [[NSNotificationCenter defaultCenter] postNotificationName:UploadVideoAndInfoFinished object:nil];
                [strongSelf.navigationController popViewControllerAnimated:YES];
            }else{
                MyCreateMainVC *vc = [MyCreateMainVC new];
                vc.isFromPost = YES;
                [[MXBADelegate sharedAppDelegate] pushViewController:vc animated:YES];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf doDeleleVideo];
                    // 从导航控制器中移除当前的控制器
                    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:strongSelf.navigationController.viewControllers];
                    if (viewControllers.count > 1) {
                        // 找到当前的控制器，并将其移除
                        [viewControllers removeObject:strongSelf];
                        [strongSelf.navigationController setViewControllers:viewControllers animated:YES];
                    }
                });
            }
            
        } else {
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError *error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:YZMsg(@"myInfoEdit_Upload_Error")];
    }];
}


- (void)refreshCollectionViewWithAddedAsset:(PHAsset *)asset image:(UIImage *)image {
//    [_selectedAssets addObject:asset];
//    [_selectedPhotos addObject:image];
   
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos {
   
    
}


- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset {
    
    [self readyForUploadVideo:asset cover:coverImage];
  
    
}

-(void)readyForUploadVideo:(PHAsset *)asset cover:(UIImage *)coverImage {
    NSString *imgKey = [asset.description toMD5];
    [CachePostVideo sharedManager].videoKey = imgKey;
    [CachePostVideo sharedManager].asset = asset;
    [CachePostVideo sharedManager].videoImage = coverImage;
    self.videoimgView.image = coverImage;
    self.addVideoButton.hidden = YES;
    self.addVideoLabel.text = YZMsg(@"PostVideo_sub_title4_1");
    self.addVideoLabel.textColor = [UIColor whiteColor];
    //[self addShadawn:[UIColor blackColor] label:self.addVideoLabel];
    [self.postVideoButton setEnabled:YES];
    [self.postVideoButton setBackgroundColor:RGB(50, 4, 56)];
}
- (void)imagePickerController:(TZImagePickerController *)picker didFailToSaveEditedVideoWithError:(NSError *)error {
    NSLog(@"编辑后的视频自动保存到相册失败:%@",error.description);
}
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(PHAsset *)asset {

}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *type = minstr([info objectForKey:UIImagePickerControllerMediaType]);
    if ([type isEqualToString:(NSString *)kUTTypeImage]) {
        // 获取选中的图片
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!image) {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        // 根据图片类型设置 filename 和 mimeType
        NSString *fileName;
        NSString *mimeType;
        NSData *data;
        
//        NSURL *imgUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
//        if ([type isEqualToString:(NSString *)kUTTypeGIF]||(imgUrl!= nil &&[imgUrl.absoluteString containsString:@"ext=GIF"])) {
//      
//            NSURL *dataUrl = [info objectForKey:UIImagePickerControllerImageURL];
//            if (dataUrl) {
//                data = [NSData dataWithContentsOfURL:dataUrl];
//            }
//            image = [SDAnimatedImage imageWithData:data];
//            fileName = @"image.gif";
//            mimeType = @"image/gif";
//        } else if (UTTypeConformsTo((__bridge CFStringRef)type, kUTTypeJPEG)) {
//            data = UIImageJPEGRepresentation(image, 0.9);
//            fileName = @"image.jpg";
//            mimeType = @"image/jpeg";
//        } else if (UTTypeConformsTo((__bridge CFStringRef)type, kUTTypePNG)) {
//            data = UIImagePNGRepresentation(image);
//            fileName = @"image.png";
//            mimeType = @"image/png";
//        } else {
//            // 默认使用 JPEG 格式
//            data = UIImageJPEGRepresentation(image, 0.9);
//            fileName = @"image.jpg";
//            mimeType = @"image/jpeg";
//        }
        
       
       
        WeakSelf
        [picker dismissViewControllerAnimated:YES completion:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf.videoimgView.image = image;
//            [strongSelf uploadCover:data fileName:fileName mintype:mimeType image:image];
        }];
        
    }else if ([type isEqualToString:@"public.movie"]) {
//        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
//        if (videoUrl) {
//            [[TZImageManager manager] saveVideoWithUrl:videoUrl location:nil completion:^(PHAsset *asset, NSError *error) {
//
//                if (!error) {
//                    TZAssetModel *assetModel = [[TZImageManager manager] createModelWithAsset:asset];
//                    [[TZImageManager manager] getPhotoWithAsset:assetModel.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
//                        if (!isDegraded && photo) {
//                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:photo];
//                        }
//                    }];
//                }
//            }];
//        }
    }
}
-(void)uploadCover:(NSData*)data fileName:(NSString*)fileName  mintype:(NSString*)mimeType image:(UIImage*)image{
    
    [CachePostVideo sharedManager].coverisUploading = true;
    
    [CachePostVideo sharedManager].cover_aid = @"";
    [CachePostVideo sharedManager].cover_url = @"";
    //self.coverImgView.image = image;
    self.videoimgView.image = image;
    
    DataForUpload *dataUpload = [[DataForUpload alloc] init];
    dataUpload.datas = data;
    dataUpload.name = @"file";
    dataUpload.filename = fileName;
    dataUpload.mimeType = mimeType;
    
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=ShortVideo.uploadCover&uid=%@&token=%@", [Config getOwnID], [Config getOwnToken]];

    [self.addVideoButton setImage:[ImageBundle imagewithBundleName:@"post_video_img"] forState:UIControlStateNormal];
    self.addVideoButton.hidden = YES;
    [self.postVideoButton setTitle:YZMsg(@"post_video_uploading") forState:UIControlStateNormal];
    [self.postVideoButton setBackgroundColor:[UIColor grayColor]];
    
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:NO andParameter:nil data:dataUpload progress:^(NSProgress * _Nonnull progress) {
      
        NSLog(@"progress %.2f",progress.fractionCompleted);
    } success:^(int code, NSArray *infos, NSString *msg) {
        STRONGSELF
        [CachePostVideo sharedManager].coverisUploading = false;
        if (strongSelf == nil) {
            return;
        }
        [MBProgressHUD hideHUD];
        if (code == 0 && [infos isKindOfClass:[NSDictionary class]]) {
            strongSelf.addVideoLabel.text = YZMsg(@"PostVideo_sub_title4_1");
            strongSelf.addVideoLabel.textColor = [UIColor whiteColor];
            //[strongSelf addShadawn:[UIColor blackColor] label:strongSelf.addVideoLabel];
            [CachePostVideo sharedManager].cover_aid = [NSString stringWithFormat:@"%@",[(NSDictionary*)infos objectForKey:@"cover_aid"]];
            [CachePostVideo sharedManager].cover_url = [NSString stringWithFormat:@"%@",[(NSDictionary*)infos objectForKey:@"url"]];
            [strongSelf uploadVideo];
        } else {
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError *error) {
        STRONGSELF
        [CachePostVideo sharedManager].coverisUploading = false;
        if (strongSelf == nil) {
            return;
        }
        [CachePostVideo sharedManager].cover_aid = nil;
        
        [MBProgressHUD showError:YZMsg(@"myInfoEdit_Upload_Error")];
        [strongSelf.postVideoButton setTitle:YZMsg(@"PostVideo_sub_title6") forState:UIControlStateNormal];
        [strongSelf.postVideoButton setBackgroundColor:RGB(50, 4, 56)];
    }];
}


-(void)uploadVideo{
    
    [CachePostVideo sharedManager].videoToken = @"";
    [CachePostVideo sharedManager].video_aid = @"";
    
    NSString *url = [[DomainManager sharedInstance].baseAPIString stringByAppendingFormat:@"?service=ShortVideo.getUploadToken&uid=%@&token=%@&cover_aid=%@", [Config getOwnID], [Config getOwnToken], [CachePostVideo sharedManager].cover_aid];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.videoimgView animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = UIColor.clearColor;
    [self.addVideoButton setImage:[ImageBundle imagewithBundleName:@"post_video_img"] forState:UIControlStateNormal];
    self.addVideoButton.hidden = YES;
    
    self.addVideoLabel.text = YZMsg(@"PostVideo_sub_title3_1");
    self.addVideoLabel.textColor = [UIColor whiteColor];
    //[self addShadawn:[UIColor blackColor] label:self.addVideoLabel];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:NO andParameter:nil data:nil  success:^(int code, NSArray *infos, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0 && [infos isKindOfClass:[NSDictionary class]]) {
            NSString *token =[(NSDictionary*)infos objectForKey:@"token"];
            NSString *video_aid =[(NSDictionary*)infos objectForKey:@"video_aid"];
            NSString *type =[(NSDictionary*)infos objectForKey:@"type"];
            NSString *upload_server_rul = [(NSDictionary*)infos objectForKey:@"upload_server"];
            [CachePostVideo sharedManager].videoToken = token;
            [CachePostVideo sharedManager].video_aid = video_aid;
            
            if ([type isEqualToString:@"S3"]) {
                [strongSelf uploadToS3:upload_server_rul token:token];
            } else {
                [PostVideoViewController uploadToQiniu];
            }
        } else {
            [hud hideAnimated:YES];
            [MBProgressHUD hideHUD];
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError *error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        
        [hud hideAnimated:YES];
        strongSelf.addVideoButton.hidden = NO;
        [strongSelf.addVideoButton setImage:[ImageBundle imagewithBundleName:@"post_video_error"] forState:UIControlStateNormal];
        [CachePostVideo sharedManager].video_aid = nil;
        [MBProgressHUD hideHUD];
        [MBProgressHUD showError:YZMsg(@"myInfoEdit_Upload_Error")];
        [strongSelf.postVideoButton setTitle:YZMsg(@"PostVideo_sub_title6") forState:UIControlStateNormal];
        [strongSelf.postVideoButton setBackgroundColor:RGB(50, 4, 56)];
    }];
    
}



- (void)uploadToS3:(NSString *)uploadServerUrl token:(NSString *)token {
    [CachePostVideo sharedManager].videoisUploading = true;
    PHAsset *asset = [CachePostVideo sharedManager].asset;
    WeakSelf
    [self getVideoURLFromPHAsset:asset completion:^(NSURL *fileURL) {
        STRONGSELF
        if (!strongSelf) return;
        if (fileURL) {
            FileUploadManager *uploadManager = [[FileUploadManager alloc] initWithFileURL:fileURL token:token server:uploadServerUrl];
            [uploadManager uploadFile];
        } else {
            [strongSelf.postVideoButton setTitle:YZMsg(@"PostVideo_sub_title6") forState:UIControlStateNormal];
            [strongSelf.postVideoButton setBackgroundColor:RGB(50, 4, 56)];
            [CachePostVideo sharedManager].videoisUploading = false;
            NSLog(@"Failed to retrieve file URL from PHAsset");
        }
    }];

}

- (void)getVideoURLFromPHAsset:(PHAsset *)asset completion:(void (^)(NSURL *fileURL))completion {
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionCurrent;
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
            if ([avAsset isKindOfClass:[AVURLAsset class]]) {
                NSURL *url = [(AVURLAsset *)avAsset URL];
                // 视频资源已经成功获取到本地URL
                completion(url);
            } else {
                completion(nil);
            }
        }];
    } else {
        completion(nil);
    }
}

+(void)uploadToQiniu{
    [CachePostVideo sharedManager].videoisUploading = true;
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.resumeUploadVersion = QNResumeUploadVersionV1;
        builder.useConcurrentResumeUpload = YES;
        builder.concurrentTaskCount = 2;
        builder.useHttps = YES;
        builder.chunkSize = 1 * 1024 * 100;
        builder.recorder = [QNFileRecorder fileRecorderWithFolder:[NSHomeDirectoryForUser([Config getOwnID]) stringByAppendingString:@"UploadFileRecord"] error:nil];
    }];
    
    // 上传过程中实时执行此函数
     QNUploadOption *uploadOption = [[QNUploadOption alloc]initWithMime:nil progressHandler:^(NSString *key, float percent) {
         // 上传进度
         NSLog(@"%f",percent);
         [[NSNotificationCenter defaultCenter] postNotificationName:UploadVideoProgress object:@{@"key":key,@"percent":min2float(percent)}];
     } params:nil checkCrc:NO cancellationSignal:^BOOL{
         //上传中途取消函数 如果想取消，返回True, 否则返回No
         return  ![CachePostVideo sharedManager].videoisUploading;
     }];
     
     QNUploadManager *uploadManager = [[QNUploadManager alloc]initWithConfiguration:config];
     [uploadManager putPHAsset:[CachePostVideo sharedManager].asset key:[CachePostVideo sharedManager].videoKey token:[CachePostVideo sharedManager].videoToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
         NSLog(@"info == %@",info);
         NSLog(@"key == %@",key);
         NSLog(@"resp == %@",resp);
         if (info.isOK) {
//             [MBProgressHUD showSuccess:YZMsg(@"PostVideo_sub_upload_video_success")];
         }else{
             [MBProgressHUD showError:YZMsg(@"PostVideo_sub_upload_video_error")];
         }
         [[NSNotificationCenter defaultCenter] postNotificationName:UploadVideoFinished object:@{@"info":info?info:@"",@"key":key?key:@"",@"resp":resp?resp:@""}];
         
     } option:uploadOption];
    
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([UIDevice currentDevice].systemVersion.floatValue < 11) {
        return;
    }
    if ([viewController isKindOfClass:NSClassFromString(@"PUPhotoPickerHostViewController")]) {
        [viewController.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.frame.size.width < 42) {
                [viewController.view sendSubviewToBack:obj];
                *stop = YES;
            }
        }];
    }
}
-(void)addOtherTags:(NSArray*)tags
{
    [self showTagsDefault:self.dataArrays];
}

#pragma mark - PostRulesView 相关设定

- (void)setupPostRulesView {
    self.postRulesShadowView = [UIView new];
    self.postRulesShadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [self.postRulesShadowView setHidden:YES];
    [self.postRulesShadowView setAlpha:0];
    [self.view addSubview:self.postRulesShadowView];
    [self.postRulesShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    self.postRulesView = [UIView new];
    self.postRulesView.backgroundColor = vkColorHex(0xEAE7EE);
    self.postRulesView.layer.cornerRadius = 20;
    self.postRulesView.layer.masksToBounds = YES;
    self.postRulesView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.postRulesView addGestureRecognizer:panGesture];
    [self.view addSubview:self.postRulesView];
    
    // 设置 postRulesView 高度为屏幕高度的 70%
    self.postRulesViewHeight = self.view.bounds.size.height * 0.7;
    [self.postRulesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(self.postRulesViewHeight);
        make.bottom.mas_equalTo(self.view).offset(self.postRulesViewHeight);
    }];

    UIImageView *topIndicator = [UIImageView new];
    topIndicator.image = [ImageBundle imagewithBundleName:@"home_search_indicator"];
    [self.postRulesView addSubview:topIndicator];
    [topIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.postRulesView.mas_top).offset(14);
        make.centerX.mas_equalTo(self.view);
        make.height.mas_equalTo(4);
    }];
    
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 20;
    bgView.layer.masksToBounds = YES;
    bgView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    [self.postRulesView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topIndicator.mas_top).offset(14);
        make.leading.trailing.mas_equalTo(self.postRulesView).inset(14);
        make.bottom.mas_equalTo(self.postRulesView);
    }];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = [NSString stringWithFormat:@"%@:", YZMsg(@"post_video_rules_title")];
    titleLabel.font = [UIFont boldSystemFontOfSize:16];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [bgView addSubview:titleLabel];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgView).offset(30);
        make.height.mas_equalTo(22);
        make.leading.trailing.mas_equalTo(bgView).inset(20);
    }];
    
    self.postRulesTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.postRulesTableView.dataSource = self;
    self.postRulesTableView.delegate = self;
    self.postRulesTableView.backgroundColor = [UIColor clearColor];
    self.postRulesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.postRulesTableView.estimatedRowHeight = 20.0f;
    self.postRulesTableView.showsVerticalScrollIndicator = NO;
    self.postRulesTableView.contentInset = UIEdgeInsetsMake(0, -10, 0, 0);
    [bgView addSubview:self.postRulesTableView];
    
    [self.postRulesTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(10);
        make.bottom.mas_equalTo(bgView).inset(34);
        make.leading.trailing.mas_equalTo(bgView).inset(10);
    }];
    
    [self createRuleData];
}

- (void)createRuleData {
    RuleSection *section1 = [RuleSection new];
    section1.title = YZMsg(@"post_video_desc_section1");
    section1.rules = @[[NSString stringWithFormat:@"・%@", YZMsg(@"post_video_desc_rulse1")]];
    
    RuleSection *section2 = [RuleSection new];
    section2.title = YZMsg(@"post_video_desc_section2");
    section2.rules = @[[NSString stringWithFormat:@"・%@", YZMsg(@"post_video_desc_rulse2_1")],
                       [NSString stringWithFormat:@"・%@", YZMsg(@"post_video_desc_rulse2_2")],
                       [NSString stringWithFormat:@"・%@", YZMsg(@"post_video_desc_rulse2_3")]];
    
    RuleSection *section3 = [RuleSection new];
    section3.title = YZMsg(@"post_video_desc_section3");
    section3.rules = @[[NSString stringWithFormat:@"・%@", YZMsg(@"post_video_desc_rulse3_1")],
                       [NSString stringWithFormat:@"・%@", YZMsg(@"post_video_desc_rulse3_2")]];
    
    RuleSection *section4 = [RuleSection new];
    section4.title = YZMsg(@"post_video_desc_section4");
    section4.rules = @[[NSString stringWithFormat:@"・%@", YZMsg(@"post_video_desc_rulse4")]];
    
    RuleSection *section5 = [RuleSection new];
    section5.title = YZMsg(@"post_video_desc_section5");
    section5.rules = @[[NSString stringWithFormat:@"・%@", YZMsg(@"post_video_desc_rulse5_1")],
                       [NSString stringWithFormat:@"・%@", YZMsg(@"post_video_desc_rulse5_2")]];
    
    RuleSection *section6 = [RuleSection new];
    section6.title = YZMsg(@"post_video_desc_section6");
    section6.rules = @[[NSString stringWithFormat:@"・%@", YZMsg(@"post_video_desc_rulse6_1")],
                       [NSString stringWithFormat:@"・%@", YZMsg(@"post_video_desc_rulse6_2")]];
    
    self.ruleSections = @[section1, section2, section3, section4, section5, section6];
}

- (void)showPostRulesView {
    if (self.postRulesShadowView.alpha != 1) {
        [self.postRulesShadowView setAlpha:0];
    }
    [self.postRulesShadowView setHidden:NO];
    [UIView animateWithDuration:0.3 animations:^{
        self.postRulesView.transform = CGAffineTransformMakeTranslation(0, -self.postRulesViewHeight);
        [self.postRulesShadowView setAlpha:1];
        [self.view layoutIfNeeded];
    }];
}

- (void)hidePostRulesView {
    [self.postRulesShadowView setAlpha:1];
    [UIView animateWithDuration:0.3 animations:^{
        self.postRulesView.transform = CGAffineTransformIdentity;
        [self.postRulesShadowView setAlpha:0];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.postRulesShadowView setHidden:YES];
    }];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.view];
    CGFloat yTranslation = translation.y;

    if (gesture.state == UIGestureRecognizerStateChanged) {
        if (yTranslation > 0) {
            // 仅允许向下拖动
            self.postRulesView.transform = CGAffineTransformMakeTranslation(0, -self.postRulesViewHeight + yTranslation);
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        CGFloat velocity = [gesture velocityInView:self.view].y;

        if (yTranslation > self.postRulesViewHeight / 2 || velocity > 1000) {
            // 如果滑动超过一半高度或速度很大，则隐藏评论视图
            [self hidePostRulesView];
        } else {
            // 否则恢复到原位
            [self showPostRulesView];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.ruleSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    RuleSection *ruleSection = self.ruleSections[section];
    return ruleSection.rules.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    RuleSection *ruleSection = self.ruleSections[section];
    return ruleSection.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"RuleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    RuleSection *ruleSection = self.ruleSections[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = ruleSection.rules[indexPath.row];
    cell.textLabel.numberOfLines = 0; // Allow multiple lines
    cell.textLabel.textColor = vkColorHex(0x4D4D4D);
    cell.textLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 22.0f;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    UIView *purpleColorView = [[UIView alloc] init];
    purpleColorView.backgroundColor = vkColorRGBA(181.0f, 149.0f, 223.0f, 0.7f);
    purpleColorView.layer.cornerRadius = 8;
    purpleColorView.layer.masksToBounds = YES;
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    headerLabel.text = [NSString stringWithFormat:@"%@", self.ruleSections[section].title];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    [view addSubview:purpleColorView];
    [purpleColorView addSubview:headerLabel];
    [purpleColorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(view);
        make.bottom.mas_equalTo(view).inset(5);;
        make.leading.mas_equalTo(view).offset(20);
    }];
    
    [headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(purpleColorView).inset(2);
        make.leading.trailing.mas_equalTo(purpleColorView).inset(5);
    }];
    return view;
}

-(void)addShadawn:(UIColor *)color label:(UILabel*)label
{
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowOffset = CGSizeMake(1.0, 1.0); // 设置阴影偏移
    shadow.shadowBlurRadius = 1.0; // 设置阴影模糊度

    NSDictionary *attributes = @{
        NSShadowAttributeName: shadow
    };

    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
    label.attributedText = attributedText;
}

- (IBAction)choisePayAction:(id)sender {
    
    [self showChoisePriceView];
    
}

-(void)showChoisePriceView{
    WeakSelf
    myAlert = Dialog()
    .wTypeSet(DialogTypeMyView)
    //关闭事件 此时要置为不然会内存泄漏
    .wEventCloseSet(^(id anyID, id otherData) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (!strongSelf->is_confirm) {
            [CachePostVideo sharedManager].coin_cost = nil;
            [CachePostVideo sharedManager].ticket_cost = @"1";
            [strongSelf displayShowPrice];
        }
        strongSelf->is_confirm = NO;
    })
    .wHeightSet(_window_width * 0.8)
    .wWidthSet(_window_width * 0.8)
    .wMainOffsetYSet(0)
    .wShowAnimationSet(AninatonZoomIn)
    .wPopViewRectCornerSet(DialogRectCornerAllCorners)
    .wPercentAngleSet(20)
    .wHideAnimationSet(AninatonZoomOut)
    .wAnimationDurtionSet(0.25)
    .wMyDiaLogViewSet(^UIView *(UIView *mainView) {
        STRONGSELF
        
        UIButton *buttonFree = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonFree.backgroundColor = [UIColor whiteColor];
        [buttonFree setBackgroundImage:[ImageBundle imagewithBundleName:@"unselected_price"] forState:UIControlStateNormal];
        [buttonFree setBackgroundImage:[ImageBundle imagewithBundleName:@"selected_price"] forState:UIControlStateSelected];
        [mainView addSubview:buttonFree];
        [buttonFree setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [buttonFree setTitle:YZMsg(@"post_video_free") forState:UIControlStateNormal];
        buttonFree.tag = 0+1000;
        //buttonFree.tag = 1;
       
//        if (![CachePostVideo sharedManager].coin_cost || [[CachePostVideo sharedManager].coin_cost isEqualToString:@"0"]) {
//            buttonFree.selected = YES;
//            if (![PublicObj checkNull:[CachePostVideo sharedManager].ticket_cost] && [[CachePostVideo sharedManager].ticket_cost isEqualToString:@"1"]) {
//                buttonFree.selected = NO;
//            }
//        }
        NSString *ticketCost = [CachePostVideo sharedManager].ticket_cost;
        NSString *coinCost = [CachePostVideo sharedManager].coin_cost;

        BOOL isTicketValid = (![PublicObj checkNull:ticketCost] && [ticketCost isEqualToString:@"1"]);
        BOOL isCoinInvalid = (!coinCost || [coinCost isEqualToString:@"0"]);

        buttonFree.selected = isTicketValid && isCoinInvalid;

        [buttonFree addTarget:self action:@selector(choiseMoneyButton:) forControlEvents:UIControlEventTouchUpInside];
        buttonFree.frame = CGRectMake(((mainView.frame.size.width)/2)-((mainView.frame.size.width)/8), 27, ((mainView.frame.size.width)/4), 24);
        /*
        buttonFree.frame = CGRectMake(((mainView.frame.size.width)/4)-6, 27, ((mainView.frame.size.width)/4), 24);
        
        UIButton *buttonTicket = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonTicket.backgroundColor = [UIColor whiteColor];
        [buttonTicket setBackgroundImage:[ImageBundle imagewithBundleName:@"unselected_price"] forState:UIControlStateNormal];
        [buttonTicket setBackgroundImage:[ImageBundle imagewithBundleName:@"selected_price"] forState:UIControlStateSelected];
        [mainView addSubview:buttonTicket];
        buttonTicket.tag = 1;
        buttonTicket.frame = CGRectMake(buttonFree.right+12, 27, ((mainView.frame.size.width)/4), 24);
        [buttonTicket setTitle:YZMsg(@"post_video_ticket_name") forState:UIControlStateNormal];
        [buttonTicket addTarget:self action:@selector(choiseMoneyButton:) forControlEvents:UIControlEventTouchUpInside];
        [buttonTicket setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        if (![PublicObj checkNull:[CachePostVideo sharedManager].ticket_cost] && [[CachePostVideo sharedManager].ticket_cost isEqualToString:@"1"]) {
            buttonTicket.selected = YES;
            if (buttonFree.selected == YES) {
                buttonTicket.selected = NO;
            }
        }
         */
        NSArray *priceArray = @[@"2",@"5",@"10",@"20",@"50",@"100"];
        
        for (int i = 0; i<priceArray.count; i++) {
            UIButton *buttonPrice = [UIButton buttonWithType:UIButtonTypeCustom];
            buttonPrice.backgroundColor = [UIColor whiteColor];
            [buttonPrice setBackgroundImage:[ImageBundle imagewithBundleName:@"unselected_price"] forState:UIControlStateNormal];
            [buttonPrice setBackgroundImage:[ImageBundle imagewithBundleName:@"selected_price"] forState:UIControlStateSelected];
            [mainView addSubview:buttonPrice];
            buttonPrice.frame = CGRectMake((mainView.frame.size.width-3*((mainView.frame.size.width)/4)-20)/2.0f+((mainView.frame.size.width)/4+10)*(i%3), buttonFree.bottom+12+((24*(((mainView.frame.size.width)/4)/60)+12)*((i)/3)), ((mainView.frame.size.width)/4), 24*(((mainView.frame.size.width)/4)/60));
            NSString *priceMoney = priceArray[i];
            buttonPrice.tag = [priceMoney integerValue]+1000;
            [buttonPrice setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [buttonPrice setTitle:[YBToolClass getRateCurrency:priceMoney showUnit:YES] forState:UIControlStateNormal];
            [buttonPrice addTarget:self action:@selector(choiseMoneyButton:) forControlEvents:UIControlEventTouchUpInside];
            
            if ([CachePostVideo sharedManager].coin_cost&&[[CachePostVideo sharedManager].coin_cost isEqualToString:priceArray[i]]) {
                buttonPrice.selected = YES;
            }
        }
        
        UILabel *otherPrice = [UILabel new];
        otherPrice.font = [UIFont systemFontOfSize:16.0f];
        otherPrice.text = [NSString stringWithFormat:@"%@(%@)%@:",YZMsg(@"post_video_other_price"),[Config getRegionCurreny],[Config getRegionCurrenyChar]];
        otherPrice.textColor = [UIColor blackColor];
        [mainView addSubview:otherPrice];
        [otherPrice sizeToFit];
        otherPrice.frame = CGRectMake((mainView.frame.size.width-87-otherPrice.width)/2.0,buttonFree.bottom+18+(12+24*(((mainView.frame.size.width)/4)/60))*(priceArray.count/3) , otherPrice.width, 24);
      
        
        UITextField *inputPrice = [UITextField new];
        strongSelf->editPriceTextField = inputPrice;
        inputPrice.backgroundColor = RGB(229, 229, 229);
        inputPrice.borderStyle = UITextBorderStyleNone;
        inputPrice.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        inputPrice.keyboardType = UIKeyboardTypeDecimalPad;
        
        UIView *lefV = [UIView new];
        lefV.size = CGSizeMake(10, 24);
        lefV.backgroundColor = [UIColor clearColor];
        inputPrice.leftView = lefV;
        inputPrice.leftViewMode = UITextFieldViewModeAlways;
        
        UIView *rithtV = [UIView new];
        rithtV.size = CGSizeMake(10, 24);
        rithtV.backgroundColor = [UIColor clearColor];
        inputPrice.leftView = rithtV;
        inputPrice.leftViewMode = UITextFieldViewModeAlways;
        
        inputPrice.layer.cornerRadius = 8;
        inputPrice.layer.masksToBounds = YES;
        
        [inputPrice addTarget:self action:@selector(editPrice) forControlEvents:UIControlEventEditingChanged];
        [mainView addSubview:inputPrice];
        inputPrice.frame = CGRectMake(otherPrice.right, otherPrice.top, 87, 24);
        
        if (![PublicObj checkNull:[CachePostVideo sharedManager].otherPrice]) {
            inputPrice.text = [CachePostVideo sharedManager].otherPrice;
        }
        
        
//        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [mainView addSubview:cancelBtn];
//        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
//        cancelBtn.frame = CGRectMake(15, 230, ((mainView.frame.size.width- 45)/2), 36);
//        cancelBtn.layer.cornerRadius = 18;
//        cancelBtn.layer.masksToBounds = YES;
//        
//        [cancelBtn setTitle:YZMsg(@"public_cancel") forState:UIControlStateNormal];
//        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [cancelBtn setBackgroundColor:RGB(166, 166, 166)];
//        [cancelBtn addTarget:strongSelf action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mainView addSubview:confirmBtn];
        confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        confirmBtn.frame = CGRectMake(20, 230, (mainView.frame.size.width-40), 36);
        confirmBtn.layer.cornerRadius = 18;
        confirmBtn.layer.masksToBounds = YES;
        
        [confirmBtn setTitle:YZMsg(@"Livebroadcast_order_confirm") forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmBtn setBackgroundColor:RGB(224, 93, 183)];
        [confirmBtn addTarget:strongSelf action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];

        
        confirmBtn.bottom = ( _window_width * 0.8)-15;
        
        
        mainView.layer.cornerRadius = 10;
        mainView.layer.masksToBounds = YES;
        return mainView;
    })
    .wStart();
    
   

}

-(void)choiseMoneyButton:(UIButton*)button
{
    UIButton *buttonFree = [button.superview viewWithTag:1000];
//    UIButton *buttonTicket = [button.superview viewWithTag:1];
    
    if (button.tag == 1000) {
        //free
        for (UIView *subV in button.superview.subviews) {
            if ([subV isKindOfClass:[UIButton class]] && subV.tag > 1000) {
                ((UIButton*)subV).selected = NO;
            }
        }
        buttonFree.selected = YES;
//        buttonTicket.selected = NO;
        //[CachePostVideo sharedManager].coin_cost = button.selected ? @"0" : nil;
        //[CachePostVideo sharedManager].ticket_cost = nil;
        [CachePostVideo sharedManager].ticket_cost = @"1";
        [CachePostVideo sharedManager].coin_cost = nil;
    }
    else {
        NSInteger tagPriceValue = button.tag-1000;
        for (UIView *subV in button.superview.subviews) {
            if ([subV isKindOfClass:[UIButton class]] && subV.tag > 1000) {
                ((UIButton*)subV).selected = NO;
            }
        }
        buttonFree.selected = tagPriceValue == 0;
        button.selected = YES;
        [CachePostVideo sharedManager].ticket_cost = @"0";
        [CachePostVideo sharedManager].coin_cost = minnum(tagPriceValue);
        [CachePostVideo sharedManager].coin_last = [NSString toAmount:minnum(tagPriceValue)].toRate;
    }
    [self displayShowPrice];
}

-(void)editPrice{
    NSString* priceEdit = editPriceTextField.text;
    [CachePostVideo sharedManager].coin_last = priceEdit;
    [CachePostVideo sharedManager].otherPrice = priceEdit;
    
    priceEdit = [YBToolClass getRmbCurrency:priceEdit];
    for (UIView *subV in editPriceTextField.superview.subviews) {
        if ([subV isKindOfClass:[UIButton class]] && subV.tag > 1000) {
            ((UIButton*)subV).selected = NO;
        } else if([subV isKindOfClass:[UIButton class]] && subV.tag == 1000) {
            ((UIButton*)subV).selected = [priceEdit isEqualToString:@"0"];
        }
    }
    [CachePostVideo sharedManager].ticket_cost = @"0";
    [CachePostVideo sharedManager].coin_cost = priceEdit;
    [self displayShowPrice];
}

-(void)closeAction:(UIButton*)button
{
    [myAlert closeView];
    [self displayShowPrice];
    
}

-(void)confirmAction:(UIButton*)button
{
    is_confirm = YES;
    [myAlert closeView];
    [self displayShowPrice];
}

-(void)displayShowPrice
{
    NSString *stringPrice = @"";
    //显示
    if (![PublicObj checkNull:[CachePostVideo sharedManager].coin_cost] && [CachePostVideo sharedManager].coin_cost.length>0) {
        stringPrice = [CachePostVideo sharedManager].coin_last.toUnit;
        [CachePostVideo sharedManager].ticket_cost = @"0"; // 外部的免费改为观影券X1
    }else{
        stringPrice = [stringPrice stringByAppendingFormat:@"%@",YZMsg(@"post_video_free")];
        [CachePostVideo sharedManager].ticket_cost = @"1"; // 外部的免费改为观影券X1
    }
    
    
    self.displayPriceLabel.text = stringPrice;
    self.displayPriceLabel.userInteractionEnabled = YES;
    self.displayPriceLabel.textColor = RGB(224, 93, 183);
    [self.displayPriceLabel sizeToFit];
    [self.displayPriceLabel vk_addTapAction:self selector:@selector(showChoisePriceView)];
    
    
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [CachePostVideo sharedManager].video_title = textView.text;
}
@end
