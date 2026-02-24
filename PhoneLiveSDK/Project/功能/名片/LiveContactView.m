//
//  LiveContactView.m
//  phonelive2
//
//  Created by test on 2021/5/27.
//  Copyright © 2021 toby. All rights reserved.
//

#import "LiveContactView.h"
#import "GGProgressView.h"
#import "UIImageView+WebCache.h"
@interface LiveContactView()
@property (weak, nonatomic) IBOutlet UIView *idInfoView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *infoBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoBackgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *lb_contactTitle;
@property (weak, nonatomic) IBOutlet UIImageView *iv_anchorIcon;
@property (weak, nonatomic) IBOutlet UILabel *lb_anchorContact;
@property (strong,nonatomic)GGProgressView *progress;
@property (weak, nonatomic) IBOutlet UIView *v_progress;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_contentCenterY;
@property (weak, nonatomic) IBOutlet UILabel *lb_tigs;
@property (weak, nonatomic) IBOutlet UILabel *liveContacsubTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactProgressTitle;
@property (weak, nonatomic) IBOutlet UILabel *contactSubTitle1;
@property (weak, nonatomic) IBOutlet UILabel *contactSubTitle2;
@property (weak, nonatomic) IBOutlet UILabel *contactSubTitle3;
@property (weak, nonatomic) IBOutlet UIButton *getButton;
@property (nonatomic,strong)UILabel *lb_progress;
//进度及要求面板
@property (weak, nonatomic) IBOutlet UIView *v_pgBack;
@property (strong,nonatomic)NSString *anchorContact;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_pgsRightMargin;
@property (weak, nonatomic) IBOutlet UIStackView *logoStackView;
@end

@implementation LiveContactView
- (void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundImageView.image = [self resizeImage:@"anchor_bg" type:1];
    self.infoBackgroundImageView.image = [self resizeImage:@"anchor_purple" type:0];
    self.logoBackgroundImageView.image = [self resizeImage:@"anchor_cover" type:0];


    self.liveContacsubTitleLabel.text = YZMsg(@"LiveContactView_ConatctTitle1");
    self.contactProgressTitle.text = YZMsg(@"LiveContactView_ConatctTitle2");
    self.contactSubTitle1.text = YZMsg(@"LiveContactView_ConatctTitle3");
    self.contactSubTitle2.text = YZMsg(@"LiveContactView_ConatctTitle4");
    self.contactSubTitle3.text = YZMsg(@"LiveContactView_ConatctTitle5");
    [self.getButton setImage:[ImageBundle imagewithBundleName:YZMsg(@"LiveContactView_ContactGetIcon")]  forState:UIControlStateNormal];
    self.lb_anchorContact.adjustsFontSizeToFitWidth = YES;
    self.lb_anchorContact.minimumScaleFactor = 0.3;
    //添加
    self.lb_progress = [[UILabel alloc]initWithFrame:self.v_progress.bounds];
    self.lb_progress.textColor = [UIColor redColor];
    self.lb_progress.font = [UIFont systemFontOfSize:12];
    self.lb_progress.textAlignment = NSTextAlignmentCenter;
    [self.v_progress addSubview:self.lb_progress];
    //送礼按钮
    UIButton *btn_gift = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_gift.frame = CGRectMake(self.v_pgBack.width - 31,42, 25,25);
    btn_gift.tag = 1125;
    btn_gift.hidden = YES;
    btn_gift.tintColor = [UIColor whiteColor];
    [btn_gift setBackgroundImage:[ImageBundle imagewithBundleName:@"anchor_liwu"] forState:UIControlStateNormal];
    [btn_gift addTarget:self action:@selector(sendLiwu:) forControlEvents:UIControlEventTouchUpInside];
    [self.v_pgBack addSubview:btn_gift];
    [self startWobbleWithView:btn_gift];
}

- (UIImage*)resizeImage:(NSString*)name type:(int)type {
    UIImage *resizeImage = [ImageBundle imagewithBundleName:name];
    resizeImage = [resizeImage initWithCGImage:resizeImage.CGImage scale:2.0 orientation:UIImageOrientationUp];
    CGFloat top = resizeImage.size.height/2.0;
    CGFloat bottom = resizeImage.size.height/2.0;
    CGFloat left = resizeImage.size.width/2.0;
    CGFloat right = resizeImage.size.width/2.0;

    UIEdgeInsets insets;
    if (type == 1) {
        insets = UIEdgeInsetsMake(resizeImage.size.height/4.0, 0, 0, 0);
    } else {
        insets = UIEdgeInsetsMake(top, left, bottom, right);
    }
    resizeImage = [resizeImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    return resizeImage;
}

+ (LiveContactView *)showContactWithAnimationAddto:(UIView *)superView liver:(hotModel *)liver setDelegate:(id<LiveContactView>)delegate{
    LiveContactView *contact = [[[XBundle currentXibBundleWithResourceName:@"LiveContactView"] loadNibNamed:@"LiveContactView" owner:nil options:nil] lastObject];
    contact.frame = CGRectMake(_window_width, 0, _window_width, _window_height);
    contact.layout_contentCenterY.constant = _window_height;
    contact.delegate = delegate;
    [contact layoutIfNeeded];
    [superView addSubview:contact];
    [UIView animateWithDuration:0.5 animations:^{
        contact.layout_contentCenterY.constant = 0;
        [contact layoutIfNeeded];
    }];
    [contact.iv_anchorIcon sd_setImageWithURL:[NSURL URLWithString:liver.zhuboIcon] placeholderImage:[ImageBundle imagewithBundleName:@"anchor_w_circle"]];
    contact.lb_contactTitle.text = [NSString stringWithFormat:YZMsg(@"LiveContactView_WhoName%@"),liver.zhuboName];
    [contact requestDatasWithLiver:liver.zhuboID];
    return contact;
}
//送礼达标ui
- (void)getArchiveUI{
    self.layout_pgsRightMargin.constant = 12;
    if (self.progress) {
        [self.progress removeFromSuperview];
    }
    [self.v_pgBack layoutIfNeeded];
    self.progress = [[GGProgressView alloc]initWithFrame:self.v_progress.bounds progressViewStyle:GGProgressViewStyleAllFillet];
    self.progress.progressTintColor = RGB_COLOR(@"#EAB26C", 1);
    self.progress.trackTintColor = [UIColor whiteColor];
    [self.v_progress insertSubview:self.progress atIndex:0];
    UIButton *gift = [self.v_pgBack viewWithTag:1125];
    [gift setHidden:YES];

    self.logoStackView.hidden = NO;
    self.idInfoView.hidden = YES;
}
//送礼未达标ui
- (void)getUnArchiveUI{
    self.layout_pgsRightMargin.constant = 37;
    if (self.progress) {
        [self.progress removeFromSuperview];
    }
    [self.v_pgBack layoutIfNeeded];
    self.progress = [[GGProgressView alloc]initWithFrame:self.v_progress.bounds progressViewStyle:GGProgressViewStyleAllFillet];
    self.progress.progressTintColor = RGB_COLOR(@"#EAB26C", 1);
    self.progress.trackTintColor = [UIColor whiteColor];
    [self.v_progress insertSubview:self.progress atIndex:0];
    UIButton *gift = [self.v_pgBack viewWithTag:1125];
    [gift setHidden:NO];

    self.logoStackView.hidden = YES;
    self.idInfoView.hidden = NO;
}

- (void)sendLiwu:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contactViewSendDoLiwuMessage:)]) {
        [self.delegate contactViewSendDoLiwuMessage:self];
    }
}

- (IBAction)didTouchClose:(UIButton *)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.layout_contentCenterY.constant = _window_height;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
- (IBAction)didTouchGetContact:(UIButton *)sender {
    if (self.progress.progress == 1) {
        if (self.anchorContact.length > 1) {
            self.lb_anchorContact.text = self.anchorContact;
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];

            pasteboard.string = self.anchorContact;
            [MBProgressHUD showSuccess:YZMsg(@"publictool_copy_success")];
        }else{
            self.lb_anchorContact.text = YZMsg(@"LiveContactView_NoCard");
        }
    }else{
        self.lb_anchorContact.text = @"******";
        [MBProgressHUD showError:YZMsg(@"LiveContactView_NotEnoughGifts")];
    }
}
- (void)requestDatasWithLiver:(NSString *)liveId{
    NSString *url = [NSString stringWithFormat:@"Live.getLiveContact"];
    NSDictionary *dic = @{@"liveuid":liveId};
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:url withBaseDomian:1 andParameter:dic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (code == 0) {
            //成功返回
            NSDictionary *dic = [info firstObject];
            NSString *currencyConsumption = [YBToolClass getRateCurrency:minstr(dic[@"consumption_f"]) showUnit:NO];
            NSString *currencyCcontactCost = [YBToolClass getRateCurrency:minstr(dic[@"contact_cost_f"]) showUnit:NO];

            CGFloat consumption = [currencyConsumption floatValue];
            CGFloat contact_cost = [currencyCcontactCost floatValue];
            strongSelf.lb_progress.text = [NSString stringWithFormat:@"%.2f/%.2f",consumption,contact_cost];
            if ([dic.allKeys containsObject:@"contact_info"]) {
                //达标
                [strongSelf getArchiveUI];
                strongSelf.progress.progress = 1;
//                strongSelf.anchorContact = dic[@"contact_info"];
                NSArray * contact_list = dic[@"contact_list"];
                if ([contact_list count]) {
                    for (int i =0; i < [contact_list count]; i++) {
                        NSDictionary *infoDict = contact_list[i];
                        NSString * infoStr = infoDict[@"info"];
                        if (![PublicObj checkNull:infoStr]) {
                            if ([PublicObj checkNull:strongSelf.anchorContact]) {
                                strongSelf.anchorContact = [NSString stringWithFormat:@"%@:%@",infoDict[@"app_name"],infoStr];
                            }else{
                                strongSelf.anchorContact = [NSString stringWithFormat:@"%@,%@:%@",strongSelf.anchorContact,infoDict[@"app_name"],infoStr];
                            }

                            UIView *logoView = [strongSelf createLogoView:infoDict[@"app_logo"] key:[NSString stringWithFormat:@"%@:%@",infoDict[@"app_name"],infoStr]];
                            [strongSelf.logoStackView addArrangedSubview:logoView];
                        }
                    }
                }
                strongSelf.lb_anchorContact.text = strongSelf.anchorContact;
            }else{
                //未达标
                [strongSelf getUnArchiveUI];
                strongSelf.progress.progress = consumption / contact_cost;
            }
        }else{
            //失败
            [strongSelf getUnArchiveUI];
            strongSelf.progress.progress = 0;
            [MBProgressHUD showError:YZMsg(@"LiveContactView_GetError")];
        }
    } fail:^(NSError * _Nonnull error) {
        STRONGSELF
        dispatch_main_async_safe(^{
            if (strongSelf == nil) {
                return;
            }
            [strongSelf getUnArchiveUI];
            strongSelf.progress.progress = 0;
            [MBProgressHUD showError:YZMsg(@"LiveContactView_GetError")];
        });
    }];
}

- (UIView*)createLogoView:(NSString*)icon key:(NSString*)key {
    UIView *logoView = [[UIView alloc] init];
    logoView.backgroundColor = [UIColor clearColor];
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@30);
    }];

    UIImageView *logoIcon = [[UIImageView alloc] init];
    logoIcon.contentMode = UIViewContentModeScaleAspectFit;
    [logoIcon sd_setImageWithURL:[NSURL URLWithString:icon]];
    [logoView addSubview:logoIcon];
    [logoIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(logoView).offset(20);
        make.size.equalTo(@20);
        make.centerY.equalTo(logoView);
    }];

    UIButton *copyButton = [[UIButton alloc] init];
    [copyButton setImage:[ImageBundle imagewithBundleName:YZMsg(@"LiveContactView_ContactGetIcon")]  forState:UIControlStateNormal];
    [copyButton addTarget:self action:@selector(didTouchGetContact:) forControlEvents:UIControlEventTouchUpInside];
    [logoView addSubview:copyButton];
    [copyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(logoView).offset(-20);
        make.width.equalTo(@35);
        make.height.equalTo(@20);
        make.centerY.equalTo(logoView);
    }];

    UILabel *keyLabel = [[UILabel alloc] init];
    keyLabel.minimumScaleFactor = 0.5;
    keyLabel.adjustsFontSizeToFitWidth = YES;
    keyLabel.text = key;
    keyLabel.textColor = [UIColor whiteColor];
    keyLabel.font = [UIFont systemFontOfSize:12];
    [logoView addSubview:keyLabel];
    [keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(logoView);
        make.left.equalTo(logoIcon.mas_right).offset(5);
        make.right.equalTo(copyButton.mas_left).offset(-5);
    }];

    return logoView;
}

#define RADIANS(degrees) (((degrees) * M_PI) / 180.0)

- (void)startWobbleWithView:(UIView *)view {
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformRotate(transform, RADIANS(-10));
    view.transform = transform;
    WeakSelf
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse)
                     animations:^ {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        view.transform = CGAffineTransformMakeRotation(RADIANS(10));
    }
                     completion:^(BOOL finished) {
        //                         if(finished){
        //                             NSLog(@"Wobble finished");
        //                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //                                 [__weakSelf startWobble];
        //                             });
        //                         }
    }
     ];
}
@end
