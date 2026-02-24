//
//  LotteryBetView_ZJH.m
//  phonelive2
//
//  Created by vick on 2023/11/17.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryBetView_ZJH.h"
#import "PockerView.h"
#import "LotteryVoiceUtil.h"

@interface LotteryBetView_ZJH ()

@property (nonatomic, strong) UIImageView *backImgView;
@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UIImageView *bottomImgView;
@property (nonatomic, strong) UILabel *bottomTitleLabel;

@end

@implementation LotteryBetView_ZJH

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        self.selected = NO;
    }
    return self;
}

- (void)setupView {
    
    UIImageView *backImgView = [UIImageView new];
    [self addSubview:backImgView];
    self.backImgView = backImgView;
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    UIImageView *iconImgView = [UIImageView new];
    iconImgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:iconImgView];
    self.iconImgView = iconImgView;
    [iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(38);
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    
    UIView *areaView = [UIView new];
    [self addSubview:areaView];
    self.areaView = areaView;
    [areaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.bottom.mas_equalTo(-5);
        make.height.mas_equalTo(areaView.mas_width).multipliedBy(0.58);
    }];
    
    UIImageView *bottomImgView = [UIImageView new];
    bottomImgView.image = [ImageBundle imagewithBundleName:@"zjh_result"];
    bottomImgView.hidden = YES;
    [self addSubview:bottomImgView];
    self.bottomImgView = bottomImgView;
    [bottomImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(bottomImgView.mas_width).multipliedBy(0.23);
    }];
    
    UILabel *bottomTitleLabel = [UILabel new];
    bottomTitleLabel.textColor = UIColor.whiteColor;
    bottomTitleLabel.font = vkFont(12);
    [bottomImgView addSubview:bottomTitleLabel];
    self.bottomTitleLabel = bottomTitleLabel;
    [bottomTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(-1);
    }];
}

- (void)setType:(ZJHLotteryBetViewType)type {
    _type = type;
    switch (type) {
        case ZJHLotteryBetViewTypeLeft:
            self.iconImgView.image = [ImageBundle imagewithBundleName:@"zjh_player_1.png"];
            break;
        case ZJHLotteryBetViewTypeRight:
            self.iconImgView.image = [ImageBundle imagewithBundleName:@"zjh_player_3.png"];
            break;
        default:
            self.iconImgView.image = [ImageBundle imagewithBundleName:@"zjh_player_2.png"];
            break;
    }
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.backImgView.image = [ImageBundle imagewithBundleName:selected ? @"zjh_bolder_s" : @"zjh_bolder_n"];
}

- (void)setPockers:(NSArray *)pockers {
    _pockers = pockers;
    for (int i=0; i<pockers.count; i++) {
        PockerView *pocker = [self.areaView viewWithTag:1000+i];
        NSString *name = LotteryPoker(pockers[i]);
        [pocker setPokerName:name];
    }
}

- (void)showPockerAnimation {
    for (int i = 0; i < 3; i++) {
        [self performSelector:@selector(startAddPocker:) withObject:@(i) afterDelay:i*0.5];
    }
}

- (void)startAddPocker:(id)object {
    NSInteger i = [object integerValue];
    CGFloat pHeight = self.areaView.height;
    CGFloat pWidth = pHeight * 0.75;
    CGFloat x = i * (0.7 * pWidth);
    
    PockerView *pocker = [[PockerView alloc] initWithFrame:CGRectMake(self.startX, -60, pWidth, pHeight)];
    pocker.tag = 1000 + i;
    [self.areaView addSubview:pocker];
    [UIView animateWithDuration:0.3 animations:^{
        pocker.x = x;
        pocker.y = 0;
    } completion:nil];
    
    [LotteryVoiceUtil.shared stopPlayHint];
    [LotteryVoiceUtil.shared startPlayHint:@"fapaiaudio"];
}

- (void)hidePockerAnimation {
    for (PockerView *pocker in self.areaView.subviews) {
        [UIView animateWithDuration:0.5 animations:^{
            pocker.x = self.startX;
            pocker.y = -60;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                pocker.alpha = 0;
            } completion:^(BOOL finished) {
                [pocker removeFromSuperview];
            }];
        }];
    }
    self.bottomImgView.hidden = YES;
}

- (void)openPockerAnimation {
    for (PockerView *pocker in self.areaView.subviews) {
        [pocker rotateWithPokerView];
    }
    self.bottomTitleLabel.text = self.result;
    self.bottomImgView.hidden = NO;
}

- (void)openPocker {
    for (PockerView *pocker in self.areaView.subviews) {
        [pocker showOpenPoker];
    }
    self.bottomTitleLabel.text = self.result;
    self.bottomImgView.hidden = NO;
}

@end
