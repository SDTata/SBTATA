//
//  ChipSwitchViewController.m
//
//

#import "ChipSwitchViewController.h"
#import "PayViewController.h"
#import "WMZDialog.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


@interface ChipSwitchViewController (){
    BOOL bUICreated; // UI是否创建
    NSMutableArray *allChipBtnArray;
    NSMutableArray *allChipLabelArray;
    NSMutableArray *allChipNumArray;
    NSInteger iLastSelectIndex;
    WMZDialog *myAlert;//Dialog
    
    UITextField *alertTextField;
    NSInteger customChipNum;
}

@property (weak, nonatomic) IBOutlet UILabel *chipSwitchTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *changeChipLabel;

@end

@implementation ChipSwitchViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = YES;
}
- (void)viewDidAppear:(BOOL)animated{
    [self getInfo];
}
- (void)viewWillDisappear:(BOOL)animated{
}

- (void)getInfo{
//    return;
    [self refreshUI];
}

-(void)refreshUI{
    if(!bUICreated){
        [self initUI];
    }
    
//    // 刷新彩种名字
//    self.lotteryName.text = allData[@"name"];
//    // 刷新彩种logo
//    self.logo.contentMode = UIViewContentModeScaleAspectFit;
//    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:minstr(allData[@"logo"])] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//        if (image) {
//            [self.logo setImage:image];
//        }
//    }];
//
//    // 更新倒计时时间
//    betLeftTime = [allData[@"time"] integerValue];
//    if(betLeftTime > 0){
//        self.leftTimeTitleLabel.text = @"本期截止:";
//        self.leftTimeLabel.text = [self timeFormatted:betLeftTime];
//    }
//
//    // 更新余额
//    self.leftCoinLabel.text = allData[@"left_coin"];
    
}

-(void)initUI{
    bUICreated = true;
    allChipNumArray = [NSMutableArray arrayWithArray:@[
        @2,
        @5,
        @10,
        @50,
        @100,
        @200,
        @500
    ]];
    allChipBtnArray = [NSMutableArray arrayWithArray:@[
        self.chip1Btn,
        self.chip2Btn,
        self.chip3Btn,
        self.chip4Btn,
        self.chip5Btn,
        self.chip6Btn,
        self.chip7Btn,
        self.chipCustomBtn
    ]];
    allChipLabelArray = [NSMutableArray arrayWithArray:@[
        self.chip1Label,
        self.chip2Label,
        self.chip3Label,
        self.chip4Label,
        self.chip5Label,
        self.chip6Label,
        self.chip7Label,
        self.chip8Label
    ]];
    // TODO ？？？ 取出来值就不对了
    NSInteger chipIdx = [common getChipIndex];
    customChipNum = [common getCustomChipNum];
    if(!customChipNum){
        customChipNum = 3;
    }
    
    for (int i = 0; i < allChipBtnArray.count; i++) {
        UIButton *btn = [allChipBtnArray objectAtIndex:i];
        UILabel *label = [allChipLabelArray objectAtIndex:i];
        [btn setTag:i];
        [btn addTarget:self action:@selector(doSelectChip:) forControlEvents:UIControlEventTouchUpInside];
        if(i != 7){
            label.text = [NSString stringWithFormat:@"%ld", (long)[[allChipNumArray objectAtIndex:i] integerValue]];
        } else {
            label.text = [NSString stringWithFormat:@"%ld", (long)customChipNum];
            label.adjustsFontSizeToFitWidth = YES;
        }
        if(chipIdx == i){
            btn.layer.borderWidth = 1;
            self.curSelectLabel.bottom = btn.bottom - 8;
            self.curSelectLabel.centerX = btn.centerX;
            if(btn.tag == 7){
                self.curSelectLabel.text = @"";
            }else{
                self.curSelectLabel.text = YZMsg(@"ChipSwitch_currentChip_title");
            }
        }else{
            btn.layer.borderWidth = 0;
        }
    }
    
    [self.chipConfirmBtn addTarget:self action:@selector(doConfirm) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)doSelectChip:(UIButton *)sender{
    NSInteger maxCount = allChipBtnArray.count;
    
    for (int i = 0; i < maxCount; i ++) {
        UIButton *btn = allChipBtnArray[i];
        if(i == sender.tag){
            btn.layer.borderWidth = 1;
        }else{
            btn.layer.borderWidth = 0;
        }
    }
    
    if(iLastSelectIndex == sender.tag){
        if(sender.tag == 7){
            [self doCustomChip];
        }else{
            [common saveChipNums:[allChipNumArray[sender.tag] integerValue]];
            [common saveChipIndex:sender.tag];
        }
    }
    iLastSelectIndex = sender.tag;
}
-(void)doCustomChip{
    WeakSelf
    myAlert = Dialog()
    .wTypeSet(DialogTypeMyView)
    //关闭事件 此时要置为不然会内存泄漏
    .wEventCloseSet(^(id anyID, id otherData) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->myAlert = nil;
    })
    .wWidthSet(_window_width * 0.8)
    .wMainOffsetYSet(0)
    .wShowAnimationSet(AninatonZoomIn)
    .wHideAnimationSet(AninatonZoomOut)
    .wAnimationDurtionSet(0.25)
    .wMyDiaLogViewSet(^UIView *(UIView *mainView) {
        STRONGSELF
        
        UILabel *title = [UILabel new];
        title.font = [UIFont systemFontOfSize:15.0f];
        title.text = YZMsg(@"ChipSwitch_input_custom_chip");
        
        title.frame = CGRectMake(0, 0, mainView.frame.size.width, 30);
        [title setTextAlignment:NSTextAlignmentCenter];
        [mainView addSubview:title];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(mainView.frame.size.width/3*1/2, 50, mainView.frame.size.width/3*2, 30)];
        textField.placeholder = [NSString stringWithFormat:@"%@2-50000",YZMsg(@"LobbyBet_RangeBetMoney")];
        textField.font = [UIFont systemFontOfSize:15.0f];
        textField.keyboardType = UIKeyboardTypeNumberPad;
        [textField setTextAlignment:NSTextAlignmentCenter];
        [mainView addSubview:textField];
        strongSelf->alertTextField = textField;
        
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mainView addSubview:cancelBtn];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        cancelBtn.frame = CGRectMake(0, 80+30, mainView.frame.size.width/2, 40);
        [cancelBtn setTitle:YZMsg(@"public_back") forState:UIControlStateNormal];
        [cancelBtn setTitleColor:DialogColor(0x3333333) forState:UIControlStateNormal];
        cancelBtn.layer.borderColor = RGB(234, 234, 234).CGColor; //边框颜色
        cancelBtn.layer.borderWidth = 1; //边框的宽度
//        cancelBtn.layer.cornerRadius = 10;
        [cancelBtn addTarget:strongSelf action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [mainView addSubview:confirmBtn];
        confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        confirmBtn.frame = CGRectMake(mainView.frame.size.width/2, 80+30, mainView.frame.size.width/2, 40);
        [confirmBtn setTitle:YZMsg(@"publictool_sure") forState:UIControlStateNormal];
        [confirmBtn setTitleColor:DialogColor(0x3333333) forState:UIControlStateNormal];
        confirmBtn.layer.borderColor = RGB(234, 234, 234).CGColor; //边框颜色
        confirmBtn.layer.borderWidth = 1; //边框的宽度
//        confirmBtn.layer.cornerRadius = 10;
        [confirmBtn addTarget:strongSelf action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
//        confirmBtn.tag = sender.tag;
        
//        mainView.layer.masksToBounds = YES;
//        mainView.layer.cornerRadius = 10;
        
        cancelBtn.bottom =  CGRectGetMaxY(mainView.frame);
        confirmBtn.bottom =  CGRectGetMaxY(mainView.frame);
        return mainView;
    })
    .wStart();
}

-(void)closeAction:(UIButton*)sender{
    [myAlert closeView];
}

-(void)confirmAction:(UIButton*)sender{
    if ([alertTextField.text integerValue]<=1 || [alertTextField.text integerValue]>50000) {
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@2-50000",YZMsg(@"LobbyBet_RangeBetMoney")]];
        return;
    }
    
    [common saveCustomChipNum:[alertTextField.text integerValue]];
    [common saveChipNums:[alertTextField.text integerValue]];
    [common saveChipIndex:7];
    [myAlert closeView];
    
    UILabel *label = [allChipLabelArray objectAtIndex:7];
    label.adjustsFontSizeToFitWidth = YES;
    label.text = [NSString stringWithFormat:@"%ld",(long)[common getCustomChipNum]];
}

// 确认选择筹码
-(void)doConfirm{
    NSInteger maxCount = allChipBtnArray.count;
    for (int i = 0; i < maxCount; i ++) {
        UIButton *btn = allChipBtnArray[i];
        if(btn.layer.borderWidth == 1){
            [common saveChipIndex:i];
            if(i == 7){
                [common saveChipNums:[common getCustomChipNum]];
            }else{
                [common saveChipNums:[allChipNumArray[i] integerValue]];
            }
        }
    }
    
    if(self.block){
        self.block(0,0);
    }
}

-(void)doCharge:(UIButton *)sender{
    PayViewController *payView = [[PayViewController alloc]initWithNibName:@"PayViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    payView.titleStr = YZMsg(@"Bet_Charge_Title");
    [payView setHomeMode:false];
    [self.navigationController pushViewController:payView animated:YES];
}

//- (UIImage *)createImageWithColor:(UIColor *)color rect:(CGRect)rect radius:(float)radius {
//    //设置长宽
////    CGRect rect = rect;//CGRectMake(0.0f, 0.0f, 80.0f, 30.0f);
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [color CGColor]);
//    CGContextFillRect(context, rect);
//    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    UIImage *original = resultImage;
//    CGRect frame = CGRectMake(0, 0, original.size.width, original.size.height);
//    // 开始一个Image的上下文
//    UIGraphicsBeginImageContextWithOptions(original.size, NO, 1.0);
//    // 添加圆角
//    [[UIBezierPath bezierPathWithRoundedRect:frame
//                                cornerRadius:radius] addClip];
//    // 绘制图片
//    [original drawInRect:frame];
//    // 接受绘制成功的图片
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     *  适配 ios 7 和ios 8 的 坐标系问题
     */
    if (@available(iOS 11.0, *)) {
        
    }else{
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    self.chipSwitchTitleLabel.text = YZMsg(@"ChipSwitch_settitle");
    self.changeChipLabel.text = YZMsg(@"ChipSwitch_ChangeChip_title");
    [self.chipConfirmBtn setTitle:YZMsg(@"publictool_sure") forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
