//
//  YBPersonTableViewCell.m
//  TCLVBIMDemo
//
//  Created by admin on 16/11/11.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "YBPersonTableViewCell.h"
#import "fansViewController.h"
#import "UIView+Additions.h"
//底部View
#import "YBBottomView.h"
#import "YBPersonTableViewModel.h"
#import "LiveNodeViewController.h"
#import "UIImageView+WebCache.h"
#import "MsgSysVC.h"
#import "MessageListNetworkUtil.h"
#import "YBUserInfoManager.h"
#import <UMCommon/UMCommon.h>

@interface YBPersonTableViewCell ()
{
    //名字宽度
    CGSize nameLabelWidth;
    UIFont *font1;//ID字体
    MASConstraint *cos;
    UIView *middleView;
    NSInteger systemUnreadCount; // 系统消息 未读数量
    NSInteger interactiveUnreadCount; // 互动消息 未读数量
}
//底部view
@property (nonatomic, strong) YBBottomView *bottomView;
@end
@implementation YBPersonTableViewCell
//-(void)drawRect:(CGRect)rect{
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextSetLineWidth(ctx,10);
//    CGContextSetStrokeColorWithColor(ctx,[UIColor colorWithRed:255255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor);
//    CGContextMoveToPoint(ctx,0,190);
//    CGContextAddLineToPoint(ctx,(self.frame.size.width),190);
//    CGContextStrokePath(ctx);
//}
-(void)perform:(NSString *)text{
    if ([text rangeOfString:YZMsg(@"homepageController_live")].location != NSNotFound) {
        
        [[YBUserInfoManager sharedManager] pushLiveNodeList];
        
    }else if ([text rangeOfString:YZMsg(@"public_fans")].location != NSNotFound){
        
        [[YBUserInfoManager sharedManager] pushFansList];
        
    }else if ([text rangeOfString:YZMsg(@"homepageController_attention")].location != NSNotFound){
        
        [[YBUserInfoManager sharedManager] pushAttentionList];
        
    }
}
-(void)setModel:(YBPersonTableViewModel *)model{
    _model = model;
    _nameLabel.text = _model.user_nicename;
    //    CGSize sizes= [_nameLabel.text boundingRectWithSize:CGSizeMake(90, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:fontThin(14)} context:nil].size;
    
    //    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
    //        {
    //            make.left.mas_equalTo(self.iconView.mas_right).offset(10);
    //            make.top.equalTo(self.iconView.mas_top).offset(20);
    //            make.height.mas_equalTo(20);
    //
    //            if (IS_IPHONE_5) {
    //                make.width.mas_equalTo(sizes.width);
    //            }
    //        }
    //    }];
    NSString *laingname = minstr([Config getliang]);
    if (![PublicObj checkNull:laingname] && [laingname isEqualToString:@"0"]) {
        _IDL.text = [NSString stringWithFormat:@"ID:%@",_model.ID];
    }
    else{
        if (![PublicObj checkNull:laingname]) {
            _IDL.text = [NSString stringWithFormat:@"%@:%@",YZMsg(@"public_liang"),laingname];
        }else{
            _IDL.text = @"";
        }
    }
    NSString *strID = _IDL.text;
    NSMutableAttributedString *attruID = [[NSMutableAttributedString alloc]initWithString:strID];
    _IDL.attributedText = attruID;
    
    
    if ([minstr(_model.sex) isEqualToString:@"1"]) {
        _sexView.backgroundColor = RGB_COLOR(@"#796dff", 1);
        [_sexView setImage:[ImageBundle imagewithBundleName:@"profile_sex_man"]];
    }
    else{
        _sexView.backgroundColor = RGB_COLOR(@"#fa7d99", 1);
        [_sexView setImage:[ImageBundle imagewithBundleName:@"profile_sex_woman"]];
    }
    //    [_levelView setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"leve%@",_model.level]]];
    //    [_level_anchorView setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"host_%@",_model.level_anchor]]];
    [_iconView sd_setImageWithURL:[NSURL URLWithString:_model.avatar] placeholderImage:[ImageBundle imagewithBundleName:@"profile_accountImg"]];
    //    [self.bottomView setAgain:@[_model.lives,_model.follows,_model.fans]];
    
}
+ (instancetype)cellWithTabelView:(UITableView *)tableView{
    static NSString *cellIdentifier = @"YBPersonTableViewCell";
    YBPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[YBPersonTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setupView];
        [self layoutUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
//MARK:-设置控件
-(void)setupView
{
    // 设置
    UIButton *setupBtn = [[UIButton alloc]init];
    [setupBtn setImage:[ImageBundle imagewithBundleName:@"profile_setting"] forState:UIControlStateNormal];
    [setupBtn addTarget:self action:@selector(doSetup) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:setupBtn];
    self.setupBtn = setupBtn;
    [self.setupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(8);
        make.trailing.mas_equalTo(self.contentView).inset(15);
        make.size.mas_equalTo(24);
    }];

    ///站内信
    UIButton *msgsBtn = [[UIButton alloc]init];
    [msgsBtn setImage:[ImageBundle imagewithBundleName:@"profile_mail"] forState:UIControlStateNormal];
    [msgsBtn addTarget:self action:@selector(doMsgAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:msgsBtn];
    self.msgButton = msgsBtn;
    [self.msgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.setupBtn.mas_top);
        make.trailing.equalTo(setupBtn.mas_leading).inset(20);
        make.size.mas_equalTo(24);
    }];

    UILabel *msgsUnreadLabel = [[UILabel alloc]init];
    msgsUnreadLabel.textColor = [UIColor whiteColor];
    msgsUnreadLabel.textAlignment = NSTextAlignmentCenter;
    msgsUnreadLabel.layer.cornerRadius = 9;
    msgsUnreadLabel.layer.masksToBounds = YES;
    msgsUnreadLabel.font = [UIFont systemFontOfSize: 8];
    msgsUnreadLabel.backgroundColor = UIColor.systemRedColor;
    [self.contentView addSubview:msgsUnreadLabel];
    msgsUnreadLabel.hidden = YES;
    self.unreadMsgLabel = msgsUnreadLabel;
    [self.unreadMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(msgsBtn.mas_top).offset(2);
        make.centerX.mas_equalTo(msgsBtn.mas_trailing).inset(2);
        make.size.mas_equalTo(18);
    }];

    //头像
    SDAnimatedImageView *iconView = [[SDAnimatedImageView alloc]init];
    //    iconView.frame = CGRectMake(0,0,80,80);
    [iconView setClipsToBounds:YES];
    iconView.contentMode = UIViewContentModeScaleAspectFill;
    iconView.layer.masksToBounds = YES;
    iconView.layer.cornerRadius = 33;
//    iconView.layer.borderWidth = 3;
//    iconView.layer.borderColor = UIColor.whiteColor.CGColor;
//    iconView.layer.shadowColor = [UIColor blackColor].CGColor;
//    iconView.layer.shadowOpacity = 0.2;
//    iconView.layer.shadowRadius = 3;
    [iconView vk_addTapAction:self selector:@selector(doEdit)];
    [iconView sizeToFit];
    self.iconView = iconView;
    [self.contentView addSubview:iconView];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = UIColor.clearColor;//RGB_COLOR(@"#f2f2f6", 1);
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(66);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(19);
        make.top.mas_equalTo(self.setupBtn.mas_bottom);
    }];
    
    //姓名
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.textColor = vkColorRGBA(0, 0, 0, 0.7);
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    //显示数据类型的连接模式（如电话号码、网址、地址等）;
    self.nameLabel = nameLabel;
    [self.contentView addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.iconView.mas_trailing).offset(13);
        make.top.equalTo(self.iconView.mas_top).offset(2);
        make.height.equalTo(@20);
    }];
    
    //性别
    UIImageView *sexView = [[UIImageView alloc]init];
    [sexView setClipsToBounds:YES];
    [sexView setContentMode:UIViewContentModeScaleAspectFit];
    sexView.layer.cornerRadius = 10;
    sexView.layer.masksToBounds = YES;
    [self.contentView addSubview:sexView];
    self.sexView = sexView;
    [sexView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(nameLabel);
        make.top.equalTo(nameLabel.mas_bottom).offset(7);
        make.size.mas_equalTo(20);
    }];
    
    
    UIImageView *levelViewhost = [[UIImageView alloc]init];
    [levelViewhost setClipsToBounds:YES];
    [levelViewhost setContentMode:UIViewContentModeScaleAspectFit];
    [self.contentView addSubview:levelViewhost];
    self.level_anchorView = levelViewhost;
    [self.level_anchorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.sexView.mas_trailing).offset(10);
        make.centerY.mas_equalTo(self.sexView);
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(20);
    }];
    
    //等级
    UIImageView *levelView = [[UIImageView alloc]init];
    [levelView setClipsToBounds:YES];
    [levelView setContentMode:UIViewContentModeScaleAspectFit];
    [self.contentView addSubview:levelView];
    self.levelView = levelView;
    
    [levelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.level_anchorView.mas_trailing).offset(10);
        make.centerY.mas_equalTo(self.sexView);
        make.width.mas_equalTo(38);
        make.height.mas_equalTo(20);
    }];

    //编辑按钮
    UIButton *editBtn = [[UIButton alloc]init];
    [editBtn setImage:[ImageBundle imagewithBundleName:@"wd_tx_jt"] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(doEdit) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:editBtn];
    editBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    self.editBtn = editBtn;
    [editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameLabel.mas_right).offset(-10);
        make.centerY.equalTo(nameLabel);
        make.right.lessThanOrEqualTo(msgsBtn.mas_left).offset(-3);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
    
    //ID
    UILabel *ID = [UILabel new];
    ID.backgroundColor = [UIColor clearColor];
    ID.textAlignment = NSTextAlignmentCenter;
    ID.textColor = RGB_COLOR(@"#000000", 0.7);
    ID.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.0];
    [self.contentView addSubview:ID];
    self.IDL = ID;
    [ID mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sexView.mas_bottom).offset(10);
        make.leading.equalTo(sexView);
    }];

    UIButton *editBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [editBtn2 setBackgroundColor:[UIColor clearColor]];
    [editBtn2 addTarget:self action:@selector(doEdit) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:editBtn2];
    self.editBtn2 = editBtn2;
    [editBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.iconView.mas_top);
        make.left.mas_equalTo(self.iconView.mas_right);
        make.right.mas_equalTo(self.editBtn.mas_right);
        make.bottom.mas_equalTo(self.IDL.mas_top);
    }];

    UIButton *copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [copyButton setImage:[ImageBundle imagewithBundleName:@"profile_copy"] forState:UIControlStateNormal];
    [copyButton addTarget:self action:@selector(copyID) forControlEvents:UIControlEventTouchUpInside];
    copyButton.titleLabel.font = [UIFont systemFontOfSize:11];
    copyButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    copyButton.titleLabel.minimumScaleFactor = 0.3;
    [self.contentView addSubview:copyButton];
    self.btn_copy = copyButton;
    [copyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(ID);
        make.leading.mas_equalTo(ID.mas_trailing).offset(10);
        make.size.mas_equalTo(16);
    }];

    // 切換幣種
    UIView *changeCoinView = [UIView new];
    changeCoinView.backgroundColor = RGB_COLOR(@"#c0a9ff", 1);
    changeCoinView.layer.cornerRadius = 12;
    changeCoinView.layer.masksToBounds = YES;
    [self.contentView addSubview:changeCoinView];
    [changeCoinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-15);
        make.top.equalTo(ID.mas_bottom).offset(26);
        make.height.equalTo(@24);
    }];

    // 钱包刷新按钮
    UIButton *walletCenterRefreshBtn = [[UIButton alloc] init];
    walletCenterRefreshBtn.backgroundColor = RGB_COLOR(@"#bb67ff", 1);
    walletCenterRefreshBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    walletCenterRefreshBtn.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    [walletCenterRefreshBtn addTarget:self action:@selector(doRefreshWallet:) forControlEvents:UIControlEventTouchUpInside];
    walletCenterRefreshBtn.layer.cornerRadius = 12;
    walletCenterRefreshBtn.layer.masksToBounds = YES;
    [changeCoinView addSubview:walletCenterRefreshBtn];
    self.walletCenterRefreshBtn = walletCenterRefreshBtn;
    [self.walletCenterRefreshBtn setImage:[ImageBundle imagewithBundleName:@"profile_refresh"] forState:UIControlStateNormal];
    [walletCenterRefreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(24);
        make.left.centerY.equalTo(changeCoinView);
    }];

    // 切换币种
    UILabel *walletCenterTitleLabel = [UILabel new];
    walletCenterTitleLabel.textColor = UIColor.whiteColor;
    walletCenterTitleLabel.text = YZMsg(@"profile_center_change_unit");
    walletCenterTitleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold];
    [changeCoinView addSubview:walletCenterTitleLabel];
    self.walletCenterTitleLabel = walletCenterTitleLabel;
    [walletCenterTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(walletCenterRefreshBtn.mas_right).offset(4);
        make.right.equalTo(changeCoinView).offset(-10);
        make.top.bottom.equalTo(changeCoinView);
    }];
    walletCenterTitleLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapWalletCenterTitleLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(exchangeRateAction)];
    [walletCenterTitleLabel addGestureRecognizer:tapWalletCenterTitleLabel];

    // 钱包余额背景
    UIView *walletAmountBgView = [UIView new];
    walletAmountBgView.backgroundColor = UIColor.clearColor;
    [self.contentView addSubview:walletAmountBgView];
    [walletAmountBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(22);
        make.left.equalTo(self.contentView).inset(25);
        make.centerY.equalTo(changeCoinView);
    }];

    // 余额
    UILabel *leftCoinLabel = [UILabel new];
    leftCoinLabel.backgroundColor = [UIColor clearColor];
    leftCoinLabel.textAlignment = NSTextAlignmentCenter;
    leftCoinLabel.textColor = RGB_COLOR(@"#000000", 0.7);
    leftCoinLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
//    leftCoinLabel.adjustsFontSizeToFitWidth = YES;
    [walletAmountBgView addSubview: leftCoinLabel];
    self.leftCoinLabel = leftCoinLabel;
    [leftCoinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(walletAmountBgView);
    }];

    // 余额眼睛
    UIButton *eyesBtn = [[UIButton alloc] init];
    eyesBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [eyesBtn addTarget:self action:@selector(doShowHideAmount:) forControlEvents:UIControlEventTouchUpInside];
    [walletAmountBgView addSubview:eyesBtn];
    //self.eyesBtn = eyesBtn;
    [eyesBtn setImage:[ImageBundle imagewithBundleName:@"profile_eye"] forState:UIControlStateNormal];
    [eyesBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(16);
        make.centerY.mas_equalTo(walletAmountBgView);
        make.left.equalTo(leftCoinLabel.mas_right).offset(5);
        make.right.equalTo(walletAmountBgView);
    }];

    // 隱藏或顯示餘額
    UIButton *showOrHideCoinBtn = [UIButton new];
    [showOrHideCoinBtn addTarget:self action:@selector(doShowHideAmount:) forControlEvents:UIControlEventTouchUpInside];
    [walletAmountBgView addSubview:showOrHideCoinBtn];
    self.exchangeRateBtn = showOrHideCoinBtn;
    [showOrHideCoinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(walletAmountBgView).inset(-10);
    }];
    
    UIImageView *backImgView2 = [UIImageView new];
    backImgView2.backgroundColor = UIColor.clearColor;
    backImgView2.userInteractionEnabled = YES;
//    backImgView2.layer.cornerRadius = 12;
//    backImgView2.layer.shadowOffset = CGSizeMake(0, 2);
//    backImgView2.layer.shadowColor = [UIColor blackColor].CGColor;
//    backImgView2.layer.shadowOpacity = 0.2;
//    backImgView2.layer.shadowRadius = 3;
    [self.contentView addSubview:backImgView2];
    self.backImgView2 = backImgView2;
    
    [backImgView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(170);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(100).priorityHigh();
    }];
    
    // 充值
    UIButton *rechargeBtn = [UIButton new];
    [rechargeBtn setImage:[ImageBundle imagewithBundleName:@"profile_refund"] forState:UIControlStateNormal];
    [rechargeBtn addTarget:self action:@selector(doRecharge) forControlEvents:UIControlEventTouchUpInside];
    rechargeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [rechargeBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 0, 0)];
    [backImgView2 addSubview:rechargeBtn];
    self.rechargeBtn = rechargeBtn;
    [rechargeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backImgView2).offset(-12);
        make.size.mas_equalTo(50);
        make.centerX.mas_equalTo(backImgView2).multipliedBy(0.25);
    }];
    
    // 充值标题
    UILabel *rechargeBtnTitle = [UILabel new];
    rechargeBtnTitle.backgroundColor = [UIColor clearColor];
    rechargeBtnTitle.textAlignment = NSTextAlignmentCenter;
    rechargeBtnTitle.textColor = vkColorRGB(82, 99, 119);
    rechargeBtnTitle.text = YZMsg(@"Bet_Charge_Title");
    rechargeBtnTitle.adjustsFontSizeToFitWidth = YES;
    rechargeBtnTitle.minimumScaleFactor = 0.5;
    rechargeBtnTitle.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [backImgView2 addSubview:rechargeBtnTitle];
    self.rechargeBtnTitle = rechargeBtnTitle;
    [rechargeBtnTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(rechargeBtn.mas_bottom).offset(2);
        make.centerX.mas_equalTo(rechargeBtn);
    }];
    
    // 提现
    UIButton *withdrawBtn = [UIButton new];
    [withdrawBtn setImage:[ImageBundle imagewithBundleName:@"profile_withdrawal"] forState:UIControlStateNormal];
    [withdrawBtn addTarget:self action:@selector(doWithdraw) forControlEvents:UIControlEventTouchUpInside];
    withdrawBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [withdrawBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 0, 0)];
    [backImgView2 addSubview:withdrawBtn];
    self.withdrawBtn = withdrawBtn;
    [withdrawBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backImgView2).offset(-12);
        make.size.mas_equalTo(50);
        make.centerX.mas_equalTo(backImgView2).multipliedBy(0.75);
    }];
    
    // 提现标题
    UILabel *withdrawBtnTitle = [UILabel new];
    withdrawBtnTitle.backgroundColor = [UIColor clearColor];
    withdrawBtnTitle.textAlignment = NSTextAlignmentCenter;
    withdrawBtnTitle.textColor = vkColorRGB(82, 99, 119);
    withdrawBtnTitle.text = YZMsg(@"public_WithDraw");
    withdrawBtnTitle.adjustsFontSizeToFitWidth = YES;
    withdrawBtnTitle.minimumScaleFactor = 0.5;
    withdrawBtnTitle.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [backImgView2 addSubview:withdrawBtnTitle];
    self.rechargeBtnTitle = withdrawBtnTitle;
    [withdrawBtnTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(withdrawBtn.mas_bottom).offset(2);
        make.centerX.mas_equalTo(withdrawBtn);
    }];
    
    
    // 额度转换
    UIButton *exchangeBtn = [UIButton new];
    [exchangeBtn setImage:[ImageBundle imagewithBundleName:@"profile_transfer"] forState:UIControlStateNormal];
    [exchangeBtn addTarget:self action:@selector(doExchange) forControlEvents:UIControlEventTouchUpInside];
    exchangeBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [exchangeBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 0, 0)];
    [backImgView2 addSubview:exchangeBtn];
    self.exchangeBtn = exchangeBtn;
    [exchangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backImgView2).offset(-12);
        make.size.mas_equalTo(50);
        make.centerX.mas_equalTo(backImgView2).multipliedBy(1.25);
    }];
    
    // 额度转换标题
    UILabel *exchangeBtnTitle = [UILabel new];
    exchangeBtnTitle.backgroundColor = [UIColor clearColor];
    exchangeBtnTitle.textAlignment = NSTextAlignmentCenter;
    exchangeBtnTitle.textColor = vkColorRGB(82, 99, 119);
    exchangeBtnTitle.text = YZMsg(@"h5game_Amount_Conversion");
    exchangeBtnTitle.adjustsFontSizeToFitWidth = YES;
    exchangeBtnTitle.minimumScaleFactor = 0.5;
    exchangeBtnTitle.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [backImgView2 addSubview:exchangeBtnTitle];
    self.exchangeBtnTitle = exchangeBtnTitle;
    [exchangeBtnTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(exchangeBtn.mas_bottom).offset(2);
        make.centerX.mas_equalTo(exchangeBtn);
    }];
    
    // 收支明细
    UIButton *billDetailBtn = [UIButton new];
    [billDetailBtn setImage:[ImageBundle imagewithBundleName:@"profile_detail"] forState:UIControlStateNormal];
    [billDetailBtn addTarget:self action:@selector(doShowBillDetail:) forControlEvents:UIControlEventTouchUpInside];
    billDetailBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [billDetailBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 0, 0)];
    [backImgView2 addSubview:billDetailBtn];
    //self.billDetailBtn = billDetailBtn;
    [billDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backImgView2).offset(-12);
        make.size.mas_equalTo(50);
        make.centerX.mas_equalTo(backImgView2).multipliedBy(1.75);
    }];
    
    // 收支明细标题
    UILabel *billDetailTitle = [UILabel new];
    billDetailTitle.backgroundColor = [UIColor clearColor];
    billDetailTitle.textAlignment = NSTextAlignmentCenter;
    billDetailTitle.textColor = vkColorRGB(82, 99, 119);
    billDetailTitle.text = YZMsg(@"YBUserInfoVC_BillDetail");
    billDetailTitle.adjustsFontSizeToFitWidth = YES;
    billDetailTitle.minimumScaleFactor = 0.5;
    billDetailTitle.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    [backImgView2 addSubview:billDetailTitle];
    //self.billDetailTitle = billDetailTitle;
    [billDetailTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(billDetailBtn.mas_bottom).offset(2);
        make.centerX.mas_equalTo(billDetailBtn);
    }];
    
    
    //底部view
    YBBottomView *bottomView = [[YBBottomView alloc]init];
    bottomView.layer.cornerRadius = 5.0;
    bottomView.layer.masksToBounds = YES;
    [self.contentView addSubview:bottomView];
    self.bottomView = bottomView;

    LiveUser *user = [Config myProfile];
    [_iconView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[ImageBundle imagewithBundleName:@"profile_accountImg"]];
    _nameLabel.text = user.user_nicename;
    NSString *laingname = minstr([Config getliang]);
    if (laingname!=nil && [laingname isEqual:@"0"]) {
        _IDL.text = [NSString stringWithFormat:@"ID:%@",user.ID];
    }
    else{
        if (![PublicObj checkNull:laingname]) {
            _IDL.text = [NSString stringWithFormat:@"%@:%@",YZMsg(@"public_liang"),laingname];
        }else{
            _IDL.text = @"";
        }
    }
    
    NSString *strID = _IDL.text;
    NSMutableAttributedString *attruID = [[NSMutableAttributedString alloc]initWithString:strID];
    if (strID.length>4) {
        [attruID addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13] range:NSMakeRange(strID.length-4, 4)];
    }
    _IDL.attributedText = attruID;
    
    _IDL.userInteractionEnabled = true;
    UITapGestureRecognizer *gestureTapID = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(copyID)];
    [_IDL addGestureRecognizer:gestureTapID];

    leftCoinLabel.attributedText = [self leftCoinAttribute:[NSString toAmount:user.coin].toDivide10.toRate];

    NSString *sexS = [NSString stringWithFormat:@"%@",user.sex];
    if ([sexS isEqualToString:@"1"]) {
        _sexView.backgroundColor = RGB_COLOR(@"#796dff", 1);
        [_sexView setImage:[ImageBundle imagewithBundleName:@"profile_sex_man"]];
    }
    else{
        _sexView.backgroundColor = RGB_COLOR(@"#fa7d99", 1);
        [_sexView setImage:[ImageBundle imagewithBundleName:@"profile_sex_woman"]];
    }
    
    //[self.contentView addSubview:self.line];
    // 编辑资料
    UIButton *updateBtn = [[UIButton alloc]init];
    //    [updateBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"icon_bjzl"]];
    updateBtn.backgroundColor = RGB_COLOR(@"#000000",0.5);
    [updateBtn setImage:[ImageBundle imagewithBundleName:@"profile_iphone"] forState:UIControlStateNormal];
    [updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [updateBtn setTitle:YZMsg(@"YBUserInfoVC_BindPhone") forState:UIControlStateNormal];
    updateBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    updateBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    updateBtn.titleLabel.minimumScaleFactor = 0.5;
    updateBtn.layer.masksToBounds = YES;
    updateBtn.layer.cornerRadius = 10;
    [updateBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
//    [updateBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 15)];
    [updateBtn addTarget:self action:@selector(bindPhone) forControlEvents:UIControlEventTouchUpInside];
    updateBtn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [self.contentView addSubview:updateBtn];
    self.updateBtn = updateBtn;
    if ([Config getIsBindMobile]) {
        self.updateBtn.hidden = YES;
    }else{
        self.updateBtn.hidden =NO;
    }
    //[self phoneStateChange];
}

- (NSMutableAttributedString*)leftCoinAttribute:(NSString*)coin {
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    [string vk_appendString:[Config getRegionCurrenyChar] ? [Config getRegionCurrenyChar] : @"" color:RGB_COLOR(@"#526377", 1) font:[UIFont systemFontOfSize:18 weight:UIFontWeightSemibold]];
    [string vk_appendString:coin color:RGB_COLOR(@"#000000", 0.7) font:[UIFont systemFontOfSize:18 weight:UIFontWeightSemibold]];
    [string vk_appendSpace:5];
    return string;
}

- (void)phoneStateChange{
    if ([Config getIsBindMobile]) {
        self.updateBtn.userInteractionEnabled = NO;
        [self.updateBtn setTitle:[Config getMobile] forState:UIControlStateNormal];
        [self.updateBtn setImage:[UIImage new] forState:UIControlStateNormal];
        [self.updateBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.updateBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }else{
        self.updateBtn.userInteractionEnabled =YES;
        [self.updateBtn setTitle:YZMsg(@"YBUserInfoVC_BindPhone") forState:UIControlStateNormal];
        [self.updateBtn setImage:[ImageBundle imagewithBundleName:@"icon_bjzl"] forState:UIControlStateNormal];
        [self.updateBtn setImageEdgeInsets:UIEdgeInsetsMake(0,50, 0, - 50)];
        [self.updateBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 15)];
    }
}

-(void)copyID {
//    NSString *strID = _IDL.attributedText.string;
    UIPasteboard *paste = [UIPasteboard generalPasteboard];
//    paste.string = [[strID stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@:",YZMsg(@"public_liang")] withString:@""]stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@:",@"ID"] withString:@""];
    paste.string = _model.ID;
    [MBProgressHUD showSuccess:YZMsg(@"publictool_copy_success")];
}
BOOL isrefreshing;
-(void)refreshVaule{
    if (isrefreshing) {
        return;
    }
    isrefreshing = YES;
    WeakSelf
    [MessageListNetworkUtil getMessageHome:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        NSNumber *messageCount = [networkData.info valueForKeyPath:@"@sum.unread_count"];
        NSInteger unreadCount = [messageCount intValue];
        [strongSelf->_unreadMsgLabel setHidden: (unreadCount == 0)];
        strongSelf->_unreadMsgLabel.text = [NSString stringWithFormat:@"%ld", unreadCount];
        if (unreadCount == 0) { isrefreshing = NO; }
        [NSNotificationCenter.defaultCenter postNotificationName:@"KNoticeMessageKey" object:@(unreadCount)];
    }];
    
    if ([Config getIsBindMobile]) {
        self.updateBtn.hidden = YES;
    }else{
        self.updateBtn.hidden =NO;
    }
    //[self phoneStateChange];
    
    NSString *getBalanceNewUrl = [NSString stringWithFormat:@"User.getWithdraw&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    [[YBNetworking sharedManager] postNetworkWithUrl:getBalanceNewUrl withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        isrefreshing = NO;
        NSDictionary *infoDic = [info firstObject];
        LiveUser *user = [Config myProfile];
        
        user.coin = minstr([infoDic valueForKey:@"coin"]);
        
        [Config updateProfile:user];

        strongSelf.leftCoinLabel.attributedText = [strongSelf leftCoinAttribute:[NSString toAmount:user.coin].toDivide10.toRate];

    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        isrefreshing = NO;
        LiveUser *user = [Config myProfile];
        strongSelf.leftCoinLabel.attributedText = [strongSelf leftCoinAttribute:[NSString toAmount:user.coin].toDivide10.toRate];
    }];
    
    [self.bottomView downDataWithHandler:self.infoArray Handler:^(BOOL hasData) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (hasData) {
            [strongSelf.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                //        make.left.right.equalTo(self.contentView);
                make.height.mas_equalTo(80*(SCREEN_WIDTH/375));
            }];
        }else{
            [strongSelf.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                //        make.left.right.equalTo(self.contentView);
                make.height.mas_equalTo(0);
            }];
        }
        if (strongSelf.personCellDelegate && [strongSelf.personCellDelegate respondsToSelector:@selector(refreshBannerData:)]) {
            [strongSelf.personCellDelegate refreshBannerData:hasData];
        }
    }];
    
    
}

- (void)doShowBillDetail:(UIButton *)sender {
    [[YBUserInfoManager sharedManager] pushBillDetails];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"收支明细"};
    [MobClick event:@"mine_menues_click" attributes:dict];
}
- (void)doShowHideAmount:(UIButton *)sender {
    NSLog(@"缺少關閉眼睛圖片");
    if ([self.leftCoinLabel.text containsString:@"*"]) {
        LiveUser *user = [Config myProfile];
        self.leftCoinLabel.attributedText = [self leftCoinAttribute:[NSString toAmount:user.coin].toDivide10.toRate];
    } else {
        NSMutableString *maskedText = [NSMutableString string];
        for (int i = 0; i < self.leftCoinLabel.text.length; i++) {
            [maskedText appendString:@"*"];
        }
        self.leftCoinLabel.text = maskedText;
    }
}

- (void)doRefreshWallet:(UIButton *)sender {
    [self rotateView:self.walletCenterRefreshBtn];
    [self.personCellDelegate refreshWalletData];
}
-(void)doRecharge{
    [[YBUserInfoManager sharedManager] pushToRecharge];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"充值"};
    [MobClick event:@"mine_menues_click" attributes:dict];
}
-(void)doExchange{
    [[YBUserInfoManager sharedManager] pushExchange];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"额度转换"};
    [MobClick event:@"mine_menues_click" attributes:dict];
}
-(void)doWithdraw{
    [[YBUserInfoManager sharedManager] pushWithdraw];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"提现"};
    [MobClick event:@"mine_menues_click" attributes:dict];
}

-(void)doEdit
{
    [[YBUserInfoManager sharedManager] pushEditView];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"编辑资料"};
    [MobClick event:@"mine_menues_click" attributes:dict];
}

-(void)doInfo
{
    [[YBUserInfoManager sharedManager] pushInfoView];
}

-(void)doSetup
{
    [[YBUserInfoManager sharedManager] pushSetupInfo];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"设置"};
    [MobClick event:@"mine_menues_click" attributes:dict];
}

-(void)doMsgAction
{
    [[YBUserInfoManager sharedManager] pushMsgAction:nil isMessageList:YES];
}

-(void)exchangeRateAction
{
    [[YBUserInfoManager sharedManager] pushExchangeRateAction];
    [self.personCellDelegate pushExchangeRateAction];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"menue_name": @"切换币种"};
    [MobClick event:@"mine_menues_click" attributes:dict];
}


-(void)bindPhone{
    [[YBUserInfoManager sharedManager] pushBindPhone];
}
//MARK:-layoutSubviews
-(void)layoutUI
{
    [self.updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconView.mas_bottom).offset(-10);
        make.centerX.equalTo(self.iconView);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(72);
    }];
    

    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.left.right.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(self.contentView).multipliedBy(0.92);
        make.top.equalTo(self.backImgView2.mas_bottom);
        make.height.mas_equalTo(80*(SCREEN_WIDTH/375));
        make.bottom.mas_equalTo(self.contentView.mas_bottom).inset(15);
    }];
    
//    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.backImgView2).offset(134);
//        make.centerY.equalTo(self.backImgView2);
//        make.size.mas_equalTo(CGSizeMake(1, 38));
//    }];
}
//MARK:-动态返回label文字宽度
+(CGSize)sizeWithText:(NSString *)text textFont:(UIFont *)font textMaxSize:(CGSize)maxSize {
    // 计算文字时要几号字体
    NSDictionary *attr = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
}

//-(UIView *)line{
//    if (!_line) {
//        _line = [[UIView alloc] init];
//        _line.backgroundColor = [UIColor clearColor];
//    }
//    return _line;
//}

#pragma mark - Animation
- (void)rotateView:(UIView *)view {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:4 * M_PI];
    rotationAnimation.duration = 2.0;
    rotationAnimation.removedOnCompletion = YES;
    rotationAnimation.fillMode = kCAFillModeRemoved;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

@end
