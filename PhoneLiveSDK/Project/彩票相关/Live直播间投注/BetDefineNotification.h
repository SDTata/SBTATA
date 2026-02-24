//
//  BetDefineNotification.h
//  phonelive2
//
//  Created by 400 on 2021/10/1.
//  Copyright © 2021 toby. All rights reserved.
//

#import "CustomScrollView.h"
#import "ImageBundle.h"
#import "LotteryBetSubView.h"

#ifndef BetDefineNotification_h
#define BetDefineNotification_h

#define KBetDoNotificationMsg @"UserDoBetNotifications"
#define KBetWinNotificationMsg @"UserWinBetNotifications"
#define KBetWinAllUserNotificationMsg @"UserWinAllUserBetNotifications"
#define KBetCloseNotificationMsg @"KBetCloseNotificationMsg"
#define KVipPayNotificationMsg @"KVipPayNotificationMsg"


#define kLotteryOpenViewCell_SC @"LotteryOpenViewCell_SC"
#define kLotteryOpenViewCell_BJL @"LotteryOpenViewCell_BJL"
#define kLotteryOpenViewCell_ZJH @"LotteryOpenViewCell_ZJH"
#define kLotteryOpenViewCell_LH @"LotteryOpenViewCell_LH"
#define kLotteryOpenViewCell_ZP @"LotteryOpenViewCell_ZP"
#define kLotteryOpenViewCell_SSC @"LotteryOpenViewCell_SSC"
#define kLotteryOpenViewCell_LHC @"LotteryOpenViewCell_LHC"

#define kBetOptionCollectionViewCell @"BetOptionCollectionViewCell"
#define kIssueCollectionViewCell @"IssueCollectionViewCell"
#define kChipChoiseCell @"ChipChoiseCell"
#define kLiveOpenListYFKSCell @"LiveOpenListYFKSCell"
#define kLiveBetListYFKSCell @"LiveBetListYFKSCell"



#define KNumberOfChipsLimit 50


#define LotteryWindowOldHeigh 377
#define LotteryWindowOldNNHeigh 377
#define LotteryWindowNewHeigh 377
#define LotteryWindowNewHeighLH 377
#define LotteryWindowNewHeighZJH 377
#define LotteryWindowNewHeighYFKS 377
#define LotteryWindowNewHeighBJL 377
#define LotteryWindowNewHeighZP 377
#define LotteryWindowNewHeighLHC 377
#define LotteryWindowNewHeighSSC 377
#define LotteryWindowNewHeighSC 377
#define LotteryWindowNewNNHeigh 377

UIKIT_STATIC_INLINE CATransform3D betTransform() {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -1.0f / 500.0f;
    transform = CATransform3DRotate(transform, 30 * M_PI / 180, 1, 0, 0);
    return transform;
}

UIKIT_STATIC_INLINE UIImageView * creatChipImage(NSString *moneyNum, NSInteger tagNum) {
    UIImageView *chipImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    chipImgV.layer.zPosition = 10;
    chipImgV.tag = tagNum;
    UILabel *labelChip = [[UILabel alloc] initWithFrame:CGRectMake(2, -3, 18, 22)];
    labelChip.textAlignment = NSTextAlignmentCenter;
    labelChip.adjustsFontSizeToFitWidth = YES;
    labelChip.minimumScaleFactor = 0.5;
    labelChip.font = [UIFont boldSystemFontOfSize:10];
    [labelChip vk_slantHorizontal:-20];
    
    labelChip.textColor = [UIColor blackColor];
    [chipImgV addSubview:labelChip];
    switch ([moneyNum intValue]) {
        case 2:
            chipImgV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"yfks_cm%d",1]];
            labelChip.text = [YBToolClass getRateCurrency:@"2" showUnit:NO];
            break;
        case 10:
            chipImgV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"yfks_cm%d",2]];
            labelChip.text = [YBToolClass getRateCurrency:@"10" showUnit:NO];
            break;
        case 100:
            chipImgV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"yfks_cm%d",3]];
            labelChip.text = [YBToolClass getRateCurrency:@"100" showUnit:NO];
            break;
        case 200:
            chipImgV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"yfks_cm%d",4]];
            labelChip.text = [YBToolClass getRateCurrency:@"200" showUnit:NO];
            break;
        case 500:
            chipImgV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"yfks_cm%d",5]];
            labelChip.text = [YBToolClass getRateCurrency:@"500" showUnit:NO];
            break;
        case 1000:
            chipImgV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"yfks_cm%d",6]];
            labelChip.text = [YBToolClass getRateCurrency:@"1000" showUnit:NO];
            break;
        default:
            chipImgV.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"yfks_cm%d",7]];
            labelChip.text = [YBToolClass getRateCurrency:moneyNum showUnit:NO];
            break;
    }
    return chipImgV;
}

UIKIT_STATIC_INLINE LotteryBetSubView * creatBetSubView(UIView *contentView, UIView *toView, VKBoolBlock block) {
    LotteryBetSubView *lotterySubBetV = [contentView viewWithTag:toView.tag + 888888];
    if (!lotterySubBetV) {
        lotterySubBetV = [LotteryBetSubView instanceLotteryBetSubViewwWithFrame:CGRectZero contentEdge:3 withBlock:block];
        lotterySubBetV.layer.zPosition = 12;
        lotterySubBetV.tag = toView.tag  + 888888;
        CGRect absoluteRect = [toView convertRect:toView.bounds toView:contentView];
        CGFloat left = absoluteRect.origin.x + (absoluteRect.size.width - 60) / 2;
        CGFloat bottom = CGRectGetHeight(contentView.frame) - CGRectGetMaxY(absoluteRect) + (absoluteRect.size.height - 40) / 2;
        [contentView addSubview:lotterySubBetV];
        [lotterySubBetV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(left);
            make.bottom.mas_equalTo(-bottom);
            make.height.mas_equalTo(VKPX(40));
            make.width.mas_equalTo(VKPX(60));
        }];
        [contentView layoutIfNeeded];
    }
    return lotterySubBetV;
}

typedef NS_ENUM (NSUInteger, LotteryBetType) {
    LotteryBetTypeNone = 0,
    LotteryBetTypeLHC,
    LotteryBetTypeSSC,
    LotteryBetTypeNN,
    LotteryBetTypeSC,
    LotteryBetTypeYFKS,
    LotteryBetTypeBJL,
    LotteryBetTypeZJH,
    LotteryBetTypeZP,
    LotteryBetTypeLH,
    LotteryBetTypeLB,
};

/// 开奖号码样式枚举
typedef NS_ENUM (NSUInteger, BetCodeStyle) {
    BetCodeStyleTop,/// 右上角
    BetCodeStyleMenu,/// 中间菜单
    BetCodeStyleBottom,/// 底部弹窗
};

UIKIT_STATIC_INLINE LotteryBetType BetType(NSInteger type) {
    switch (type) {
//        case 7:
        case 8:
//        case 32:
            return LotteryBetTypeLHC;
        case 6:
        case 11:
            return LotteryBetTypeSSC;
        case 10:
            return LotteryBetTypeNN;
        case 14:
            return LotteryBetTypeSC;
        case 26:
        case 27:
            return LotteryBetTypeYFKS;
        case 28:
            return LotteryBetTypeBJL;
        case 29:
            return LotteryBetTypeZJH;
        case 30:
            return LotteryBetTypeZP;
        case 31:
            return LotteryBetTypeLH;
        case 40:
            return LotteryBetTypeLB;
        default:
            return LotteryBetTypeNone;
    }
}

UIKIT_STATIC_INLINE void LotterySwitchSet(NSInteger lotteryType, BOOL value) {
    NSString *key = [NSString stringWithFormat:@"LotterySwitchKey_%ld", BetType(lotteryType)];
    vkUserSet(key, @(value));
}

UIKIT_STATIC_INLINE BOOL LotterySwitchGet(NSInteger lotteryType) {
    NSString *key = [NSString stringWithFormat:@"LotterySwitchKey_%ld", BetType(lotteryType)];
    return [vkUserGet(key) boolValue];
}

UIKIT_STATIC_INLINE NSString * LotteryPoker(NSString *pokerName) {
    if (pokerName.length < 3) {
        return @"";
    }
    NSString *midName = @"";
    NSString *preTag = [pokerName substringToIndex:2];
    NSString *endName = [pokerName substringFromIndex:2];
    if ([preTag isEqualToString:@"黑桃"]) {
        midName = @"spade";
    }else if ([preTag isEqualToString:@"红心"]) {
        midName = @"heart";
    }else if ([preTag isEqualToString:@"方块"]) {
        midName = @"rectangle";
    }else if ([preTag isEqualToString:@"梅花"]){
        midName = @"flower";
    }
    return [NSString stringWithFormat:@"poker_%@_%@", midName, endName];
}

UIKIT_STATIC_INLINE NSArray <NSArray *> * LotteryResults(NSString *value) {
    NSMutableArray *array = [NSMutableArray array];
    NSArray *results = [value componentsSeparatedByString:@"|"];
    for (NSString *result in results) {
        NSArray *items = [result componentsSeparatedByString:@":"];
        NSString *item = items.lastObject;
        NSArray *lasts = [item componentsSeparatedByString:@"("];
        NSString *last = lasts.firstObject;
        [array addObject:[last componentsSeparatedByString:@","]];
    }
    return array;
}

@class LotteryBetViewController;
@protocol lotteryBetViewDelegate <NSObject>
@optional
//关闭
-(void)lotteryCancless;
//礼物
-(void)doLiwu;
-(BOOL)cancelLuwu;
//游戏
-(void)doGame;
//红包
-(void)showRedView;
//聊天输入框
-(void)showkeyboard:(UIButton *)sender;
//切换版本到新版
- (void)exchangeVersionToNew:(NSInteger)curLotteryType;
//切换版本到老版
- (void)exchangeVersionToOld:(NSInteger)curLotteryType;
//设置当前彩种选择
- (void)setCurlotteryVC:(LotteryBetViewController *)vc;
//刷新直播聊天列表的高度
-(void)refreshTableHeight:(BOOL)isShowTopView;
@end

#endif /* BetDefineNotification_h */
