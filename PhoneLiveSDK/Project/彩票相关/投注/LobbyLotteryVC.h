//
//  LobbyLotteryVC.h
//  XLPageViewControllerExample
//
//  Created by MengXianLiang on 2019/5/14.
//  Copyright © 2019 xianliang meng. All rights reserved.
//  频道管理举例

#import <UIKit/UIKit.h>
#ifdef LIVE
#import "PhoneLive-Swift.h"
#else
#import <PhoneSDK/PhoneLive-Swift.h>
#endif
#import "EqualSpaceFlowLayoutEvolve.h"

NS_ASSUME_NONNULL_BEGIN

@interface LobbyLotteryVC : UIViewController

// 长链接start
@property(nonatomic,copy)NSString *lobbySocketServerUrl;
@property(nonatomic,strong)SocketIOClient *LobbySocket;
//@property(nonatomic,copy)NSDate * lastReconnectDate; //最后一次重连时间

// 长链接end

@property (weak, nonatomic) IBOutlet UIView *navBar;
@property (weak, nonatomic) IBOutlet UIView *lotterInfoView;
@property (weak, nonatomic) IBOutlet UIView *historyView;

@property (weak, nonatomic) IBOutlet UILabel *lotteryStatusLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *openResultCollection;
@property (weak, nonatomic) IBOutlet UILabel *leftCoinLabel;

@property (weak, nonatomic) IBOutlet UIView *chargeView;
//@property (weak, nonatomic) IBOutlet UIButton *chargeBtn;


@property (weak, nonatomic) IBOutlet UIButton *betHistoryIssueBtn;

// 顶部nav区域
@property (weak, nonatomic) IBOutlet UIButton *backBtn; // 返回
@property (weak, nonatomic) IBOutlet UIButton *moreBtn; // 更多功能
@property (weak, nonatomic) IBOutlet UIButton *lotteryHelpBtn;  // 彩种说明

// 跑马灯
@property (weak, nonatomic) IBOutlet UIView *marqueeView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *bottomMoreBtn; // 更多功能
@property (weak, nonatomic) IBOutlet UIButton *emptySelectedBtn; // 清空
@property (weak, nonatomic) IBOutlet UIButton *deviceRandomBtn; // 机选
@property (weak, nonatomic) IBOutlet UIButton *betHistoryBtn; // 投注记录

// vc标题
@property (weak, nonatomic) IBOutlet UILabel *viewTitleLabel;
// 当前期号
@property (weak, nonatomic) IBOutlet UILabel *curIssueLabel;
// 上期期号
@property (weak, nonatomic) IBOutlet UILabel *lastIssueLabel;


// 倒计时
@property (weak, nonatomic) IBOutlet UIView *countdownView; // 倒计时view

// 注单
@property (weak, nonatomic) IBOutlet UIView *lotteryCartView; // 注单view
@property (weak, nonatomic) IBOutlet UIImageView *lotteryLogo; // 当前彩种logo
@property (weak, nonatomic) IBOutlet UIView *redBallBgView; // 红点View
@property (weak, nonatomic) IBOutlet UILabel *totalBetCount; // 注单数量
@property (weak, nonatomic) IBOutlet UIView *ballBgView; // 彩种View
@property (weak, nonatomic) IBOutlet UILabel *totalMoney; // 注单金额
@property (weak, nonatomic) IBOutlet UILabel *totalPlanProfit; // 注单总注数 预期收益
@property (weak, nonatomic) IBOutlet UIButton *totalBetBtn; // 下注按钮

// 投注界面
@property (weak, nonatomic) IBOutlet UIView *betView; // 投注view
@property (weak, nonatomic) IBOutlet UIView *chipBgView; // 投注view
@property (weak, nonatomic) IBOutlet UITextField *customAmountTextField; // 自定义金额
@property (weak, nonatomic) IBOutlet UILabel *betDesc; // 投注描述文本（注单总注数 总投注 预期收益）
@property (weak, nonatomic) IBOutlet UIButton *chip1Btn;
@property (weak, nonatomic) IBOutlet UIButton *chip2Btn;
@property (weak, nonatomic) IBOutlet UIButton *chip3Btn;
@property (weak, nonatomic) IBOutlet UIButton *chip4Btn;
@property (weak, nonatomic) IBOutlet UIButton *chip5Btn;
@property (weak, nonatomic) IBOutlet UIButton *chip6Btn;
@property (weak, nonatomic) IBOutlet UIButton *chip7Btn;
@property (weak, nonatomic) IBOutlet UIButton *chipMinBtn; // 最小下注
@property (weak, nonatomic) IBOutlet UIButton *betBtn; // 下注按钮
@property (weak, nonatomic) IBOutlet UIButton *addToLotteryCartBtn; // 加入注单按钮
@property (weak, nonatomic) IBOutlet UIButton *betCancelBtn; // 取消按钮

@property (weak, nonatomic) IBOutlet UIImageView *historyListImgV;
@property (weak, nonatomic) IBOutlet UIImageView *gameImgeView;

@property(assign,nonatomic) NSInteger lotteryType;
@property(strong,nonatomic) NSString * urlName;

@property(strong,nonatomic) NSString * lotteryNameStr;

@end

NS_ASSUME_NONNULL_END
