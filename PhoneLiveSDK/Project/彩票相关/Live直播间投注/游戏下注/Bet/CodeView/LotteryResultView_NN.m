//
//  LotteryResultView_NN.m
//  phonelive2
//
//  Created by vick on 2023/11/21.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryResultView_NN.h"
#import "PockerView.h"
#import "LotteryVoiceUtil.h"

@interface LotteryResultView_NN ()

@property (nonatomic, strong) UIImageView *backImgView;
@property (nonatomic, strong) UIImageView *bottomImgView;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UIButton *winButton;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation LotteryResultView_NN

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
    backImgView.layer.borderWidth = 2.0;
    backImgView.layer.cornerRadius = 5;
    backImgView.layer.masksToBounds = YES;
    backImgView.backgroundColor = vkColorHexA(0x000000, 0.3);
    [self addSubview:backImgView];
    self.backImgView = backImgView;
    [backImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = vkFontBold(20);
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.mas_equalTo(0);
    }];
    
    UIView *contentView = [UIView new];
    [self addSubview:contentView];
    self.contentView = contentView;
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(-5);
    }];
    
    UIImageView *bottomImgView = [UIImageView new];
    bottomImgView.contentMode = UIViewContentModeScaleAspectFit;
    bottomImgView.hidden = YES;
    [self addSubview:bottomImgView];
    self.bottomImgView = bottomImgView;
    [bottomImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    
    UILabel *valueLabel = [UIView vk_label:nil font:vkFontMedium(10) color:vkColorHex(0xFFFFFF)];
    [bottomImgView addSubview:valueLabel];
    self.valueLabel = valueLabel;
    [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
    
    UIButton *winButton = [UIView vk_button:@"胜" image:nil font:vkFont(10) color:vkColorHex(0xFFFFFF)];
    [winButton setBackgroundImage:[ImageBundle imagewithBundleName:@"win_mark"] forState:UIControlStateNormal];
    [self addSubview:winButton];
    self.winButton = winButton;
}

- (void)setType:(NNLotteryResultType)type {
    _type = type;
    switch (type) {
        case NNLotteryResultTypeRight:
        {
            self.titleLabel.text = @"红方";
            self.titleLabel.textColor = vkColorRGB(236, 123, 126);
            self.backImgView.layer.borderColor = vkColorRGB(236, 123, 126).CGColor;
            self.bottomImgView.image = [ImageBundle imagewithBundleName:@"red_di"];
            [self.winButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo(14);
                make.right.mas_equalTo(5);
                make.top.mas_equalTo(-5);
            }];
        }
            break;
        default:
        {
            self.titleLabel.text = @"蓝方";
            self.titleLabel.textColor = vkColorRGB(0, 160, 255);
            self.backImgView.layer.borderColor = vkColorRGB(0, 160, 255).CGColor;
            self.bottomImgView.image = [ImageBundle imagewithBundleName:@"blue_di"];
            [self.winButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.height.mas_equalTo(14);
                make.left.mas_equalTo(-5);
                make.top.mas_equalTo(-5);
            }];
        }
            break;
    }
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    self.winButton.hidden = !selected;
}

- (void)setResult:(NSString *)result {
    _result = result;
    self.valueLabel.text = result;
    self.bottomImgView.hidden = NO;
}

- (void)setPockers:(NSArray *)pockers {
    _pockers = pockers;
    for (int i=0; i<pockers.count; i++) {
        PockerView *pocker = [self.contentView viewWithTag:1000+i];
        NSString *name = LotteryPoker(pockers[i]);
        [pocker setPokerName:name];
    }
}

- (void)setupPockerView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    for (int i = 0; i < 5; i++) {
        CGFloat pHeight = self.contentView.height;
        CGFloat pWidth = pHeight * 0.8;
        CGFloat x = i * (0.75 * pWidth);
        
        PockerView *pocker = [[PockerView alloc] initWithFrame:CGRectMake(x, 0, pWidth, pHeight)];
        pocker.tag = 1000 + i;
        [self.contentView addSubview:pocker];
    }
}

- (void)showPockerAnimation {
    for (int i = 0; i < 5; i++) {
        [self performSelector:@selector(startAddPocker:) withObject:@(i) afterDelay:i*0.4];
    }
}

- (void)startAddPocker:(id)object {
    NSInteger i = [object integerValue];
    CGFloat pHeight = self.contentView.height;
    CGFloat pWidth = pHeight * 0.8;
    CGFloat x = i * (0.75 * pWidth);
    
    PockerView *pocker = [[PockerView alloc] initWithFrame:CGRectMake(self.startX, -40, pWidth, pHeight)];
    pocker.tag = 1000 + i;
    [self.contentView addSubview:pocker];
    [UIView animateWithDuration:0.3 animations:^{
        pocker.x = x;
        pocker.y = 0;
    } completion:nil];
    
    [LotteryVoiceUtil.shared stopPlayHint];
    [LotteryVoiceUtil.shared startPlayHint:@"fapaiaudio"];
}

- (void)hidePockerAnimation {
    self.winButton.hidden = YES;
    self.bottomImgView.hidden = YES;
    for (PockerView *pocker in self.contentView.subviews) {
        [UIView animateWithDuration:0.3 animations:^{
            pocker.x = self.startX;
            pocker.y = -40;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                pocker.alpha = 0;
            } completion:^(BOOL finished) {
                [pocker removeFromSuperview];
            }];
        }];
    }
}

- (void)openPockerAnimation {
    for (PockerView *pocker in self.contentView.subviews) {
        [pocker rotateWithPokerView];
    }
}

- (void)openPocker {
    for (PockerView *pocker in self.contentView.subviews) {
        [pocker showOpenPoker];
    }
}

@end
