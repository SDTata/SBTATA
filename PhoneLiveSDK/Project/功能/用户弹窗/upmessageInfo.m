#import "upmessageInfo.h"
#import "UIButton+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "CSActionSheet.h"
#import "CSActionPicker.h"
#import "UIView+Additions.h"
#import <UMCommon/UMCommon.h>

@interface upmessageInfo ()<UIAlertViewDelegate,UIActionSheetDelegate,UIActionSheetDelegate>
{
    CSActionSheet *_myActionSheet;
    UIActionSheet *actionSheet;//管理弹窗
    UIButton *cancleBTN;
    CGFloat userW;
    NSString *userName;
}
@end
@implementation upmessageInfo
-(instancetype)initWithFrame:(CGRect)frame andPlayer:(NSString *)playerstate{
    self = [super initWithFrame:frame];
    if (self) {
        _playstate = playerstate;
        [self upMessage];
    }
    return self;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex== 0) {
        return;
    }else{
        NSDictionary *subdic = @{
                                 @"uid":[Config getOwnID],
                                 @"touid":self.userID,
                                 @"token":[Config getOwnToken],
                                 @"content":YZMsg(@"upmessageInfo_content")
                                 };
        [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.setReport" withBaseDomian:YES andParameter:subdic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
            if (code == 0) {
                [MBProgressHUD showError:YZMsg(@"jubaoVC_success")];
            }
        } fail:^(NSError * _Nonnull error) {
            
        }];
    }
}
-(void)doReport{
//    UIAlertView *customAlertView = [[UIAlertView alloc] initWithTitle:YZMsg(@"提示") message:YZMsg(@"确定举报？") delegate:self cancelButtonTitle:YZMsg(@"取消") otherButtonTitles:YZMsg(@"确定"), nil];
//    customAlertView.tag = 1035;
//    customAlertView.delegate = self;
//    [customAlertView show];
    [self.upmessageDelegate doReportAnchor:self.userID];
}
-(void)closeDetailView{
    [NSNotificationCenter.defaultCenter postNotificationName:KLiveCanScrollNotification object:@1];
    [self.upmessageDelegate doupCancle];
}
//用户列表弹窗
-(void)upMessage{
    //*********************************添加用户列表弹窗**********************************//
    CGFloat headerHeight = _window_width*0.4;
    //头部背景
    UIImageView *topImageView = [[UIImageView alloc]init];
    topImageView.userInteractionEnabled = YES;
    topImageView.image = [ImageBundle imagewithBundleName:@"userMsg_backImg"];
    [self addSubview:topImageView];
    [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.equalTo(self);
        make.height.equalTo(topImageView.mas_width).multipliedBy(0.5);
    }];
    //头像
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(topImageView);
        make.top.equalTo(self).offset(headerHeight*72/300);
        make.height.equalTo(topImageView.mas_height).multipliedBy(0.5);
        make.width.equalTo(_iconImageView.mas_height);
    }];
    UIImageView *headerImageView = [[UIImageView alloc]init];
    headerImageView.image = [ImageBundle imagewithBundleName:@"userMsg_header"];
    [self addSubview:headerImageView];
    [headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(topImageView);
        make.height.equalTo(topImageView.mas_height).multipliedBy(26/30.00);
        make.width.equalTo(headerImageView.mas_height);
    }];
    //关闭按钮
    cancleBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleBTN setImage:[ImageBundle imagewithBundleName:@"iconguanbi"] forState:UIControlStateNormal];
    [cancleBTN addTarget:self action:@selector(closeDetailView) forControlEvents:UIControlEventTouchUpInside];
    cancleBTN.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:cancleBTN];
    [cancleBTN mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.right.equalTo(self).mas_offset(-29);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(45);
    }];
    _jubaoBTNnew = [UIButton buttonWithType:UIButtonTypeCustom];
    [_jubaoBTNnew setTitle:YZMsg(@"upmessageInfo_report") forState:UIControlStateNormal];
    _jubaoBTNnew.titleLabel.font = fontThin(15);
    [_jubaoBTNnew setTitleColor:RGB_COLOR(@"#959698", 1) forState:UIControlStateNormal];
    [_jubaoBTNnew addTarget:self action:@selector(doReport) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_jubaoBTNnew];
    [_jubaoBTNnew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(35);
    }];
    
    _guanliBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    [_guanliBTN setImage:[ImageBundle imagewithBundleName:@"userMsg_set"] forState:UIControlStateNormal];
    [_guanliBTN setTitleColor:UIColorFromRGB(0xff9216) forState:UIControlStateNormal];
    [_guanliBTN addTarget:self action:@selector(doGuanLi) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_guanliBTN];
    [_guanliBTN mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self);
        make.width.height.mas_equalTo(35);
    }];

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(topImageView.mas_bottom).mas_offset(3);
        make.height.equalTo(@15.5);
        make.width.equalTo(self).multipliedBy(0.5);
    }];
    //主播性别
    [self.sexIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.nameLabel.mas_right).mas_offset(3);
        make.width.height.equalTo(self.levelhostview.mas_height);
    }];
    //主播等级
    [self.levelhostview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.sexIcon.mas_right).mas_offset(3);;
        make.width.equalTo(self).multipliedBy(0.1);
        make.height.equalTo(_levelhostview.mas_width).multipliedBy(0.5);
    }];
    
    [self.levelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.left.equalTo(self.levelhostview.mas_right).mas_offset(3);;
        make.width.height.equalTo(self.levelhostview);
        //make.bottom.equalTo(self).multipliedBy(0.5);
    }];
    
    [self.IDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(14);
        make.height.equalTo(@9.5);
        make.width.equalTo(self).multipliedBy(0.5);
    }];
    
    [self.mapIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.IDLabel.mas_right).offset(6);
        make.centerY.equalTo(self.IDLabel);
        make.height.mas_equalTo(12);
        make.width.mas_equalTo(10);
    }];
    [self.cityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.IDLabel);
        make.left.equalTo(self.mapIcon.mas_right).offset(6);
    }];
    UIView *lineView1 = [[UIView alloc]init];
    lineView1.backgroundColor = RGB_COLOR(@"#eff0f1", 1);
    [self addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.IDLabel);
        make.width.mas_equalTo(1);
        make.height.equalTo(self.mapIcon).multipliedBy(1.2);
    }];
    
    [self.yinxiang1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self).multipliedBy(0.05);
    }];
    [self.yinxiang2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.yinxiang1.mas_height);
        make.centerY.equalTo(_yinxiang1.mas_centerY);
    }];
    [self.addYinXiang mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.yinxiang1.mas_height);
        make.centerY.equalTo(_yinxiang1.mas_centerY);
        make.width.mas_equalTo(80);
    }];

    NSArray *array = @[YZMsg(@"homepageController_attention"),
                       [NSString stringWithFormat:@"%@",YZMsg(@"upmessageInfo_sended")],
                       YZMsg(@"public_fans"),
                       [NSString stringWithFormat:@"%@",YZMsg(@"upmessageInfo_income")]];
    for (int i = 0; i<array.count; i++) {
        UILabel *label1 = [[UILabel alloc]init];
        label1.font = [UIFont boldSystemFontOfSize:25];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.textColor = RGB_COLOR(@"#333333", 1);
        label1.text = @"0";
        [self addSubview:label1];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).multipliedBy(0.6+(i/2)*0.15);
            make.width.equalTo(self).multipliedBy(0.5);
            make.left.equalTo(self).offset((i%2)*headerHeight);
        }];
        
        UILabel *label2 = [[UILabel alloc]init];
        label2.font = fontThin(13);
        label2.textAlignment = NSTextAlignmentCenter;
        label2.text = array[i];
        label2.textColor = RGB_COLOR(@"#999999", 1);
        [self addSubview:label2];
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.equalTo(label1);
            make.top.equalTo(label1.mas_bottom).offset(5);
        }];
        if (i == 0) {
            self.forceLabel = label1;
        }
        if (i == 1) {
            self.payLabel = label1;
        }
        if (i == 2) {
            self.fansLabel = label1;
        }
        if (i == 3) {
            self.incomeLabel = label1;
//            UIView *lineView2 = [[UIView alloc]init];
//            lineView2.backgroundColor = RGB_COLOR(@"#eff0f1", 1);
//            [self addSubview:lineView2];
//            [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.equalTo(self);
//                //                make.centerY.equalTo(self).multipliedBy(1.5);
//                make.width.mas_equalTo(1);
//                //                make.height.equalTo(self).multipliedBy(7/40.000);
//                make.top.equalTo(_fansLabel.mas_bottom).offset(-3);
//                make.bottom.equalTo(label2.mas_bottom).offset(-5);
//            }];

        }

    }
    _lastLine = [[UIView alloc]init];
    _lastLine.backgroundColor = RGB_COLOR(@"#eff0f1", 1);
    [self addSubview:_lastLine];
    [_lastLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).multipliedBy(1.8);
        make.width.equalTo(self);
        make.height.mas_equalTo(1);
    }];
   

    [self layoutIfNeeded];
    _iconImageView.layer.cornerRadius = _iconImageView.width/2;
    _iconImageView.layer.masksToBounds = YES;
    _guanliBTN.hidden   = YES;
    _jubaoBTNnew.hidden = YES;
    userW = self.frame.size.width;
    
}
- (void)updateLiveMessageInfo{
    [self.forceBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.width.mas_equalTo(self.frame.size.width/3);
        make.left.equalTo(self.mas_left);
        make.height.equalTo(self).multipliedBy(0.1);
    }];
    [self.messageBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.forceBtn);
        make.width.mas_equalTo(self.frame.size.width/3);
        make.left.equalTo(self.forceBtn.mas_right);
        make.height.equalTo(self).multipliedBy(0.1);
    }];
    [self.homeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.forceBtn);
        make.width.mas_equalTo(self.frame.size.width/3);
        make.left.equalTo(self.messageBtn.mas_right);
        make.height.equalTo(self).multipliedBy(0.1);
    }];
}

- (void)updateCustomerMessageInfo{
    [self.forceBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.width.mas_equalTo(self.frame.size.width/2);
        make.left.equalTo(self.mas_left);
        make.height.equalTo(self).multipliedBy(0.1);
    }];
    [self.homeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.forceBtn);
        make.width.mas_equalTo(self.frame.size.width/2);
        make.left.equalTo(self.forceBtn.mas_right);
        make.height.equalTo(self).multipliedBy(0.1);
    }];
}
- (void)updateSelfMessageInfo{
    [self.homeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.width.mas_equalTo(self.frame.size.width);
        make.left.equalTo(self.mas_left);
        make.height.equalTo(self).multipliedBy(0.1);
    }];
}
-(void)getUpmessgeinfo:(NSDictionary *)userDic andzhuboModel:(hotModel *)zhuboModel{
    self.zhuboModel = zhuboModel;
    
    if([self.zhuboModel.zhuboID isEqualToString:[Config getOwnID]]){
        [self.forceBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom);
            make.width.mas_equalTo(self.frame.size.width/3);
            make.left.equalTo(self.mas_left);
            make.height.equalTo(self).multipliedBy(0.1);
        }];
        [self.messageBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.forceBtn);
            make.width.mas_equalTo(self.frame.size.width/3);
            make.left.equalTo(self.forceBtn.mas_right);
            make.height.equalTo(self).multipliedBy(0.1);
        }];
        [self.homeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.forceBtn);
            make.width.mas_equalTo(self.frame.size.width/3);
            make.left.equalTo(self.messageBtn.mas_right);
            make.height.equalTo(self).multipliedBy(0.1);
        }];
    }else{
        [self.forceBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom);
            make.width.mas_equalTo(self.frame.size.width/2);
            make.left.equalTo(self.mas_left);
            make.height.equalTo(self).multipliedBy(0.1);
        }];
        [self.homeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.forceBtn);
            make.width.mas_equalTo(self.frame.size.width/2);
            make.left.equalTo(self.forceBtn.mas_right);
            make.height.equalTo(self).multipliedBy(0.1);
        }];
    }
    self.userID = [NSString stringWithFormat:@"%@",[userDic valueForKey:@"id"]];
    //如果点开的是自己
    NSString *userID = [NSString stringWithFormat:@"%@",[userDic valueForKey:@"id"]];
    //判断点击y的用户，并更新约束 (0->主播点自己) (1->自己点自己.非主播) (2->用户点用户) (3->用户点主播) (4->主播点用户)
    if ([userID isEqual:[Config getOwnID]]) {
        _forceBtn.hidden = YES;
        _messageBtn.hidden = YES;
        if ([userID isEqual:minstr(zhuboModel.zhuboID)]) {
            [self uoloadMasonryForState:0];
        }else{
            [self uoloadMasonryForState:1];
        }
    }
    else
    {
        _forceBtn.hidden = NO;
        _messageBtn.hidden = NO;
        if ([userID isEqual:minstr(zhuboModel.zhuboID)]) {
            [self uoloadMasonryForState:3];
        }else{
            if ([[Config getOwnID] isEqual:minstr(zhuboModel.zhuboID)]) {
                [self uoloadMasonryForState:4];
            }else{
                [self uoloadMasonryForState:2];
            }
        }

    }
    [self getinfomessage2:[userDic valueForKey:@"id"]];
}
-(void)getinfomessage2:(NSString *)selectedID{
    _guanliArrays = [NSArray array];
    NSDictionary *getPop = @{
                             @"uid":[Config getOwnID],
                             @"touid":selectedID,
                             @"liveuid":self.zhuboModel.zhuboID
                             };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.getPop" withBaseDomian:YES andParameter:getPop data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            NSArray *singleUserArray = [info firstObject];
            //头像
            [strongSelf.iconImageView sd_setImageWithURL:[NSURL URLWithString:[singleUserArray valueForKey:@"avatar"]] placeholderImage:[ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"]];
            //ID
            
            NSString *liangname = [NSString stringWithFormat:@"%@",[[singleUserArray valueForKey:@"liang"] valueForKey:@"name"]];
            if ([liangname isEqual:@"0"]) {
                strongSelf.IDLabel.text = [NSString stringWithFormat:@"ID:%@",[singleUserArray valueForKey:@"id"]];
                
            }else{
                strongSelf.IDLabel.text = [NSString stringWithFormat:@"%@:%@",YZMsg(@"public_liang"),liangname];
            }
            //姓名
            strongSelf->userName = [singleUserArray valueForKey:@"user_nicename"];
            strongSelf.nameLabel.text = [NSString stringWithFormat:@"%@%@",[singleUserArray valueForKey:@"user_nicename"],@"  "];
            strongSelf.seleIcon = [singleUserArray valueForKey:@"avatar"];
            strongSelf.seleID = [singleUserArray valueForKey:@"id"];
            strongSelf.selename = [singleUserArray valueForKey:@"user_nicename"];
            
            //印象
            NSArray * yinxiangLabel = [singleUserArray valueForKey:@"label"];
            if (yinxiangLabel.count == 0) {
                [strongSelf.addYinXiang mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(strongSelf);
                }];
            }else{
                if (yinxiangLabel.count == 1) {
                    strongSelf.yinxiang1.text = minstr([yinxiangLabel[0] valueForKey:@"name"]);
                    UIColor *color = RGB_COLOR(minstr([yinxiangLabel[0] valueForKey:@"colour"]), 1);
                    strongSelf.yinxiang1.backgroundColor = color;
                    //                    _yinxiang1.layer.borderColor = color.CGColor;
                    CGFloat yinxiangWidth = [[YBToolClass sharedInstance] widthOfString:strongSelf.yinxiang1.text andFont:fontThin(12) andHeight:20];
                    if (strongSelf.addYinXiang.hidden) {
                        [strongSelf.yinxiang1 mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.width.mas_equalTo(yinxiangWidth+20);
                            make.centerX.equalTo(self);
                        }];

                    }else{
                        [strongSelf.yinxiang1 mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.width.mas_equalTo(yinxiangWidth+20);
                            make.centerX.equalTo(self).multipliedBy(0.7);
                        }];

                        [strongSelf.addYinXiang mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.left.equalTo(strongSelf.yinxiang1.mas_right).offset(5);
                        }];
                    }
                }else{
                    strongSelf.yinxiang1.text = minstr([yinxiangLabel[0] valueForKey:@"name"]);
                    UIColor *color1 = RGB_COLOR(minstr([yinxiangLabel[0] valueForKey:@"colour"]), 1);
                    strongSelf.yinxiang1.backgroundColor = color1;
                    CGFloat yinxiangWidth1 = [[YBToolClass sharedInstance] widthOfString:strongSelf.yinxiang1.text andFont:fontThin(12) andHeight:20];
                    
                    
                    strongSelf.yinxiang2.text = minstr([yinxiangLabel[1] valueForKey:@"name"]);
                    UIColor *color2 = RGB_COLOR(minstr([yinxiangLabel[1] valueForKey:@"colour"]), 1);
                    strongSelf.yinxiang2.backgroundColor = color2;
                    CGFloat yinxiangWidth2 = [[YBToolClass sharedInstance] widthOfString:strongSelf.yinxiang2.text andFont:fontThin(12) andHeight:20];

                    
                    if (strongSelf.addYinXiang.hidden) {
                        [strongSelf.yinxiang1 mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.width.mas_equalTo(yinxiangWidth1+20);
                            make.left.equalTo(self.mas_left).offset(5);
                        }];
                        [strongSelf.yinxiang2 mas_updateConstraints:^(MASConstraintMaker *make) {
                            make.width.mas_equalTo(yinxiangWidth2+20);
                            make.left.equalTo(self.yinxiang1.mas_right).offset(5);
                        }];

                    }else{
                        CGFloat yinxiangWidth = yinxiangWidth1 + yinxiangWidth2 + 20 + 40 + strongSelf.addYinXiang.width;
                        if (yinxiangWidth > self.width) {
                            strongSelf.yinxiang2.hidden = YES;
                            [strongSelf.yinxiang1 mas_updateConstraints:^(MASConstraintMaker *make) {
                                make.width.mas_equalTo(yinxiangWidth1+20);
                                make.left.equalTo(strongSelf.mas_left).offset(5);
                            }];
                            [strongSelf.addYinXiang mas_updateConstraints:^(MASConstraintMaker *make) {
                                make.left.equalTo(strongSelf.yinxiang1.mas_right).offset(5);
                            }];
                        }else{
                            strongSelf.yinxiang2.hidden = NO;
                            [strongSelf.yinxiang1 mas_updateConstraints:^(MASConstraintMaker *make) {
                                make.width.mas_equalTo(yinxiangWidth1+20);
                                make.left.equalTo(strongSelf.mas_left).offset(5);
                            }];
                            
                            [strongSelf.yinxiang2 mas_updateConstraints:^(MASConstraintMaker *make) {
                                make.width.mas_equalTo(yinxiangWidth2+20);
                                make.left.equalTo(strongSelf.yinxiang1.mas_right).offset(5);
                            }];
                            
                            [strongSelf.addYinXiang mas_updateConstraints:^(MASConstraintMaker *make) {
                                make.left.equalTo(strongSelf.yinxiang2.mas_right).offset(5);
                            }];
                        }
                    }
                
                }

            }
            //数据信息
            NSString *currencyPayCoin = [YBToolClass getRateCurrency:minstr([singleUserArray valueForKey:@"consumption"]) showUnit:YES];
            if ([currencyPayCoin intValue] > 10000) {
                NSString *attString = [NSString stringWithFormat:@"%.1f %@",[currencyPayCoin intValue]/10000.0,YZMsg(@"upmessageInfo_ten_thousand")];
                [strongSelf.payLabel setAttributedText:[strongSelf fuwenben:attString]];

            }else{
                strongSelf.payLabel.text = currencyPayCoin;
            }
            if ([minstr([singleUserArray valueForKey:@"fans"]) intValue] > 10000) {
                NSString *attString = [NSString stringWithFormat:@"%.1f %@",[minstr([singleUserArray valueForKey:@"fans"]) intValue]/10000.0,YZMsg(@"upmessageInfo_ten_thousand")];
                [strongSelf.fansLabel setAttributedText:[strongSelf fuwenben:attString]];
                
            }else{
                strongSelf.fansLabel.text = minstr([singleUserArray valueForKey:@"fans"]);
            }

            NSString *currencyVotesCoin = [YBToolClass getRateCurrency:minstr([singleUserArray valueForKey:@"votestotal"]) showUnit:YES];
            if ([currencyVotesCoin intValue] > 10000) {
                NSString *attString = [NSString stringWithFormat:@"%.1f %@",[currencyVotesCoin intValue]/10000.0,YZMsg(@"upmessageInfo_ten_thousand")];
                [strongSelf.incomeLabel setAttributedText:[strongSelf fuwenben:attString]];
                
            }else{
                strongSelf.incomeLabel.text = currencyVotesCoin;
            }
            if ([minstr([singleUserArray valueForKey:@"follows"]) intValue] > 10000) {
                NSString *attString = [NSString stringWithFormat:@"%.1f %@",[minstr([singleUserArray valueForKey:@"follows"]) intValue]/10000.0,YZMsg(@"upmessageInfo_ten_thousand")];
                [strongSelf.forceLabel setAttributedText:[strongSelf fuwenben:attString]];
            }else{
                strongSelf.forceLabel.text = minstr([singleUserArray valueForKey:@"follows"]);
            }


            //性别
            NSString *sex = [NSString stringWithFormat:@"%@",[singleUserArray valueForKey:@"sex"]];
            if ([sex isEqual:@"1"]) {
                strongSelf.sexIcon.image = [ImageBundle imagewithBundleName:@"sex_man"];
            }
            else{
                strongSelf.sexIcon.image = [ImageBundle imagewithBundleName:@"sex_woman"];//性别
            }
            //等级
            NSDictionary *levelDic = [common getUserLevelMessage:minstr([singleUserArray valueForKey:@"level"])];
            [strongSelf.levelView sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]];
            NSDictionary *levelDic1 = [common getAnchorLevelMessage:minstr([singleUserArray valueForKey:@"level_anchor"])];
            [strongSelf.levelhostview sd_setImageWithURL:[NSURL URLWithString:minstr([levelDic1 valueForKey:@"thumb"])]];
            

//            _levelView.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"leve%@.png",[NSString stringWithFormat:@"%@",[singleUserArray valueForKey:@"level"]]]];
//            _levelhostview.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"host_%@.png",[NSString stringWithFormat:@"%@",[singleUserArray valueForKey:@"level_anchor"]]]];
            NSString *cityfu = [NSString stringWithFormat:@"%@",[singleUserArray valueForKey:@"city"]];
            //位置
            if ([[singleUserArray valueForKey:@"city"] isEqual:[NSNull null]] || [[singleUserArray valueForKey:@"city"] isEqual:@"null"] || [[singleUserArray valueForKey:@"city"] isEqual:@"(null)"] || [singleUserArray valueForKey:@"city"] == NULL || [singleUserArray valueForKey:@"city"] == nil) {
                strongSelf.cityLabel.text = YZMsg(@"upmessageInfo_on_Mars");
            }
            else if (cityfu.length == 0){
                strongSelf.cityLabel.text = YZMsg(@"upmessageInfo_on_Mars");
            }
            else{
                strongSelf.cityLabel.text = [NSString stringWithFormat:@"%@",[singleUserArray valueForKey:@"city"]];//地址
            }
            NSString *isattention = [NSString stringWithFormat:@"%@",[singleUserArray valueForKey:@"isattention"]];
            //判断关注
            if ([isattention isEqual:@"0"]) {
                [strongSelf.forceBtn setTitle:YZMsg(@"homepageController_attention") forState:UIControlStateNormal];
                [strongSelf.forceBtn setTitleColor:RGB_COLOR(@"#333333", 1) forState:UIControlStateNormal];
//                _forceBtn.enabled = YES;
            }
            else{
                [strongSelf.forceBtn setTitle:YZMsg(@"upmessageInfo_followed") forState:UIControlStateNormal];
                [strongSelf.forceBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
//                _forceBtn.enabled = NO;
            }
            //判断管理 操作显示，0表示自己，30表示普通用户，40表示管理员，501表示主播设置管理员，502表示主播取消管理员，60表示超管管理主播
            NSString *action = [NSString stringWithFormat:@"%@",[singleUserArray valueForKey:@"action"]];
            
            if ([action isEqual:@"0"]) {
                strongSelf.guanliBTN.hidden = YES;
                strongSelf.jubaoBTNnew.hidden = YES;
                //自己
            }else if ([action isEqual:@"30"]){
                strongSelf.guanliBTN.hidden = YES;
                strongSelf.jubaoBTNnew.hidden = NO;
                //普通用户
            }else if ([action isEqual:@"40"]){
                strongSelf.guanliBTN.hidden = NO;
                strongSelf.jubaoBTNnew.hidden = YES;
                strongSelf.guanliArrays = @[YZMsg(@"upmessageInfo_kick"),YZMsg(@"upmessageInfo_silent")];
                //管理员
            }else if ([action isEqual:@"501"]){
                strongSelf.guanliBTN.hidden = NO;
                strongSelf.jubaoBTNnew.hidden = YES;
                strongSelf.guanliArrays = @[YZMsg(@"upmessageInfo_kick"),YZMsg(@"upmessageInfo_silent"),YZMsg(@"upmessageInfo_set_management"),YZMsg(@"upmessageInfo_management_list")];
                //主播设置管理员
            }else if ([action isEqual:@"502"]){
                strongSelf.guanliBTN.hidden = NO;
                strongSelf.jubaoBTNnew.hidden = YES;
                strongSelf.guanliArrays = @[YZMsg(@"upmessageInfo_kick"),YZMsg(@"upmessageInfo_silent"),YZMsg(@"upmessageInfo_cancel_management"),YZMsg(@"upmessageInfo_management_list")];
                //主播取消管理员
            }else if ([action isEqual:@"60"]){
                //超管管理主播
                strongSelf.guanliBTN.hidden = NO;
                strongSelf.jubaoBTNnew.hidden = YES;
                strongSelf.guanliArrays = @[YZMsg(@"upmessageInfo_close_live"),YZMsg(@"upmessageInfo_disable_live")];
            }

        }
    } fail:^(NSError * _Nonnull error) {
        
    }];
}
#pragma mark ================ 富文本 ===============
- (NSMutableAttributedString *)fuwenben:(NSString *)str{
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:str];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:9] range:NSMakeRange(str.length-1, 1)];
    return attStr;
}
//这是弹窗的事件
-(void)doGuanLi{
//    UIAlertController *adminAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    for (NSString *str in _guanliArrays) {
//        UIAlertAction *action = [UIAlertAction actionWithTitle:str style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            if ([str isEqual:@"踢人"]) {
//                [self kickuser];
//            }
//            if ([str isEqual:@"禁言"]) {
//                [self jinyan];
//            }
//            if ([str isEqual:@"关闭直播"]) {
//                [self superStopRoom];
//            }
//            if ([str isEqual:@"禁用直播"]) {
//                [self superCloseRoom];
//            }
//            if ([str isEqual:@"设为管理"]) {
//                [self setAdmin];;
//            }
//            if ([str isEqual:@"取消管理"]) {
//                [self setAdmin];;
//            }
//            if ([str isEqual:@"管理员列表"]) {
//                [self adminLIst];
//            }
//        }];
//        [adminAlert addAction:action];
//
//    }
//    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:YZMsg(@"取消") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//    }];
//    [adminAlert addAction:cancleAction];

    
   
    if (_myActionSheet) {
        [_myActionSheet removeFromSuperview];
        _myActionSheet = nil;
    }
    CGSize winsize = [UIScreen mainScreen].bounds.size;
    CGFloat x;
    x = 0;
    _myActionSheet = [[CSActionSheet alloc] initWithFrame:CGRectMake(x,0, winsize.width, winsize.height) titles:_guanliArrays cancal:YZMsg(@"public_cancel") normal_color:[UIColor blueColor] highlighted_color:[UIColor blueColor] tips:nil tipsColor:[UIColor whiteColor] cellBgColor:[[UIColor whiteColor] colorWithAlphaComponent:0.9] cellLineColor:RGB_COLOR(@"#c3c4c5", 1)];
    
    [self.superview addSubview:_myActionSheet];
    WeakSelf
    [_myActionSheet showView:^(int index, id sender) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (index == 1)
        {
            if ([[strongSelf.guanliArrays firstObject] isEqualToString:YZMsg(@"upmessageInfo_close_live")]) {
                [strongSelf superStopRoom];
            }else{
                if ([[strongSelf.guanliArrays firstObject] isEqualToString:YZMsg(@"upmessageInfo_kick")]) {
                    
                    [strongSelf kickuser];
                }
            }
        }
        if (index == 2)
        {
            if ([[strongSelf.guanliArrays objectAtIndex:1] isEqualToString:YZMsg(@"upmessageInfo_disable_live")]) {
                [strongSelf superCloseRoom];
            }else{
                if ([[strongSelf.guanliArrays objectAtIndex:1] isEqualToString:YZMsg(@"upmessageInfo_silent")]) {
                    
                    [strongSelf jinyan];
                }
            }
        }
        if (index == 3)
        {
            if ([[strongSelf.guanliArrays objectAtIndex:2] isEqualToString:YZMsg(@"upmessageInfo_set_management")]||[[strongSelf.guanliArrays objectAtIndex:1] isEqualToString:YZMsg(@"upmessageInfo_cancel_management")]) {
                [strongSelf superCloseRoom];
            }

            [strongSelf setAdmin];
        }
        if (index == 4)
        {
            if ([[strongSelf.guanliArrays objectAtIndex:3] isEqualToString:YZMsg(@"upmessageInfo_management_list")]) {
                
                [strongSelf adminLIst];
            }
        }
        CSActionSheet *view1 = (CSActionSheet*)sender;
        [view1 hideView];
    }
                       close:^(id sender) {
        CSActionSheet *view1 = (CSActionSheet*)sender;
        if (view1) {
            [view1 removeFromSuperview];
            view1 = nil;
        }
    }];
    
}
//超管管理主播
-(void)superStopRoom{
    //关闭当前直播
    NSDictionary *setadmin = @{
                               @"uid":[Config getOwnID],
                               @"liveuid":self.zhuboModel.zhuboID,
                               @"type":@"0",
                               @"token":[Config getOwnToken]
                               };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.superStopRoom" withBaseDomian:YES andParameter:setadmin data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            [MBProgressHUD showError:[[info firstObject] valueForKey:@"msg"]];
            [strongSelf.upmessageDelegate superAdmin:@"0"];
        }
        [strongSelf.upmessageDelegate doupCancle];

    } fail:^(NSError * _Nonnull error) {
        
    }];
}
-(void)superCloseRoom{
    //超管关闭直播间并禁用主播账户
    NSDictionary *setadmin = @{
                               @"uid":[Config getOwnID],
                               @"liveuid":self.zhuboModel.zhuboID,
                               @"type":@"1",
                               @"token":[Config getOwnToken]
                               };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.superStopRoom" withBaseDomian:YES andParameter:setadmin data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            [MBProgressHUD showError:msg];
            [strongSelf.upmessageDelegate superAdmin:@"1"];

        }
        [strongSelf.upmessageDelegate doupCancle];

    } fail:^(NSError * _Nonnull error) {
        
    }];
}
-(void)adminLIst{
    [self.upmessageDelegate adminList];
}
-(void)setAdmin{
    NSDictionary *setadmin = @{
                             @"uid":[Config getOwnID],
                             @"liveuid":self.zhuboModel.zhuboID,
                             @"touid":self.userID,
                             @"token":[Config getOwnToken]
                             };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.setAdmin" withBaseDomian:YES andParameter:setadmin data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            NSString *isadmin = [NSString stringWithFormat:@"%@",[[info firstObject] valueForKey:@"isadmin"]];
            if ([isadmin isEqualToString:@"1"]) {
                
            }
            [strongSelf.upmessageDelegate setAdminSuccess:isadmin andName:strongSelf->userName andID:strongSelf.userID];
        }
        [strongSelf.upmessageDelegate doupCancle];

    } fail:^(NSError * _Nonnull error) {
        
    }];
    
}
//踢人
-(void)kickuser{
    
    NSDictionary *kickuser = @{
                             @"uid":[Config getOwnID],
                             @"liveuid":self.zhuboModel.zhuboID,
                             @"touid":self.userID,
                             @"token":[Config getOwnToken]
                             };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.kicking" withBaseDomian:YES andParameter:kickuser data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        if (code == 0) {
            if ([strongSelf.upmessageDelegate respondsToSelector:@selector(socketkickuser:andID:)]) {
                [strongSelf.upmessageDelegate socketkickuser:strongSelf->userName andID:strongSelf.userID];
            }
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        
    }];
}
//禁言
-(void)jinyan{
    //  User.setShutUp
    
    NSDictionary *shutup = @{
                             @"uid":[Config getOwnID],
                             @"liveuid":self.zhuboModel.zhuboID,
                             @"touid":self.userID,
                             @"token":[Config getOwnToken]
                             };
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"Live.setShutUp" withBaseDomian:YES andParameter:shutup data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            if ([strongSelf.upmessageDelegate respondsToSelector:@selector(socketShutUp:andID:)]) {
                [strongSelf.upmessageDelegate socketShutUp:strongSelf->userName andID:strongSelf.userID];
            }
        }
        else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        
    }];
}
//发送联系方式
-(void)sendContactInfo{
    if ([self.upmessageDelegate respondsToSelector:@selector(socketSendContactInfo:andID:)]) {
        [self.upmessageDelegate socketSendContactInfo:[Config getOwnContactInfo] andID:self.userID];
    }
    
//    NSDictionary *shutup = @{
//                             @"uid":[Config getOwnID],
//                             @"liveuid":[self.zhuboDic valueForKey:@"uid"],
//                             @"touid":self.userID,
//                             @"token":[Config getOwnToken]
//                             };
//
//    [YBToolClass postNetworkWithUrl:@"Live.setShutUp" andParameter:shutup success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
//        if (code == 0) {
//            if ([self.upmessageDelegate respondsToSelector:@selector(socketSendContactInfo:andID:)]) {
//
//                [self.upmessageDelegate socketSendContactInfo:[Config getOwnContactInfo] andID:self.userID];
//            }
//        }
//        else{
//            [MBProgressHUD showError:msg];
//        }
//    } fail:^{
//
//    }];
}
//设置取消关注
-(void)forceBtnClick{

    // User.setAttentionAnchor
    NSDictionary *attent = @{
                             @"touid":self.userID,
                             @"is_follow":[_forceBtn.titleLabel.text isEqualToString:YZMsg(@"homepageController_attention")]?@"1":@"0"
                             };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    [hud hideAnimated:YES afterDelay:10];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:@"User.setAttent" withBaseDomian:YES andParameter:attent data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        [MBProgressHUD hideHUDForView:self];
        [hud hideAnimated:YES];
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            NSDictionary *subdic = [info firstObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadLiveplayAttion" object:subdic];
            NSString *isattention = [NSString stringWithFormat:@"%@",[subdic valueForKey:@"isattent"]];
            //判断关注
            if ([isattention isEqual:@"0"]) {
                [strongSelf.forceBtn setTitle:YZMsg(@"homepageController_attention") forState:UIControlStateNormal];
                [strongSelf.forceBtn setTitleColor:normalColors forState:UIControlStateNormal];
            }
            else{
                [strongSelf.forceBtn setTitle:YZMsg(@"upmessageInfo_followed") forState:UIControlStateNormal];
                [strongSelf.forceBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
            [strongSelf getinfomessage2:strongSelf.userID];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [MBProgressHUD hideHUD];
    }];
    [MobClick event:@"live_room_unfollow_click" attributes:@{@"eventType": @(1)}];
}
-(void)homeBtnClick{
    [self.upmessageDelegate pushZhuYe:self.userID];
}
-(void)messageBtnClick{
    if ([_forceBtn.titleLabel.text isEqual:YZMsg(@"关注")]) {
        [self.upmessageDelegate siXin:_seleIcon andName:_selename andID:_seleID andIsatt:@"0"];
    }else{
        [self.upmessageDelegate siXin:_seleIcon andName:_selename andID:_seleID andIsatt:@"1"];
    }
    
}
- (void)addLabelClick{
    [self closeDetailView];
    [self.upmessageDelegate setLabel:self.userID];
    [MobClick event:@"live_room_anchor_impression_click" attributes:@{@"eventType": @(1)}];
}
#pragma mark ================ 更新约束 ===============

/**
 更新约束
 state: (0->主播点自己) (1->自己点自己.非主播) (2->用户点用户) (3->用户点主播) (4->主播点用户)
 @param state state
 */
- (void)uoloadMasonryForState:(int)state{
    if (state == 0) {
        _homeBtn.hidden = YES;
        _lastLine.hidden = YES;
        _yinxiang1.hidden = NO;
        _yinxiang2.hidden = NO;
        _addYinXiang.hidden = YES;
        [self updateSelfMessageInfo];
        [self.levelView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self).offset(_window_width*0.4);
//            make.width.height.equalTo(self.levelhostview);
//            make.bottom.equalTo(self).multipliedBy(0.5);
            make.centerY.equalTo(self.nameLabel);
            make.left.equalTo(self.levelhostview.mas_right).mas_offset(3);;
            make.width.height.equalTo(self.levelhostview);
        }];

        [self.IDLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(14);
            make.height.equalTo(@9.5);
            make.width.equalTo(self).multipliedBy(0.5);
        }];
        [self.yinxiang1 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.IDLabel.mas_bottom).mas_offset(12);
            //make.centerY.equalTo(self).multipliedBy(1.25);
        }];
        //关注
        [self.forceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.IDLabel.mas_bottom).offset(44.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.right.equalTo(self);
        }];
        //粉丝
        [self.fansLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.IDLabel.mas_bottom).offset(44.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.left.equalTo(self);
        }];
        //送出月牙
        [self.payLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.fansLabel.mas_bottom).offset(40.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.left.equalTo(self);
        }];
        //收入月牙
        [self.incomeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.forceLabel.mas_bottom).offset(40.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.right.equalTo(self);
        }];
    }
    
    if (state == 1) {
        _homeBtn.hidden = NO;
        _lastLine.hidden = NO;
        _yinxiang1.hidden = NO;
        _yinxiang2.hidden = NO;
        _addYinXiang.hidden = YES;
   
        [self updateSelfMessageInfo];
        
        [self.levelView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.nameLabel);
            make.left.equalTo(self.levelhostview.mas_right).mas_offset(3);;
            make.width.height.equalTo(self.levelhostview);
        }];
        
        [self.IDLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(14);
            make.height.equalTo(@9.5);
            make.width.equalTo(self).multipliedBy(0.5);
        }];
        //关注
        [self.forceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.IDLabel.mas_bottom).offset(44.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.right.equalTo(self);
        }];
        //粉丝
        [self.fansLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.IDLabel.mas_bottom).offset(44.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.left.equalTo(self);
        }];
        //送出月牙
        [self.payLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.fansLabel.mas_bottom).offset(40.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.left.equalTo(self);
        }];
        //收入月牙
        [self.incomeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.forceLabel.mas_bottom).offset(40.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.right.equalTo(self);
        }];
    }
    if (state == 2) {
        _homeBtn.hidden = NO;
        _lastLine.hidden = NO;
        _yinxiang1.hidden = NO;
        _yinxiang2.hidden = NO;
        _addYinXiang.hidden = YES;
        [self updateCustomerMessageInfo];
        
        [self.levelView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self).offset(_window_width*0.4);
//            make.width.height.equalTo(self.levelhostview);
//            make.bottom.equalTo(self).multipliedBy(0.5);
            make.centerY.equalTo(self.nameLabel);
            make.left.equalTo(self.levelhostview.mas_right).mas_offset(3);;
            make.width.height.equalTo(self.levelhostview);
        }];
        
        [self.IDLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(14);
            make.height.equalTo(@9.5);
            make.width.equalTo(self).multipliedBy(0.5);
        }];
        //关注
        [self.forceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.IDLabel.mas_bottom).offset(44.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.right.equalTo(self);
        }];
        //粉丝
        [self.fansLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.IDLabel.mas_bottom).mas_offset(44.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.left.equalTo(self);
        }];
        //送出月牙
        [self.payLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.fansLabel.mas_bottom).offset(40.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.left.equalTo(self);
        }];
        //收入月牙
        [self.incomeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.forceLabel.mas_bottom).offset(40.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.right.equalTo(self);
        }];
    }
    if (state == 3) {
        _homeBtn.hidden = NO;
        _lastLine.hidden = NO;
        _yinxiang1.hidden = NO;
        _yinxiang2.hidden = NO;
        _addYinXiang.hidden = NO;
        
        [self updateCustomerMessageInfo];
    

        [self.levelView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self).offset(_window_width*0.4);
//            make.width.height.equalTo(self.levelhostview);
//            make.bottom.equalTo(self).multipliedBy(0.49);
            make.centerY.equalTo(self.nameLabel);
            make.left.equalTo(self.levelhostview.mas_right).mas_offset(3);
            make.width.height.equalTo(self.levelhostview);
        }];
        
        [self.IDLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(14);
            make.height.equalTo(@9.5);
            make.width.equalTo(self).multipliedBy(0.5);
        }];
        
        
        [self.yinxiang1 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.IDLabel.mas_bottom).mas_offset(12);
           // make.centerY.equalTo(self).multipliedBy(1.2);
        }];
        //关注
        [self.forceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.IDLabel.mas_bottom).offset(44.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.right.equalTo(self);
        }];
        //粉丝
        [self.fansLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.IDLabel.mas_bottom).offset(44.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.left.equalTo(self);
        }];
        //送出月牙
        [self.payLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.fansLabel.mas_bottom).offset(40.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.left.equalTo(self);
        }];
        //收入月牙
        [self.incomeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.forceLabel.mas_bottom).offset(40.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.right.equalTo(self);
        }];
    }
    if (state == 4) {
        _homeBtn.hidden = NO;
        _lastLine.hidden = NO;
        _yinxiang1.hidden = NO;
        _yinxiang2.hidden = NO;
        _addYinXiang.hidden = YES;
        
        [self updateLiveMessageInfo];
     
        [self.levelView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self).offset(_window_width*0.4);
//            make.width.height.equalTo(self.levelhostview);
//            make.bottom.equalTo(self).multipliedBy(0.5);
            make.centerY.equalTo(self.nameLabel);
            make.left.equalTo(self.levelhostview.mas_right).mas_offset(3);;
            make.width.height.equalTo(self.levelhostview);
        }];
        
        [self.IDLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(14);
            make.height.equalTo(@9.5);
            make.width.equalTo(self).multipliedBy(0.5);
        }];
        //关注
        [self.forceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.IDLabel.mas_bottom).offset(44.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.right.equalTo(self);
        }];
        //粉丝
        [self.fansLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.IDLabel.mas_bottom).offset(44.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.left.equalTo(self);
        }];
        //送出月牙
        [self.payLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.fansLabel.mas_bottom).offset(43.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.left.equalTo(self);
        }];
        //收入月牙
        [self.incomeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.forceLabel.mas_bottom).offset(43.5);
            make.width.equalTo(self).multipliedBy(0.5);
            make.right.equalTo(self);
        }];
    }

}
#pragma mark ================ c懒加载 ===============
//MARK:-SetUI
-(UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc]init];
        [_iconImageView setClipsToBounds:YES];
        _iconImageView.layer.masksToBounds = YES;
        [_iconImageView sizeToFit];
        self.iconImageView = _iconImageView;
        [self addSubview:_iconImageView];
    }
    return _iconImageView;
}
-(UIImageView *)iconBackView
{
    if (!_iconBackView) {
        _iconBackView = [[UIImageView alloc]init];
        [_iconBackView setClipsToBounds:NO];
        _iconBackView.layer.masksToBounds = NO;
        _iconBackView.layer.cornerRadius = 37;
        [_iconBackView sizeToFit];
        self.iconBackView = _iconBackView;
        [self addSubview:_iconBackView];
    }
    return _iconBackView;
}
-(UIImageView *)sexIcon
{
    if (!_sexIcon) {
        _sexIcon = [[UIImageView alloc]init];
        _sexIcon.backgroundColor = [UIColor whiteColor];
        [_sexIcon setContentMode:UIViewContentModeScaleAspectFit];
        self.sexIcon = _sexIcon;
        [self addSubview:_sexIcon];
    }
    return _sexIcon;
}
//名字label
-(UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.textColor = RGB_COLOR(@"#333333", 1);
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nameLabel.textAlignment = NSTextAlignmentRight;
        self.nameLabel = _nameLabel;
        [self addSubview:_nameLabel];}
    return _nameLabel;
}
-(UIImageView *)levelView
{
    if (!_levelView) {
        _levelView = [[UIImageView alloc]init];
        _levelView.backgroundColor = [UIColor whiteColor];
        self.levelView = _levelView;
        [self addSubview:_levelView];
    }
    return _levelView;
}
-(UIImageView *)levelhostview
{     if (!_levelhostview) {
    _levelhostview = [[UIImageView alloc]init];
    self.levelhostview = _levelhostview;
    [self addSubview:_levelhostview];
}
    return _levelhostview;
}

-(UILabel *)IDLabel
{
    if (!_IDLabel)
    {
        _IDLabel = [[UILabel alloc]init];
        _IDLabel.textColor = RGB_COLOR(@"#999999", 1);
        _IDLabel.font = fontThin(12);
        _IDLabel.textAlignment = NSTextAlignmentRight;
        self.IDLabel = _IDLabel;
        _IDLabel.text = @" ";
        [self addSubview:_IDLabel];
    }
    return _IDLabel;
}
-(UIImageView *)mapIcon
{
    if (!_mapIcon) {
        _mapIcon = [[UIImageView alloc]init];
        _mapIcon.image = [ImageBundle imagewithBundleName:@"img_wz"];
        self.mapIcon = _mapIcon;
        [self addSubview:_mapIcon];
    }
    return _mapIcon;
}
-(UILabel *)cityLabel
{
    if (!_cityLabel) {
        _cityLabel = [[UILabel alloc]init];
        _cityLabel.textColor = UIColorFromRGB(0xb0b0b0);
        _cityLabel.font = fontThin(14);;
        _cityLabel.text = @"";
        self.cityLabel = _cityLabel;
        [self addSubview:_cityLabel];}
    return _cityLabel;
}
-(UILabel *)yinxiang1{
    if (!_yinxiang1) {
        _yinxiang1 = [[UILabel alloc]init];
        _yinxiang1.hidden = YES;
        _yinxiang1.font = fontThin(12);;
        _yinxiang1.layer.masksToBounds = YES;
        _yinxiang1.layer.cornerRadius = 3.0;
//        _yinxiang1.layer.borderWidth = 1;
        _yinxiang1.textColor = [UIColor whiteColor];
        _yinxiang1.textAlignment = NSTextAlignmentCenter;
        self.yinxiang1 = _yinxiang1;
        [self addSubview:_yinxiang1];
    }
    return _yinxiang1;
    
}
-(UILabel *)yinxiang2{
    if (!_yinxiang2) {
        _yinxiang2 = [[UILabel alloc]init];
        _yinxiang2.font = fontThin(12);;
        _yinxiang2.layer.masksToBounds = YES;
        _yinxiang2.layer.cornerRadius = 3.0;
//        _yinxiang2.layer.borderWidth = 1;
        _yinxiang2.textColor = [UIColor whiteColor];
        _yinxiang2.textAlignment = NSTextAlignmentCenter;
        self.yinxiang2 = _yinxiang2;
        [self addSubview:_yinxiang2];
    }
    return _yinxiang2;
    
}
-(UIButton *)addYinXiang
{
    if (!_addYinXiang) {
        _addYinXiang = [self YBBottomButton:_forceBtn title:YZMsg(@"upmessageInfo_add_the_impression+") titleColor:RGB_COLOR(@"#FF0072", 1) titleFont:11];
        [_addYinXiang addTarget:self action:@selector(addLabelClick) forControlEvents:UIControlEventTouchUpInside];
        _addYinXiang.layer.masksToBounds = YES;
        _addYinXiang.layer.cornerRadius = 3.0;
        _addYinXiang.layer.borderWidth = 0.5;
        _addYinXiang.hidden =YES;
        _addYinXiang.layer.borderColor = RGB_COLOR(@"#FF0072", 1).CGColor;
        self.addYinXiang = _addYinXiang;
    }
    return _addYinXiang;
}

-(UIButton *)forceBtn
{
    if (!_forceBtn) {
        _forceBtn = [self YBBottomButton:_forceBtn title:YZMsg(@"homepageController_attention") titleColor:NULL titleFont:16];
        [_forceBtn addTarget:self action:@selector(forceBtnClick) forControlEvents:UIControlEventTouchUpInside];
        self.forceBtn = _forceBtn;
    }
    return _forceBtn;
}
-(UIButton *)messageBtn
{
    if (!_messageBtn) {
        _messageBtn = [self YBBottomButton:_messageBtn title:YZMsg(@"upmessageInfo_Send_a_card") titleColor:NULL titleFont:16];
        [_messageBtn addTarget:self action:@selector(sendContactInfo) forControlEvents:UIControlEventTouchUpInside];
        self.messageBtn = _messageBtn;
    }
    return  _messageBtn;
}
-(UIButton *)homeBtn
{
    if (!_homeBtn) {
        _homeBtn = [self YBBottomButton:_homeBtn title:YZMsg(@"upmessageInfo_HomeTitle") titleColor:NULL titleFont:16];
        [_homeBtn addTarget:self action:@selector(homeBtnClick) forControlEvents:UIControlEventTouchUpInside];
        self.homeBtn = _homeBtn;
    }
    return _homeBtn;
}

- (UIButton *)YBBottomButton:(UIButton *)button  title:(NSString *)title titleColor:(nullable UIColor *)color titleFont:(CGFloat)titleFont  {
    if (!button) {
        button = [[UIButton alloc]init];
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.minimumScaleFactor = 0.5;
        if (color) {
            [button setTitleColor:color forState:UIControlStateNormal];
        }else{
            [button setTitleColor:RGB_COLOR(@"#333333", 1) forState:UIControlStateNormal];
        }
        if ([button.titleLabel.text containsString:YZMsg(@"upmessageInfo_add_the_impression")]) {
            button.titleLabel.font = [UIFont systemFontOfSize:titleFont weight:UIFontWeightRegular];
        }else{
            button.titleLabel.font = [UIFont boldSystemFontOfSize:titleFont];
        }
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:button];
    }
    return button;
}


@end
