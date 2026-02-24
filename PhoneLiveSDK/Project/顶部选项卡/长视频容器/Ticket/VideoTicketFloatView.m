//
//  VideoTicketFloatView.m
//  phonelive2
//
//  Created by vick on 2024/7/15.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoTicketFloatView.h"
#import "VideoTicketAlertView.h"
#import "PostVideoViewController.h"
#import <UMCommon/UMCommon.h>

@interface VideoTicketFloatView ()

@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UIImageView *ticketImgView;
@property (nonatomic, strong) UIImageView *postVideoImgView;

@end

@implementation VideoTicketFloatView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self refreshData];
    }
    return self;
}

- (void)setupView {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeLanguage) name:@"changeLanguage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTicket_count:) name:@"updateTicket_count" object:nil];
    self.backgroundColor = UIColor.clearColor;
    self.clipsToBounds = NO;
    self.isKeepBounds = YES;
    self.freeRect = CGRectMake(10, State_Bar_H, SCREEN_WIDTH-20, SCREEN_HEIGHT-State_Bar_H-kSafeBottomHeight-55);
    UIImageView *ticketImgView = [UIImageView new];
    ticketImgView.userInteractionEnabled = YES;
    ticketImgView.image = [ImageBundle imagewithBundleName:YZMsg(@"video_ticket_float")];
    [self addSubview:ticketImgView];
    self.ticketImgView = ticketImgView;
    [ticketImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(6);
        make.width.mas_equalTo(32);
        make.height.mas_equalTo(20);
    }];
    [ticketImgView vk_addTapAction:self selector:@selector(clickTicketAction)];
    
    // 创建标签容器
    UIView *labelContainer = [[UIView alloc] init];
    labelContainer.backgroundColor = vkColorHex(0xF251BB);
    labelContainer.layer.cornerRadius = 6;
    labelContainer.layer.masksToBounds = YES;
    [self addSubview:labelContainer];
    
    // 创建数字标签
    UILabel *numberLabel = [UIView vk_label:@"0" font:vkFont(8) color:UIColor.whiteColor];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    [labelContainer addSubview:numberLabel];
    self.numberLabel = numberLabel;
    
    // 设置标签容器约束
    [labelContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ticketImgView.mas_right).offset(4);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(12);
        // 根据内容自适应宽度,但最小宽度为12
        make.width.mas_greaterThanOrEqualTo(12);
    }];
    
    // 设置数字标签约束
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(3);
        make.right.mas_equalTo(-3);
        make.top.bottom.mas_equalTo(0);
        make.height.mas_equalTo(12);
    }];

    UIImageView *postVideoImgView = [UIImageView new];
    postVideoImgView.hidden = YES;
    postVideoImgView.userInteractionEnabled = YES;
    [postVideoImgView vk_addTapAction:self selector:@selector(clickPostAction)];
    postVideoImgView.image = [ImageBundle imagewithBundleName:@"postvideo"];
    [self addSubview:postVideoImgView];
    self.postVideoImgView = postVideoImgView;
    [postVideoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ticketImgView.mas_bottom).offset(34); // 设置与 backImgView 底部间距为 5
        make.centerX.mas_equalTo(ticketImgView); // 水平居中对齐 backImgView
        make.width.height.mas_equalTo(27);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)changeLanguage {
    self.ticketImgView.image = [ImageBundle imagewithBundleName:YZMsg(@"video_ticket_float")];
}

- (void)updateTicket_count:(NSNotification *)notification {
    NSNumber *total = notification.object;
    // 判斷是否超過 99，顯示99+
    if (total.integerValue > 99) {
        self.numberLabel.text = @"99+";
    } else {
        self.numberLabel.text = total.stringValue;
    }
}

- (void)clickPostAction {
    NSLog(@"发布视频");
    PostVideoViewController *postVideo = [[PostVideoViewController alloc]initWithNibName:@"PostVideoViewController" bundle:[XBundle currentXibBundleWithResourceName:@"PostVideoViewController"]];
    [[MXBADelegate sharedAppDelegate] pushViewController:postVideo animated:YES];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"event_detail":@"发布短视频"};
    [MobClick event:@"shortvideo_menue_click" attributes:dict];
}
- (void)clickTicketAction {
    VideoTicketAlertView *vc = [VideoTicketAlertView new];
    [vc showFromBottom];
    NSDictionary *dict = @{ @"eventType": @(0),
                            @"type_name":@"观影券"};
    [MobClick event:@"home_recommend_coupons_click" attributes:dict];
}

- (void)refreshData {
    WeakSelf
    [LotteryNetworkUtil getVideoTicketsBlock:^(NetworkData *networkData) {
        STRONGSELF
        if (!strongSelf) return;
        if (networkData.status) {
            NSArray *tickets = networkData.data[@"ticket"];
            [Config setVideoTickets:tickets];
            NSNumber *total = [tickets valueForKeyPath:@"@sum.ticket_count"];
            // 判斷是否超過 99，顯示99+
            if (total.integerValue > 99) {
                strongSelf.numberLabel.text = @"99+";
            } else {
                strongSelf.numberLabel.text = total.stringValue;
            }
            LiveUser *user = [Config myProfile];
            user.coin = minstr(networkData.data[@"coin"]);
            [Config updateProfile:user];
        }
    }];
}

+ (void)showFloatView {
    VideoTicketFloatView *view = [UIApplication.sharedApplication.keyWindow viewWithTag:18181818];
    if (view) {
        [view refreshData];
        view.hidden = NO;
        return;
    }
    view = [VideoTicketFloatView new];
    view.tag = 18181818;
    [UIApplication.sharedApplication.keyWindow addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(VK_NAV_H + 100);
    }];
}

+ (void)hideFloatView {
    UIView *view = [UIApplication.sharedApplication.keyWindow viewWithTag:18181818];
    view.hidden = YES;
}

+ (void)refreshFloatData {
    VideoTicketFloatView *view = [UIApplication.sharedApplication.keyWindow viewWithTag:18181818];
    if (view) {
        [view refreshData];
        return;
    }
}

+ (void)hidePostVideoButton {
    VideoTicketFloatView *view = [UIApplication.sharedApplication.keyWindow viewWithTag:18181818];
    if (view) {
        view.postVideoImgView.hidden = YES;
        if (view.numberLabel.isHidden && view.ticketImgView.isHidden) {
            view.hidden = YES;
        }
        return;
    }
}

+ (void)showPostVideoButton {
    VideoTicketFloatView *view = [UIApplication.sharedApplication.keyWindow viewWithTag:18181818];
    if (view) {
        [UIApplication.sharedApplication.keyWindow bringSubviewToFront:view];
        view.hidden = NO;
        view.postVideoImgView.hidden = NO;
        return;
    }
    view = [VideoTicketFloatView new];
    view.tag = 18181818;
    [UIApplication.sharedApplication.keyWindow addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.top.mas_equalTo(VK_NAV_H + 100);
    }];
}

+ (void)hideTicketButton {
    VideoTicketFloatView *view = [UIApplication.sharedApplication.keyWindow viewWithTag:18181818];
    if (view) {
        view.numberLabel.hidden = YES;
        view.ticketImgView.hidden = YES;
        if (view.postVideoImgView.isHidden) {
            view.hidden = YES;
        }
        return;
    }
}

+ (void)showTicketButton {
    if ([Config getOwnID]!= nil && [Config getOwnID].length>0) {
        VideoTicketFloatView *view = [UIApplication.sharedApplication.keyWindow viewWithTag:18181818];
        if (view) {
            [UIApplication.sharedApplication.keyWindow bringSubviewToFront:view];
            view.hidden = NO;
            view.numberLabel.hidden = NO;
            view.ticketImgView.hidden = NO;
            [view refreshData];
            return;
        }
        view = [VideoTicketFloatView new];
        view.tag = 18181818;
        [UIApplication.sharedApplication.keyWindow addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-10);
            make.top.mas_equalTo(VK_NAV_H + 100);
        }];
    }
    
}

@end
