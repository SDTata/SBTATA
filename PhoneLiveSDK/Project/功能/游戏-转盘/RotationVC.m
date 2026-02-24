//
//

#import "RotationVC.h"
#import "Masonry.h"
#import "TYRotaryView.h"
#import "MJExtension.h"
#import "RotaionRecordVC.h"
#import "RotationDescVC.h"
#import "RotationModel.h"
#import "RotationResultVC.h"
#import "RotationNothingVC.h"
@interface RotationVC ()

@property (nonatomic, strong) TYRotaryView *rotaryView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (nonatomic, strong) RotationSubModel *currentPrizeModel;  //当前奖品
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constantY;
@property (weak, nonatomic) IBOutlet UIImageView *topTitleImgV; //奖池大派送标题
@property (weak, nonatomic) IBOutlet UIButton *jcsyjjButton;
@property (weak, nonatomic) IBOutlet UILabel *sycsLabel;
@property (weak, nonatomic) IBOutlet UITextView *textViewBottom;



@property (weak, nonatomic) IBOutlet UIButton *giftRecordButton;
@property (weak, nonatomic) IBOutlet UIButton *giftRuleButton;

@property (weak, nonatomic) IBOutlet UILabel *GiftPoolTitleLabel;


@property(nonatomic,assign)BOOL isRunning;

@property(nonatomic,strong)RotationModel *resultModel;
@end

@implementation RotationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    // Do any additional setup after loading the view, typically from a nib.

    [self setupUI];
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:recognizer];
    
    [self.giftRecordButton setBackgroundImage:[ImageBundle imagewithBundleName:YZMsg(@"RotationVC_giftRecordButton")] forState:UIControlStateNormal];
    [self.giftRuleButton setBackgroundImage:[ImageBundle imagewithBundleName:YZMsg(@"RotationVC_giftRuleButton")] forState:UIControlStateNormal];
    
    self.topTitleImgV.image = [ImageBundle imagewithBundleName:YZMsg(@"RotationVC_topTitleImgV")];
    self.GiftPoolTitleLabel.text = YZMsg(@"RotationVC_giftPoolTitle");

}
/** 平移手势响应事件  */
- (void)handlePan:(UIPanGestureRecognizer *)swipe {
    if (swipe.state == UIGestureRecognizerStateChanged) {
        [self commitTranslation:[swipe translationInView:self.view]];
    }else if(swipe.state == UIGestureRecognizerStateEnded){
        if (self.constantY.constant>SCREEN_HEIGHT/4.0) {
            [self dismiss];
        }else{
            [UIView animateWithDuration:0.25 animations:^{
                self.constantY.constant = 0;
                [self.view layoutIfNeeded];
            }];
        }
    }
}

/** 判断手势方向  */
- (void)commitTranslation:(CGPoint)translation {
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    // 设置滑动有效距离
    if (MAX(absX, absY) < 10)
        return;
    if (absX > absY ) {
        if (translation.x<0) {//向左滑动
        }else{//向右滑动
        }
    } else if (absY > absX) {
        if (translation.y<0) {//向上滑动
        }else{ //向下滑动
//            [self dismiss];
            self.constantY.constant = translation.y;
            
        }
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches.allObjects lastObject];
    BOOL result = [touch.view isDescendantOfView:self.bgView];
    if (!result) {
        [self dismiss];
    }
   
}
-(void)dismiss{
    if (self.isRunning) {
        return;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)setupUI{
    
    self.rotaryView = [TYRotaryView new];
    __weak typeof(self) weakself = self;
    self.rotaryView.rotaryStartTurnBlock = ^{
        NSLog(@"开始旋转");
        [weakself starToLottery];
    };
    
    self.rotaryView.rotaryEndTurnBlock = ^{
        NSLog(@"旋转结束");
        weakself.isRunning = false;
        //抽奖结束 次数减一
        [weakself handleEndRollAction];
    };
    [self.bgView addSubview:self.rotaryView];
    [self.bgView addSubview:self.topTitleImgV];
    [self.rotaryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(KPaddingR+4);
        make.right.mas_offset(-KPaddingR);
        make.height.mas_equalTo(self.rotaryView.mas_width);
        make.top.mas_equalTo(127.5);
    }];
    [self getViewInformation];
}
-(void)getViewInformation {
    NSString *userBaseUrl = @"Live.getLuckydraw";
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow  animated:YES];
   WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:@{@"liveuid":self.liveUid}  data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        if (code == 0 && info.count>0) {
            if(![info isKindOfClass:[NSArray class]] || [(NSArray*)info count]<=0){
                [MBProgressHUD showError:msg];
                return;
            }
            strongSelf.resultModel = [RotationModel mj_objectWithKeyValues:info[0]];
            if (strongSelf.resultModel.reward.count==10) {
                [strongSelf.rotaryView loadLottery:strongSelf.resultModel.reward];
            }
            if(strongSelf.resultModel.process_tip && strongSelf.resultModel.process_tip.length>0){
                NSAttributedString * attStr = [[NSAttributedString alloc] initWithData:[strongSelf.resultModel.process_tip dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                strongSelf.textViewBottom.attributedText = attStr;
            }
           
            [strongSelf.jcsyjjButton setTitle:strongSelf.resultModel.pool forState:UIControlStateNormal];
            strongSelf.sycsLabel.text = [NSString stringWithFormat:@"%@%d",YZMsg(@"RotationVC_remaining_lottery_times"),strongSelf.resultModel.left_times];
        }else{
           
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError *error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    }];
}
-(void)handleEndRollAction{
    //抽奖次数减1
    [self.jcsyjjButton setTitle:self.resultModel.pool forState:UIControlStateNormal];
    self.sycsLabel.text = [NSString stringWithFormat:@"%@%d",YZMsg(@"RotationVC_remaining_lottery_times"),self.resultModel.left_times];
    if ([self.currentPrizeModel.item_type isEqualToString:@"nothing"]) {
        RotationNothingVC *resultNothiVC = [[RotationNothingVC alloc]initWithNibName:@"RotationNothingVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        resultNothiVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:resultNothiVC animated:NO completion:nil];
    }else{
        RotationResultVC *resultVC = [[RotationResultVC alloc]initWithNibName:@"RotationResultVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
        resultVC.model = self.currentPrizeModel;
        resultVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:resultVC animated:NO completion:nil];
    }
}

-(void)starToLottery{
    // 測試用
//    self.currentPrizeModel = [self.resultModel.reward objectAtIndex:8];
//    [self.rotaryView animationWithSelectonIndex:8];
//    return;
    //判断用户是否可以抽奖
    
    //禁用按钮
//    self.rotaryView.startButton.userInteractionEnabled = NO;
    
    //发起网络请求获取当前选中奖品 由于这里需要发起网络请求(真实环境)，这里就通过随机的方式获取一次index
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: [UIApplication sharedApplication].keyWindow  animated:YES];
    NSString *userBaseUrl = @"Live.doLuckydraw";
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        if (code == 0 && info.count>0) {
            if(![info isKindOfClass:[NSArray class]] || [(NSArray*)info count]<=0){
                [MBProgressHUD showError:msg];
                return;
            }
            NSDictionary *resulDic = info[0];
            strongSelf.resultModel.left_times = [resulDic[@"left_times"] intValue];
            strongSelf.resultModel.pool = resulDic[@"luckydraw_money_pool"];
            NSDictionary *rewardDic = resulDic[@"reward"];
            NSString *rewardId = rewardDic[@"id"];
            if (rewardId) {
                int indexSel = 0;
                for (int i = 0; i<strongSelf.resultModel.reward.count; i++) {
                    RotationSubModel *subModel = strongSelf.resultModel.reward[i];
                    if ([subModel.ID isEqualToString:rewardId]) {
                        indexSel = i;
                        break;
                    }
                }
                strongSelf.currentPrizeModel = [self.resultModel.reward objectAtIndex:indexSel];
                //让转盘转起来
                strongSelf.isRunning = true;
                [strongSelf.rotaryView animationWithSelectonIndex:indexSel];
            }
        }else{
            strongSelf.isRunning = false;
            [MBProgressHUD showError:msg];
        }
        
    } fail:^(NSError *error) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:error.localizedDescription];
    }];
    //清理请求结束之后使能按钮
    //    self.rotaryView.startButton.userInteractionEnabled = NO;

    //拿到当前奖品的 找到其对于的位置
   
}
- (IBAction)recordAction:(id)sender {
    RotaionRecordVC *rotationVC = [[RotaionRecordVC alloc]initWithNibName:@"RotaionRecordVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
//    rotationVC.liveUid = strongSelf.playDocModel.zhuboID;
    rotationVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:rotationVC animated:NO completion:nil];
}
- (IBAction)descAction:(id)sender {
    RotationDescVC *rotationVC = [[RotationDescVC alloc]initWithNibName:@"RotationDescVC" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    rotationVC.ruleStr = self.resultModel.rule;
    rotationVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:rotationVC animated:NO completion:nil];
}

@end
