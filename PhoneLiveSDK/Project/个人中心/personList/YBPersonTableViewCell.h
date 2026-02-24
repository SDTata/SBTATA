
#import <UIKit/UIKit.h>
@class YBPersonTableViewModel;

@protocol personInfoCellDelegate <NSObject>
- (void)pushExchangeRateAction;
- (void)refreshBannerData:(BOOL)hasData;
- (void)refreshWalletData;
@end

@interface YBPersonTableViewCell : UITableViewCell

@property(nonatomic,strong)YBPersonTableViewModel *model;
//跳页面代理
@property(nonatomic,assign)id<personInfoCellDelegate>personCellDelegate;
/**
 *  个人中心个人信息cell
 */

@property(nonatomic,strong) UIView *centerView;//用来居中名称，性别，等级,编辑图标

//头像视图
@property (nonatomic, weak) SDAnimatedImageView *iconView;

//背景
@property (nonatomic, strong) UIImageView *backImgView;

//背景
@property (nonatomic, strong) UIImageView *backImgView2;

//姓名
@property (nonatomic, weak) UILabel *nameLabel;
//性别
@property (nonatomic, weak) UIImageView *sexView;
//等级
@property (nonatomic, weak) UIImageView *levelView;
//主播等级
@property (nonatomic, weak) UIImageView *level_anchorView;
//编辑按钮
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UIButton *editBtn2;
//签名
@property (nonatomic, strong) UILabel *IDL;
//编辑
@property (nonatomic, strong) UIButton *btn_copy;


//底部view

//中心钱包标题
@property (nonatomic, strong) UILabel *walletCenterTitleLabel;
//中心钱包刷新按钮
@property (nonatomic, strong) UIButton *walletCenterRefreshBtn;
//汇率转换
@property (nonatomic, strong) UIButton *exchangeRateBtn;
//汇率转换
@property (nonatomic, strong) UILabel *exchangeRateLabel;
//余额标题
@property (nonatomic, strong) UILabel *leftCoinTitleLabel;
//余额
@property (nonatomic, strong) UILabel *leftCoinLabel;

//充值
@property (nonatomic, strong) UIButton *rechargeBtn;
//充值标题
@property (nonatomic, strong) UILabel *rechargeBtnTitle;
//额度转换
@property (nonatomic, strong) UIButton *exchangeBtn;
//额度转换标题
@property (nonatomic, strong) UILabel *exchangeBtnTitle;
//提现
@property (nonatomic, strong) UIButton *withdrawBtn;
//提现标题
@property (nonatomic, strong) UILabel *withdrawBtnTitle;

//分割线
@property (nonatomic, strong) UIView *line;
//站内信
@property (nonatomic, strong) UIButton *msgButton;
//是否有新消息
@property (nonatomic, strong) UILabel *unreadMsgLabel;

//设置
@property (nonatomic, strong) UIButton *setupBtn;
//编辑
@property (nonatomic, strong) UIButton *updateBtn;

@property(nonatomic,strong)NSDictionary *infoArray;//个人信息


+ (instancetype)cellWithTabelView:(UITableView *)tableView;
- (void)refreshVaule;
@end
