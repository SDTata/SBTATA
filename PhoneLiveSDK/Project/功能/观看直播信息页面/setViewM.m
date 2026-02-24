#import "setViewM.h"
#import "Config.h"
#import "MBProgressHUD+MJ.h"
#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+LBExtension.h"
#import <UMCommon/UMCommon.h>

@interface setViewM() {
    UIView *_yingpiaoLabelView;
    CAGradientLayer *_yingpiaoLabelLayer;
    CAGradientLayer *_guardBtnLayer;
}
@end

@implementation setViewM

-(void)leftviews{
    if (_leftView) {
        return;
    }
    _leftView = [[UIView alloc]init];
    
    _leftView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
    //左上角 直播live
    _leftView.frame = CGRectMake(10,25+statusbarHeight,110,leftW);
    _leftView.layer.cornerRadius = leftW/2;
    UITapGestureRecognizer *tapleft = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zhuboMessage)];
    tapleft.numberOfTapsRequired = 1;
    tapleft.numberOfTouchesRequired = 1;
    [_leftView addGestureRecognizer:tapleft];
    //关注主播
    _newattention = [UIButton buttonWithType:UIButtonTypeCustom];
    _newattention.frame = CGRectMake(100,5,40,25);
//    _newattention.layer.masksToBounds = YES;
//    _newattention.layer.cornerRadius = 12.5;
    [_newattention setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _newattention.titleLabel.font = [UIFont systemFontOfSize:11];
    [_newattention setTitle:YZMsg(@"homepageController_attention") forState:UIControlStateNormal];
//    [_newattention setBackgroundColor:normalColors];
    [_newattention setBackgroundImage:[ImageBundle imagewithBundleName:@"yfks_gz_anniu"] forState:UIControlStateNormal];
    _newattention.contentMode = UIViewContentModeScaleAspectFit;
    [_newattention addTarget:self action:@selector(guanzhuzhubo) forControlEvents:UIControlEventTouchUpInside];
    _newattention.hidden = YES;
    _newattention.titleLabel.adjustsFontSizeToFitWidth = YES;
    _newattention.titleLabel.minimumScaleFactor = 0.3;
    //主播头像button
    _IconBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    [_IconBTN addTarget:self action:@selector(zhuboMessage) forControlEvents:UIControlEventTouchUpInside];
    
    _IconBTN.frame = CGRectMake(2.5, 2.5, leftW-5, leftW-5);
    _IconBTN.layer.masksToBounds = YES;
    _IconBTN.layer.borderWidth = 1;
    _IconBTN.layer.borderColor = normalColors.CGColor;
    _IconBTN.layer.cornerRadius = (leftW-5)/2;
    
    //添加主播等级
    _levelimage = [[UIImageView alloc]initWithFrame:CGRectMake(_IconBTN.right - 11,_IconBTN.bottom - 11,13,13)];
    NSDictionary *levelDic = [common getAnchorLevelMessage:minstr(self.zhuboModel.level_anchor)];
    [_levelimage sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb_mark"])] placeholderImage:nil];
    
    NSString *path = self.zhuboModel.zhuboIcon;
    NSURL *url = [NSURL URLWithString:path];
    [_IconBTN sd_setBackgroundImageWithURL:url forState:UIControlStateNormal placeholderImage:[ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"]];
    //主播名称
    UILabel *liveLabel;
    liveLabel = [[UILabel alloc]initWithFrame:CGRectMake(leftW+5,2,50,15)];
    liveLabel.textAlignment = NSTextAlignmentLeft;
    liveLabel.text = minstr(self.zhuboModel.zhuboName);
    liveLabel.textColor = [UIColor whiteColor];
    liveLabel.shadowOffset = CGSizeMake(1,1);//设置阴影
    liveLabel.font = fontMT(10);
    //主播ID
    _idLabel = [[UILabel alloc]initWithFrame:CGRectMake(7, _leftView.bottom+10, 80, 20)];
    _idLabel.frame = CGRectMake(leftW+5,17,70,15);
    
    _idLabel.textAlignment = NSTextAlignmentLeft;
    _idLabel.textColor = [UIColor whiteColor];
    _idLabel.font = fontMT(10);
    NSString *liangname = minstr(self.zhuboModel.goodnum);
    if ([liangname isEqual:@"0"]) {
        _idLabel.text = [NSString stringWithFormat:@"ID:%@",minstr(_zhuboModel.zhuboID)];
    }else{
        _idLabel.text = [NSString stringWithFormat:@"%@:%@",YZMsg(@"public_liang"),liangname];
    }
    ///花浪
    _yingpiaoLabel  = [[UILabel alloc]init];
    _yingpiaoLabel.font = [UIFont systemFontOfSize:12];
    _yingpiaoLabel.textAlignment = NSTextAlignmentCenter;
    _yingpiaoLabel.textColor = [UIColor whiteColor];
    _yingpiaoLabel.layer.cornerRadius = 10;
    _yingpiaoLabel.layer.masksToBounds = YES;
    UITapGestureRecognizer *yingpiaoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(yingpiao)];
    _yingpiaoLabel.userInteractionEnabled = YES;
    [_yingpiaoLabel addGestureRecognizer:yingpiaoTap];

    // 花浪的漸層
    _yingpiaoLabelView = [UIView new];
    _yingpiaoLabelView.backgroundColor = [UIColor clearColor];
    _yingpiaoLabelView.layer.cornerRadius = 10;
    _yingpiaoLabelView.layer.masksToBounds = YES;
    [self addSubview:_yingpiaoLabelView];

    _yingpiaoLabelLayer = [CAGradientLayer layer];
    _yingpiaoLabelLayer.colors = @[(__bridge id)RGB_COLOR(@"#FACC22", 1).CGColor,(__bridge id)RGB_COLOR(@"#F83600", 1).CGColor];
    _yingpiaoLabelLayer.startPoint = CGPointMake(0, 0);
    _yingpiaoLabelLayer.endPoint = CGPointMake(1.0, 0);
    _yingpiaoLabelLayer.zPosition = -100;
    [_yingpiaoLabelView.layer insertSublayer:_yingpiaoLabelLayer atIndex:0];

    ///守护
    _guardBtn = [UIButton buttonWithType:0];
    [_guardBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _guardBtn.frame = CGRectMake(_yingpiaoLabel.right+5, _yingpiaoLabel.top, 80, _yingpiaoLabel.height);
    [_guardBtn addTarget:self action:@selector(guardBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_guardBtn setTitle:YZMsg(@"setViewM_guardTitle>") forState:0];
    _guardBtn.layer.cornerRadius = 10;
    _guardBtn.layer.masksToBounds = YES;
    guardWidth = [[YBToolClass sharedInstance] widthOfString:YZMsg(@"setViewM_guardTitle") andFont:[UIFont systemFontOfSize:12] andHeight:20];
    _guardBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _guardBtnLayer = [CAGradientLayer layer];
    _guardBtnLayer.colors = @[(__bridge id)RGB_COLOR(@"#2400FF", 1).CGColor,(__bridge id)RGB_COLOR(@"#76AAFF", 1).CGColor];
    _guardBtnLayer.startPoint = CGPointMake(0, 0);
    _guardBtnLayer.endPoint = CGPointMake(1.0, 0);
    _guardBtnLayer.zPosition = -100;
    [_guardBtn.layer insertSublayer:_guardBtnLayer atIndex:0];

    ///实时榜单
    _topTodayButton = [UIButton buttonWithType:0];
    _topTodayButton.frame = CGRectMake(_guardBtn.right+5, _yingpiaoLabel.top, 70, _yingpiaoLabel.height);
    _topTodayButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
    [_topTodayButton addTarget:self action:@selector(topTodayClick) forControlEvents:UIControlEventTouchUpInside];
    [_topTodayButton setTitle:YZMsg(@"setViewM_Top_list") forState:0];
    _topTodayButton.layer.cornerRadius = 10;
    _topTodayButton.layer.masksToBounds = YES;
    _topTodayButton.titleLabel.font = [UIFont systemFontOfSize:12];
    
    
    
    [_leftView addSubview:liveLabel];
    [_leftView addSubview:_idLabel];
    [_leftView addSubview:_IconBTN];
    [_leftView addSubview:_levelimage];//主播等级
    [self addSubview:_yingpiaoLabel];//
    [self addSubview:_guardBtn];//
    [self addSubview:_topTodayButton];//

    [self addSubview:_leftView];//添加左上角信息
    [_leftView addSubview:_newattention];
    
    UIButton *speedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    speedButton.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
    speedButton.layer.cornerRadius = 10;
    speedButton.layer.masksToBounds = YES;
    speedButton.titleLabel.font = [UIFont systemFontOfSize:8];
    speedButton.titleLabel.textColor = UIColor.whiteColor;
    speedButton.titleLabel.numberOfLines = 0;
    speedButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    speedButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    speedButton.userInteractionEnabled = NO;
    [self addSubview:speedButton];
    self.speedButton = speedButton;
    [speedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topTodayButton.mas_centerY);
        make.left.mas_equalTo(self.topTodayButton.mas_right).offset(5);
        make.height.mas_equalTo(self.topTodayButton.mas_height);
    }];
}

- (void)updateSpeedValue:(NSInteger)speed {
    [YBToolClass.sharedInstance checkNetworkflow];
    NSString *title = [NSString stringWithFormat:@"%ldms\n↓%@/s", speed, YBToolClass.sharedInstance.receivedNetworkSpeed?:@"0"];
    [self.speedButton setTitle:title forState:UIControlStateNormal];
    
    if (speed > 350 || speed <= 0) {
        [self.speedButton setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    } else if (speed > 150) {
        [self.speedButton setTitleColor:UIColor.orangeColor forState:UIControlStateNormal];
    } else {
        [self.speedButton setTitleColor:UIColor.greenColor forState:UIControlStateNormal];
    }
}

-(instancetype)initWithModel:(hotModel *)playModel{
    self = [super init];
    if (self) {
        self.zhuboModel = playModel;
        //添加遮罩层
        _ZheZhaoBTN = [UIButton buttonWithType:UIButtonTypeSystem];
        _ZheZhaoBTN.frame = CGRectMake(0, 0, _window_width, _window_height);
        _ZheZhaoBTN.backgroundColor = [UIColor clearColor];
        [_ZheZhaoBTN addTarget:self action:@selector(zhezhaoBTN) forControlEvents:UIControlEventTouchUpInside];
        _ZheZhaoBTN.hidden = YES;
        //一开始进入显示的背景
        _bigAvatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,_window_width, _window_height)];
        _bigAvatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        if (playModel.zhuboImage) {
             [_bigAvatarImageView sd_setImageWithURL:[NSURL URLWithString:playModel.zhuboImage] placeholderImage:[ImageBundle imagewithBundleName:@"image_placehold"]];
         }else{
             [_bigAvatarImageView sd_setImageWithURL:[NSURL URLWithString:playModel.avatar_thumb] placeholderImage:[ImageBundle imagewithBundleName:@"image_placehold"]];
         }
        
        
//        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//        UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
//        effectview.frame = CGRectMake(0, 0,_window_width,_window_height);
//        [_bigAvatarImageView addSubview:effectview];
        
        [self addSubview:_ZheZhaoBTN];//添加遮罩
        [self addSubview:_bigAvatarImageView];//添加背景图
        WeakSelf
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF
            if(strongSelf == nil){
                return;
            }
            [strongSelf leftviews];
            
            [strongSelf changeState:@"0"];
            [strongSelf changeGuardButtonFrame:@"0"];
        });
        
        //*********************************************************************************//
    }
    return self;
}
//点击关注主播
-(void)guanzhuzhubo{
    NSDictionary *subdic = @{
        @"touid":self.zhuboModel.zhuboID,
        @"is_follow":@"1"
    };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:10];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.setAttent" withBaseDomian:YES andParameter:subdic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [hud hideAnimated:YES];
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            [strongSelf.frontviewDelegate guanzhuZhuBo];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
    }];
    [MobClick event:@"live_room_follow_click" attributes:@{@"eventType": @(1)}];
}
//改变左上角 映票数量
-(void)changeState:(NSString *)texts{
    if (!_leftView) {
        [self leftviews];
    }
    UIFont *font1 = [UIFont systemFontOfSize:12];
//    NSString *currencyCoin = [YBToolClass getRateCurrency:texts showUnit:YES];
    NSString *str = [NSString stringWithFormat:@"%@ >",YZMsg(@"RankVC_contribution_list")];
    CGFloat width = [[YBToolClass sharedInstance] widthOfString:str andFont:font1 andHeight:20];
    _yingpiaoLabel.frame = CGRectMake(10, _leftView.bottom+10, width+30, 20);
    _yingpiaoLabelView.frame = _yingpiaoLabel.frame;
    _yingpiaoLabel.text = str;
    _guardBtn.frame = CGRectMake(_yingpiaoLabel.right+5, _yingpiaoLabel.top, guardWidth+20, _yingpiaoLabel.height);
    _topTodayButton.frame = CGRectMake(_guardBtn.right+5, _yingpiaoLabel.top, 70, _yingpiaoLabel.height);

    _yingpiaoLabelLayer.frame = _yingpiaoLabelView.bounds;
    _guardBtnLayer.frame = _guardBtn.bounds;
}
-(void)changeGuardButtonFrame:(NSString *)nums{
    [_guardBtn setTitle:[NSString stringWithFormat:@"%@ %@%@ >",YZMsg(@"setViewM_Guardians"),nums,YZMsg(@"setViewM_GuardiansP")] forState:0];
    
    guardWidth = [[YBToolClass sharedInstance] widthOfString:_guardBtn.titleLabel.text andFont:[UIFont systemFontOfSize:12] andHeight:20];
    _guardBtn.frame = CGRectMake(_yingpiaoLabel.right+5, _yingpiaoLabel.top, guardWidth+20, _yingpiaoLabel.height);
    
    _topTodayButton.frame = CGRectMake(_guardBtn.right+5, _yingpiaoLabel.top, 70, _yingpiaoLabel.height);

    _guardBtnLayer.frame = _guardBtn.bounds;
}//改变守护按钮适应坐标

//跳魅力值页面
-(void)yingpiao{
    [self.frontviewDelegate gongxianbang];
}
-(void)zhuboMessage{
    [self.frontviewDelegate zhubomessage];
}
-(void)zhezhaoBTN{
    [self.frontviewDelegate zhezhaoBTNdelegate];
}
- (void)guardBtnClick{
    [self.frontviewDelegate showGuardView];
}
-(void)topTodayClick
{
    [self.frontviewDelegate showTopTodayView];
}
-(void)hiddenTopViewForChat:(BOOL)isHiden
{
    if (isHiden) {
        WeakSelf
        [UIView animateWithDuration:0.2 animations:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf.yingpiaoLabel.alpha = 0;
            strongSelf.guardBtn.alpha = 0;
            strongSelf.topTodayButton.alpha = 0;
            strongSelf->_yingpiaoLabelView.alpha = 0;
        }];
        
    }else{
        WeakSelf
        [UIView animateWithDuration:0.2 animations:^{
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            strongSelf.yingpiaoLabel.alpha = 1;
            strongSelf.guardBtn.alpha = 1;
            strongSelf.topTodayButton.alpha = 1;
            strongSelf->_yingpiaoLabelView.alpha = 1;
        }];
    }
}

- (CGRect)getLeftViewFrame {
    return _leftView.frame;
}
@end
