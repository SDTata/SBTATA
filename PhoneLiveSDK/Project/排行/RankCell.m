//
//  RankCell.m
//  yunbaolive
//
//  Created by YunBao on 2018/2/2.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "RankCell.h"
#import "UIImageView+WebCache.h"

#import "LiveGifImage.h"
@interface RankCell()
{
  
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_rightMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_rightMargin_two;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_leftRecoin;

@end
@implementation RankCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.followBtn setTitle:YZMsg(@"RankCell_FollowButton") forState:UIControlStateNormal];
    self.followBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.followBtn.titleLabel.minimumScaleFactor = 0.3;
    self.followBtn.titleLabel.numberOfLines = 1;
    [self.followBtn addTarget:self action:@selector(followSomeOne:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *gifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:@"living_animation" ofType:@"gif"];
   
    self.gifImgV = [[YYAnimatedImageView alloc]init];
     
    LiveGifImage *imgAnima =  (LiveGifImage *)[LiveGifImage imageWithData:[NSData dataWithContentsOfFile:gifPath]];
    [imgAnima setAnimatedImageLoopCount:0];
//    imgAnima.loopCount = 0;
    self.gifImgV.image = imgAnima;
    self.gifImgV.runloopMode = NSRunLoopCommonModes;
    self.gifImgV.animationRepeatCount = 0;
    [self.gifImgV startAnimating];
    [self.contentView addSubview:self.gifImgV];
   
    [self.gifImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameL.mas_right).offset(7);
        make.top.equalTo(self.nameL.mas_top).offset(0);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(14);
    }];
    
    // 设置灰色半透明背景
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1]; // 灰色半透明
    backgroundView.layer.cornerRadius = 10; // 圆角半径
    backgroundView.layer.masksToBounds = YES; // 裁剪超出圆角部分
    backgroundView.tag = 1101010;

    [self.gifImgV.superview addSubview:backgroundView];
    [self.gifImgV.superview addSubview:self.gifImgV];
    
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gifImgV).offset(-3);
        make.top.equalTo(self.gifImgV).offset(-4);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}


- (void)setIsRich:(BOOL)isRich{
    _isRich = isRich;
    [self.followBtn setHidden:isRich];
    self.layout_rightMargin_two.constant = isRich?20:79.5;
    self.layout_rightMargin.constant = isRich?60:120.5;
}
-(void)setModel:(RankModel *)model {
    _model = model;
    [_iconIV sd_setImageWithURL:[NSURL URLWithString:_model.iconStr] placeholderImage:[ImageBundle imagewithBundleName:@"profile_accountImg"]];
    _nameL.text = _model.unameStr;
    //收益榜-0 消费榜-1
    if ([_model.type isEqual:@"0"]) {
        NSDictionary *levelDic = [common getAnchorLevelMessage:_model.levelStr];
        [_levelIV sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]];
        //        _votesL.text = [common name_votes];
    }else {
        NSDictionary *levelDic = [common getUserLevelMessage:_model.levelStr];
        [_levelIV sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]];
        //        _votesL.text = [common name_coin];
    }

    NSString *currencyCoin = [YBToolClass getRateCurrency:minstr(_model.totalCoinStr) showUnit:YES];
    if (_isRich) {
        _votesL.text = [NSString stringWithFormat:YZMsg(@"RankCell_Title_scroe%@"),[NSString stringWithFormat:@"%@",currencyCoin]];

        
        NSDictionary *levelDic = [common getUserLevelMessage:_model.levelStr];
        [_levelIV sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]];
    }else{
        _votesL.text = [NSString stringWithFormat:YZMsg(@"RankCell_Title_scroe%@"),[NSString stringWithFormat:@"%@",currencyCoin]];
    }
    
    
    if ([_model.sex isEqual:@"1"]) {
        self.sexImgView.image = [ImageBundle imagewithBundleName:@"sex_man"];
    }else{
        self.sexImgView.image = [ImageBundle imagewithBundleName:@"sex_woman"];
    }
    if ([_model.isAttention isEqual:@"0"]) {
        self.followBtn.selected = NO;
        [self.followBtn setTitle:YZMsg(@"RankCell_FollowButton") forState:UIControlStateNormal];
    }else {
        self.followBtn.selected = YES;
        [self.followBtn setTitle:YZMsg(@"upmessageInfo_followed") forState:UIControlStateNormal];
    }
    
    
    if ([_model.region_icon isKindOfClass:[NSNull class]] || [_model.region_icon isEqual:[NSNull null]] || _model.region_icon == nil || [_model.region_icon isEqualToString:@"<null>"]) {
        self.countryImg.image = nil;
        self.layout_leftRecoin.constant = 13;
    }else{
        self.layout_leftRecoin.constant = 34;
        [self.countryImg sd_setImageWithURL:[NSURL URLWithString:_model.region_icon] placeholderImage:[ImageBundle imagewithBundleName:@""]];
    }
    
    if (_model.isLive && (!_gifImgV.isAnimating || _gifImgV.hidden)) {
        _gifImgV.hidden = NO;
        UIView *backgroundView = [_gifImgV.superview viewWithTag:1101010];
        backgroundView.hidden = NO;
        [_gifImgV startAnimating];
    }else{
        UIView *backgroundView = [_gifImgV.superview viewWithTag:1101010];
        backgroundView.hidden = YES;
        if (_gifImgV.hidden == NO) {
            _gifImgV.hidden = YES;
        }
        if (_gifImgV.isAnimating) {
            [_gifImgV stopAnimating];
        }
       
    }
}

- (void)followSomeOne:(UIButton *)sender{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [hud hideAnimated:YES afterDelay:10];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.setAttent" withBaseDomian:YES andParameter:@{@"touid":_model.uidStr,@"is_follow":minnum(![_model.isAttention isEqual:@"0"])} data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [hud hideAnimated:YES];
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            NSString *isattent = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"isattent"]];
            NSDictionary *subdic = [info firstObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLiveplayAttion" object:subdic];

            if ([isattent isEqual:@"1"]) {
                [strongSelf.followBtn setTitle:YZMsg(@"upmessageInfo_followed") forState:UIControlStateNormal];
                NSLog(@"关注成功");
            }
            else
            {
                [strongSelf.followBtn setTitle:YZMsg(@"homepageController_attention") forState:UIControlStateNormal];
                NSLog(@"取消关注成功");
            }
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
    }];
}
@end
