//
//  shouhuView.m
//  yunbaolive
//
//  Created by Boom on 2018/8/9.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "shouhuView.h"
#import "grardButton.h"
#import "guardAlertView.h"
#import "UIImageView+WebCache.h"
@implementation shouhuView{
    UIView *whiteView;
    NSMutableArray *btnArray;
    int selectIndex;
    UIImageView *monthImgView;
    UIImageView *yearImgView;
    UILabel *monthLabel;
    UILabel *yearLabel;
    UILabel *coinLabel;
    UIButton *buyBtn;
    NSArray *typeArray;
    UILabel *dateLabel;
    NSDictionary *infoDic;
    NSMutableArray *privilegeArray;
    NSMutableArray *privilegeTitleArray;
    NSMutableArray *privilegeDesArray;
    guardAlertView *gAlert;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, _window_width, _window_height);
        self.backgroundColor = [UIColor clearColor];
        privilegeArray = [NSMutableArray array];
        privilegeTitleArray = [NSMutableArray array];
        privilegeDesArray = [NSMutableArray array];

        btnArray = [NSMutableArray array];
        typeArray = [NSArray array];
        selectIndex = 0;
        [self requestData];
    }
    return self;
}
- (void)creatUI:(NSDictionary *)subDic{
    UIButton *hidebtn = [UIButton buttonWithType:0];
    hidebtn.frame = CGRectMake(0, 0, _window_width, _window_height*0.4);
    [hidebtn addTarget:self action:@selector(hideBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:hidebtn];
    whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, _window_height, _window_width, _window_height*0.6)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:whiteView];
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, _window_width - 20, whiteView.height*0.12)];
    label1.text = YZMsg(@"shouhuView_guardTime");
    label1.textColor = RGB_COLOR(@"#626364", 1);
    label1.font = [UIFont systemFontOfSize:15];
    [whiteView addSubview:label1];
    dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(label1.right, label1.top, _window_width*0.95-(label1.right), label1.height)];
    dateLabel.textColor = [UIColor grayColor];
    dateLabel.textAlignment = NSTextAlignmentRight;
    dateLabel.font = fontThin(13);
    [whiteView addSubview:dateLabel];
    NSArray *arr = [subDic valueForKey:@"list"];
    for (int i = 0 ; i < arr.count ; i++) {
        CGFloat widthhhh = 0;

        if (i == arr.count - 1 ) {
            widthhhh = 20;
        }
        grardButton *btn = [[grardButton alloc] initWithFrame:CGRectMake(20+90*i, label1.bottom, 85+widthhhh, 40)];
        btn.tag = 201889+i;

        NSString *currencyCoin = [YBToolClass getRateCurrency:minstr([arr[i] valueForKey:@"coin"]) showUnit:YES];
        btn.coinL.text = currencyCoin;
        btn.nameL.text = minstr([arr[i] valueForKey:@"name"]);
        
        if (i==0) {
            btn.selected = YES;
        }else{
            btn.selected = NO;
        }
        if (i == arr.count - 1){
            [btn setBackgroundImage:[ImageBundle imagewithBundleName:@"guard_select_s_2"] forState:UIControlStateSelected];
            [btn setBackgroundImage:[ImageBundle imagewithBundleName:@"guard_select_n_2"] forState:UIControlStateNormal];
        }else{
            [btn setBackgroundImage:[ImageBundle imagewithBundleName:@"guard_select_s"] forState:UIControlStateSelected];
            [btn setBackgroundImage:[ImageBundle imagewithBundleName:@"guard_select_n"] forState:UIControlStateNormal];
        }
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnArray addObject:btn];
        [whiteView addSubview:btn];
    }
    
    UIImageView *lineImgView =[[UIImageView alloc]initWithFrame:CGRectMake(_window_width*0.05, whiteView.height*0.25, _window_width*0.9, 1)];
    lineImgView.image = [ImageBundle imagewithBundleName:@"jimo_shouhu_xuxian"];
    [whiteView addSubview:lineImgView];
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(10, lineImgView.bottom, _window_width*0.8, whiteView.height*0.12)];
    label2.text = YZMsg(@"shouhuView_guardrights");
    label2.font = [UIFont systemFontOfSize:15];
    label2.textColor = RGB_COLOR(@"#626364", 1);

    [whiteView addSubview:label2];

    NSArray *privilege = [subDic valueForKey:@"privilege"];
    NSArray *firstArr = [[[subDic valueForKey:@"list"] firstObject] valueForKey:@"privilege"];

    for (int i = 0; i < privilege.count; i++) {
        NSDictionary *itemDic = privilege[i];
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(20, label2.bottom+i*whiteView.height*0.12, whiteView.height*0.08, whiteView.height*0.08)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [whiteView addSubview:imgView];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(imgView.right+8, imgView.top, _window_width-(imgView.right+8+5), imgView.height/2)];
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.text = minstr([itemDic valueForKey:@"title"]);
        [whiteView addSubview:titleLabel];
        
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(imgView.right+8, titleLabel.bottom, _window_width-(imgView.right+8+5), imgView.height/1.2)];
        contentLabel.font = fontThin(10);
        contentLabel.numberOfLines = 2;
        contentLabel.textColor = [UIColor grayColor];
        contentLabel.text = minstr([itemDic valueForKey:@"des"]);
        [whiteView addSubview:contentLabel];
        if (i < firstArr.count) {
            if (i == 0) {
                [imgView sd_setImageWithURL:[NSURL URLWithString:minstr([itemDic valueForKey:@"thumb_g"])]];
            }else{
                [imgView sd_setImageWithURL:[NSURL URLWithString:minstr([itemDic valueForKey:@"thumb_c"])]];
            }
            titleLabel.textColor = RGB_COLOR(@"#646464", 1);
            contentLabel.textColor = RGB_COLOR(@"#646464", 1);
        }else{
            [imgView sd_setImageWithURL:[NSURL URLWithString:minstr([itemDic valueForKey:@"thumb_g"])]];
            titleLabel.textColor = RGB_COLOR(@"#c8c8c8", 1);
            contentLabel.textColor = RGB_COLOR(@"#c8c8c8", 1);
        }
        [privilegeArray addObject:imgView];
        [privilegeTitleArray addObject:titleLabel];
        [privilegeDesArray addObject:contentLabel];

        if (i == 3) {
            yearImgView = imgView;
        }
    }
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, yearImgView.bottom+whiteView.height*0.05, _window_width, 1)];
    lineView.backgroundColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1.00];
    [whiteView addSubview:lineView];
    
    coinLabel = [[UILabel alloc]initWithFrame:CGRectMake(_window_width*0.05, lineView.bottom, _window_width*0.95-110, whiteView.height-ShowDiff-(lineView.bottom))];
    coinLabel.font = [UIFont systemFontOfSize:14];
    coinLabel.attributedText = [self coinLabel:minstr([subDic valueForKey:@"coin"])];
    coinLabel.textColor = RGB_COLOR(@"#646464", 1);
    [whiteView addSubview:coinLabel];
    
    buyBtn = [UIButton buttonWithType:0];
    buyBtn.frame = CGRectMake(_window_width-100, coinLabel.top + (coinLabel.height-30)/2, 90, 30);
    [buyBtn addTarget:self action:@selector(buyBtnClick) forControlEvents:UIControlEventTouchUpInside];
    buyBtn.layer.cornerRadius = 15;
    buyBtn.layer.masksToBounds = YES;
    [buyBtn setBackgroundColor:normalColors];
    [buyBtn setTitle:YZMsg(@"guardShowView_OpenNow") forState:0];
    buyBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    buyBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    buyBtn.titleLabel.minimumScaleFactor = 0.5;
    [whiteView addSubview:buyBtn];
    [self show];
}
- (NSMutableAttributedString *)coinLabel:(NSString *)coin{
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]init];
    NSAttributedString *str1 = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@：",YZMsg(@"shouhuView_MyBalance"),YZMsg(@"LobbyBetConfirm_balance")]];
    [attStr appendAttributedString:str1];

    NSString *currencyCoin = [YBToolClass getRateCurrency:coin showUnit:YES];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc]initWithString:currencyCoin];
    [str2 addAttribute:NSForegroundColorAttributeName value:normalColors range:NSMakeRange(0, [coin length])];
    [attStr appendAttributedString:str2];
    return  attStr;
}
- (void)hideBtnClick{
    [self.delegate removeShouhuView];
}
- (void)btnClick:(grardButton *)sender{
    sender.selected = YES;
    selectIndex = (int)sender.tag - 201889;
    for (grardButton *btn in btnArray) {
        if (sender != btn) {
            btn.selected = NO;
        }
    }
    NSArray *privilege = [infoDic valueForKey:@"privilege"];
    NSDictionary *selectDiccc = [infoDic valueForKey:@"list"][selectIndex];
    NSArray *firstArr = [selectDiccc valueForKey:@"privilege"];
    for (int i = 0; i < privilege.count; i ++) {
        NSDictionary *itemDic = privilege[i];
        UIImageView *imgView = privilegeArray[i];
        UILabel *titleLabel = privilegeTitleArray[i];
        UILabel *contentLabel = privilegeDesArray[i];
        if (i < firstArr.count) {
            if([minstr([selectDiccc valueForKey:@"type"]) isEqual:@"2"]){
                [imgView sd_setImageWithURL:[NSURL URLWithString:minstr([itemDic valueForKey:@"thumb_c"])]];
            }else{
                if (i == 0) {
                    [imgView sd_setImageWithURL:[NSURL URLWithString:minstr([itemDic valueForKey:@"thumb_g"])]];
                }else{
                    [imgView sd_setImageWithURL:[NSURL URLWithString:minstr([itemDic valueForKey:@"thumb_c"])]];
                }
            }
            titleLabel.textColor = RGB_COLOR(@"#646464", 1);
            contentLabel.textColor = RGB_COLOR(@"#646464", 1);
        }else{
            [imgView sd_setImageWithURL:[NSURL URLWithString:minstr([itemDic valueForKey:@"thumb_g"])]];
            titleLabel.textColor = RGB_COLOR(@"#c8c8c8", 1);
            contentLabel.textColor = RGB_COLOR(@"#c8c8c8", 1);
        }

    }


}
- (void)show{
    WeakSelf
    [UIView animateWithDuration:0.3 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->whiteView.frame = CGRectMake(0, _window_height*0.4, _window_width, _window_height*0.6);
    }];
}
- (void)hideAlert{
    [gAlert removeFromSuperview];
    gAlert = nil;
}
- (void)buyBtnClick{
//    if ([_guardType isEqual:@"0"]) {
//
////        [self goBuy];
//    }else{
        if ([_guardType isEqual:@"1"] && selectIndex == 2) {
            gAlert = [[guardAlertView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andType:1 andMsg:YZMsg(@"shouhuView_GuardMonthDes")];
            __weak shouhuView *wSelf = self;
            gAlert.block = ^(BOOL isSure) {
                if (isSure) {
                    [wSelf goBuy];
                }else{
                    [wSelf hideAlert];
                }
            };
            [self addSubview:gAlert];

        }else if ([_guardType isEqual:@"2"] && selectIndex != 2) {
            gAlert = [[guardAlertView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andType:0 andMsg:YZMsg(@"shouhuView_GuardYearDes")];
            __weak shouhuView *wSelf = self;
            gAlert.block = ^(BOOL isSure) {
                if (isSure) {
                    [wSelf goBuy];
                }else{
                    [wSelf hideAlert];
                }
            };
            [self addSubview:gAlert];

        }else{
            NSString *msg;
            NSString *coin = minstr([[infoDic valueForKey:@"list"][selectIndex] valueForKey:@"coin"]);
            NSString *currencyCoin = [YBToolClass getRateCurrency:coin showUnit:YES];
            switch (selectIndex) {
                case 0:
                    msg = [NSString stringWithFormat:@"%@ %@， %@",
                           YZMsg(@"shouhuView_You_will_coast"),
                           currencyCoin,
                           YZMsg(@"shouhuView_Guard7Days")];
                    break;
                case 1:
                    msg = [NSString stringWithFormat:@"%@ %@，%@",
                           YZMsg(@"shouhuView_You_will_coast"),
                           currencyCoin,
                           YZMsg(@"shouhuView_GuardMonthDays")];
                    break;
                case 2:
                    msg = [NSString stringWithFormat:@"%@ %@，%@",
                           YZMsg(@"shouhuView_You_will_coast"),
                           currencyCoin,
                           YZMsg(@"shouhuView_GuardOneYear")];
                    break;
                    
                default:
                    break;
            }
            gAlert = [[guardAlertView alloc]initWithFrame:CGRectMake(0, 0, _window_width, _window_height) andType:1 andMsg:msg];
            __weak shouhuView *wSelf = self;
            gAlert.block = ^(BOOL isSure) {
                if (isSure) {
                    [wSelf goBuy];
                }else{
                    [wSelf hideAlert];
                }
            };
            [self addSubview:gAlert];

        }

//    }

}
- (void)goBuy{
    NSDictionary *parameterDic = @{
                                   @"liveuid":_liveUid,
                                   @"guardid":minstr([[infoDic valueForKey:@"list"][selectIndex] valueForKey:@"id"]),
                                   @"stream":_stream
                                   };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Guard.BuyGuard" withBaseDomian:YES andParameter:parameterDic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            NSDictionary *infos = [info firstObject];
            [strongSelf.delegate buyShouhuSuccess:infos];
            [strongSelf hideBtnClick];
            
        }
        [MBProgressHUD showError:msg];
        
    } fail:^(NSError * _Nonnull error) {
        [MBProgressHUD showError:YZMsg(@"public_networkError")];
    }];

}
- (void)requestData{
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Guard.GetList" withBaseDomian:YES andParameter:nil data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            strongSelf->infoDic = [info firstObject];
            [strongSelf creatUI:strongSelf->infoDic];
        }
    } fail:^(NSError * _Nonnull error) {
        
    }];
}
#pragma mark ================ alertview ===============
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (buttonIndex == 1) {
//        [self.delegate pushCoinV];
//    }
//}
@end
