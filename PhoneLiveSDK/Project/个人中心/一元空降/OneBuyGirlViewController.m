//
//  OneBuyGirlViewController.m
//  phonelive2
//
//  Created by 400 on 2022/6/12.
//  Copyright © 2022 toby. All rights reserved.
//

#import "OneBuyGirlViewController.h"
#import "OneBuyViewController.h"
#import "UIImageView+WebCache.h"
#import "OneBuyHistoryViewController.h"
#import "NavWeb.h"
#import "UINavModalWebView.h"
@interface OneBuyGirlViewController ()
{
    NSInteger numberPrice ;
    NSString *end_time;
    dispatch_source_t timer;
    NSString *urlDes;
}
@property(nonatomic,strong)NSArray *priceArray;

@property (weak, nonatomic) IBOutlet UILabel *playDesLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleSub1;
@property (weak, nonatomic) IBOutlet UILabel *titleSub2;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *winLastPlayerLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentProgressLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPregressLabel1;

@property (weak, nonatomic) IBOutlet UILabel *minePrice;
@property (weak, nonatomic) IBOutlet UILabel *mineWinRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *pricePaidLabel;
@property (weak, nonatomic) IBOutlet UIImageView *winAvatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *coinNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *sureButton;

@end

@implementation OneBuyGirlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapDesPlay = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playDesAction)];
    self.playDesLabel.userInteractionEnabled = true;
    self.coinNameLabel.text = [common name_coin];
    [self.sureButton setTitle:[NSString stringWithFormat:@"投入%@",[common name_coin]] forState:UIControlStateNormal];
    [self.playDesLabel addGestureRecognizer:tapDesPlay];
    self.priceArray = @[@"1",@"2",@"3",@"4",@"5",@"10",@"50",@"100",@"200",@"300",@"400",@"500",@"1000"];
    numberPrice = 0;
    [self updatePriceNum];
    WeakSelf
    dispatch_queue_t queue = dispatch_get_main_queue();
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf updateOpenTime];
          
    });
    dispatch_resume(timer);
    [self getData];
    // Do any additional setup after loading the view from its nib.
}
-(void)getData{
    NSString *requestURLStr = @"User.getFuckActivityInfo";
    WeakSelf
    [[YBNetworking sharedManager]postNetworkWithUrl:requestURLStr withBaseDomian:YES andParameter:nil data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            if(![info isKindOfClass:[NSArray class]]|| [(NSArray*)info count]<=0){
                [MBProgressHUD showError:msg];
                return;
            }
            NSDictionary *obj = (NSDictionary*)info[0];
            int cur_period = [[obj objectForKey:@"cur_period"] intValue];
            strongSelf->end_time = [obj objectForKey:@"end_time"];
            NSString *last_win_user_account = [obj objectForKey:@"last_win_user_account"];
            int my_bet = [[obj objectForKey:@"my_bet"] intValue];
            float my_rate = [[obj objectForKey:@"my_rate"] floatValue];
            int need_bet = [[obj objectForKey:@"need_bet"] intValue];
            int total_bet = [[obj objectForKey:@"total_bet"] intValue];
            int user_count = [[obj objectForKey:@"user_count"] intValue];
            NSString *title = [NSString stringWithFormat:@"%@",[obj objectForKey:@"title"]];
            strongSelf.titleSub1.text = title;
            strongSelf->urlDes = [obj objectForKey:@"rule"];
            NSString *last_win_user_photo = [NSString stringWithFormat:@"%@",[obj objectForKey:@"last_win_user_photo"]];
            NSString *last_win_uid =[NSString stringWithFormat:@"%@",[obj objectForKey:@"last_win_uid"]];
            NSURL *imgUrl = [NSURL URLWithString:last_win_user_photo];
            if (imgUrl) {
                [strongSelf.winAvatarImgView sd_setImageWithURL:imgUrl];
            }
        
            strongSelf.titleSub2.text = [NSString stringWithFormat:@"第%d期 本期参与人数:%d人",cur_period,user_count];
            [strongSelf updateOpenTime];
            
            if ([last_win_uid isEqualToString:[Config getOwnID]]) {
                strongSelf.winLastPlayerLabel.text = @"恭喜中奖，请联系客服!";
                strongSelf.winLastPlayerLabel.textColor = [UIColor redColor];
            }else{
                strongSelf.winLastPlayerLabel.text = minstr(last_win_user_account);
                strongSelf.winLastPlayerLabel.textColor = [UIColor blackColor];
            }
            NSString *totalRateV = [NSString stringWithFormat:@"%.3f",(total_bet*1.0/need_bet*1.0*100.0)];
            strongSelf.currentProgressLabel.text = [NSString stringWithFormat:@"当前进度:%@%%",totalRateV];
            strongSelf.currentPregressLabel1.text = [NSString stringWithFormat:@"%d/%d%@",total_bet,need_bet,[common name_coin]];
            strongSelf.minePrice.text = [NSString stringWithFormat:@"%d",my_bet];
            strongSelf.mineWinRateLabel.text  = [NSString stringWithFormat:@"%.3f%%",my_rate*100];
        }else{
            [MBProgressHUD showError:msg];
        }
      
        
        
    } fail:^(NSError *error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [MBProgressHUD showError:error.localizedDescription];
    
        
    }];
}
-(void)updateOpenTime{
    if (end_time!= nil && end_time.length>0) {
        NSDate *date1 = [NSDate new];
        NSTimeInterval timeInv=[end_time doubleValue];
        NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:timeInv];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *cmps = [calendar components:type fromDate:date1 toDate:date2 options:0];
        self.timeLabel.text = [NSString stringWithFormat:@"开奖倒计时:%@%@%@%@%@%@",
                               (cmps.year>0?[NSString stringWithFormat:@"%ld年",(long)cmps.year]:@""),
                               (cmps.month>0?[NSString stringWithFormat:@"%ld月",(long)cmps.month]:@""),
                               (cmps.day>0?[NSString stringWithFormat:@"%ld天",(long)cmps.day]:@""),
                               (cmps.hour>0?[NSString stringWithFormat:@"%ld小时",(long)cmps.hour]:@""),
                               (cmps.minute>0?[NSString stringWithFormat:@"%ld分钟",(long)cmps.minute]:@""),
                               (cmps.second>0?[NSString stringWithFormat:@"%ld秒",(long)cmps.second]:@"")];
    }
}

-(void)updatePriceNum {
    self.pricePaidLabel.text = _priceArray[numberPrice];
}

//玩法介绍
-(void)playDesAction{
    if (urlDes!= nil && urlDes.length>0) {
        NSURL *url = [NSURL URLWithString:urlDes];
        if (url) {
            NavWeb *VC = [[NavWeb alloc]init];
            VC.titles = @"玩法说明";

            VC.urls = urlDes;
            UINavModalWebView * navController = [[UINavModalWebView alloc] initWithRootViewController:VC];
            if (@available(iOS 13.0, *)) {
                navController.modalPresentationStyle = UIModalPresentationAutomatic;
            } else {
                navController.modalPresentationStyle = UIModalPresentationFullScreen;
            }
            VC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:YZMsg(@"public_back") style:UIBarButtonItemStylePlain target:self action:@selector(closeService:)];
            VC.navigationItem.title = @"";

            if ([[MXBADelegate sharedAppDelegate] topViewController].presentedViewController != nil)
            {
                [[[MXBADelegate sharedAppDelegate] topViewController] dismissViewControllerAnimated:false completion:nil];
            }
            if ([[MXBADelegate sharedAppDelegate] topViewController].presentedViewController==nil) {
                [[[MXBADelegate sharedAppDelegate] topViewController] presentViewController:navController animated:true completion:nil];
            }
        }
       
    }
    
}

- (IBAction)navigationBack:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)cutPrice:(id)sender {
    if (numberPrice<=0) {
        numberPrice = (self.priceArray.count-1);
    }else{
        numberPrice--;
    }
    [self updatePriceNum];
}

- (IBAction)addPrice:(id)sender {
    if (numberPrice>=self.priceArray.count-1) {
        numberPrice = 0;
    }else{
        numberPrice++;
    }
    [self updatePriceNum];
    
}
- (IBAction)surePay:(id)sender {
    NSString *requestURLStr = @"User.fuckActivityBet";
    
    WeakSelf
    [[YBNetworking sharedManager]postNetworkWithUrl:requestURLStr withBaseDomian:YES andParameter:@{@"bet_coin":self.pricePaidLabel.text} data:nil success:^(int code, NSArray *info, NSString *msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            [strongSelf getData];
            if (msg==nil && (msg!= nil && msg.length>0)) {
                [MBProgressHUD showSuccess:@"投注成功"];
            }else{
                [MBProgressHUD showError:msg];
            }
            
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError *error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [MBProgressHUD showError:error.localizedDescription];
    
        
    }];
    
}

- (IBAction)historyCurrent:(id)sender {
    OneBuyViewController *oneHistroy = [[OneBuyViewController alloc]initWithNibName:@"OneBuyViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    [[MXBADelegate sharedAppDelegate] pushViewController:oneHistroy animated:YES];
}
- (IBAction)winHistory:(id)sender {
    OneBuyHistoryViewController *oneHistroy = [[OneBuyHistoryViewController alloc]initWithNibName:@"OneBuyHistoryViewController" bundle:[XBundle currentXibBundleWithResourceName:@""]];
    [[MXBADelegate sharedAppDelegate] pushViewController:oneHistroy animated:YES];
}

@end
