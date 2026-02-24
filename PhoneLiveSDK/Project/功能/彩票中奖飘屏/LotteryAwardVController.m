//
//  LotteryAwardVController.m
//  phonelive
//
//  Created by 400 on 2020/8/2.
//  Copyright © 2020 toby. All rights reserved.
//

#import "LotteryAwardVController.h"

@interface LotteryAwardVController ()
{
    AVAudioPlayer *voiceAwardMoney;
    
}
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *closeTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *lotteryImgView;
@end

@implementation LotteryAwardVController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self playSoundEffect];
     self.view.backgroundColor = [UIColor clearColor];
    NSString *currencyCoin = [YBToolClass getRateCurrency:_model.content showUnit:YES];
    self.amountLabel.text = [NSString stringWithFormat:YZMsg(@"LotteryAwardVC%@%@"),currencyCoin,@""];
    self.lotteryImgView.image= [ImageBundle imagewithBundleName:YZMsg(@"LotteryAwardVC_lottery_reward_bgImg")];
    self.contentView.transform = CGAffineTransformMakeTranslation(0, SCREEN_HEIGHT);
    WeakSelf
    [UIView animateWithDuration:0.5 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        strongSelf.contentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
    
    __block int timeout=5; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_main_async_safe(^{
                strongSelf.closeTitleLabel.text = YZMsg(@"LotteryAwardVC_close");
                [strongSelf closeView];
            });

        }else{
            int seconds = timeout % 60;
//            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_main_async_safe((^{
                strongSelf.closeTitleLabel.text = [NSString stringWithFormat:@"%@(%ld)",YZMsg(@"LotteryAwardVC_close"),(long)seconds];
            }));

            timeout--;
        }

    });

    dispatch_resume(_timer);
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self closeView];
}

-(void)closeView
{
    WeakSelf
    [UIView animateWithDuration:0.5 animations:^{
        if (weakSelf!=nil) {
            weakSelf.view.backgroundColor = [UIColor clearColor];
            weakSelf.contentView.transform = CGAffineTransformMakeTranslation(0, SCREEN_HEIGHT);
        }
        
    } completion:^(BOOL finished) {
        if (weakSelf!=nil) {
            [weakSelf.view removeFromSuperview];
            [weakSelf removeFromParentViewController];
        }
        
    }];
}

- (void)playSoundEffect{
    
    if (!voiceAwardMoney) {
        NSURL *url=[[XBundle currentXibBundleWithResourceName:NSStringFromClass([self class])]URLForResource:@"reward_500.mp3" withExtension:Nil];
        voiceAwardMoney = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
    }
    [voiceAwardMoney prepareToPlay];
    [voiceAwardMoney play];
    UIImpactFeedbackGenerator *impactLight = [[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleMedium];
    [impactLight impactOccurred];

}
@end
