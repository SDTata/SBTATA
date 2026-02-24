//
//  fans.m
//  yunbaolive
//
//  Created by cat on 16/4/1.
//  Copyright © 2016年 cat. All rights reserved.
//

#import "fans.h"
#import "fansModel.h"
#import "fansViewController.h"
#import "UIButton+WebCache.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+MJ.h"
#import "UIImageView+WebCache.h"
#import "Config.h"
#import "LiveGifImage.h"
#import "EnterLivePlay.h"
@interface fans ()
@property (nonatomic, strong) UIView *gifImgAndLiveTag;
@end

@implementation fans

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView addSubview:self.gifImgAndLiveTag];
    [self.gifImgAndLiveTag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.iconV.mas_centerX);
        make.bottom.mas_equalTo(self.iconV.mas_bottom);
        make.height.mas_equalTo(11);
        make.width.mas_equalTo(self.iconV);
    }];
    
    [self.iconV addTarget:self action:@selector(jumpLiveRoom) forControlEvents:UIControlEventTouchUpInside];
    
    
}
-(void)jumpLiveRoom
{
    if (_model.isLive) {
        [[EnterLivePlay sharedInstance]showLivePlayFromLiveID:[_model.uid integerValue] fromInfoPage:YES];
    }
}
-(void)drawRect:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx,1);
    CGContextSetStrokeColorWithColor(ctx,[UIColor groupTableViewBackgroundColor].CGColor);
    CGContextMoveToPoint(ctx,0,self.frame.size.height);
    CGContextAddLineToPoint(ctx,(self.frame.size.width),self.frame.size.height);
    CGContextStrokePath(ctx);
}

-(void)setModel:(fansModel *)model{
    _model = model;
    _nameL.text = _model.name;
    _signatureL.text = _model.signature;
    //性别 1男
     if ([[_model valueForKey:@"sex"] isEqual:@"1"])
    {
        self.sexL.image = [ImageBundle imagewithBundleName:@"sex_man"];
    }
    else
    {
        self.sexL.image = [ImageBundle imagewithBundleName:@"sex_woman"];
    }
    //级别
    NSDictionary *userLevel = [common getUserLevelMessage:_model.level];
//    self.levelL.image = [ImageBundle imagewithBundleName:[NSString stringWithFormat:@"host_%@",_model.level_anchor]];
    [self.levelL sd_setImageWithURL:[NSURL URLWithString:minstr([[common getAnchorLevelMessage:_model.level_anchor] valueForKey:@"thumb"])]];
    [self.hostlevel sd_setImageWithURL:[NSURL URLWithString:minstr([userLevel valueForKey:@"thumb"])]];
    
    NSString *avatarURL = _model.avatar.length > 0 ? _model.avatar : _model.icon;
    //头像
    [self.iconV sd_setBackgroundImageWithURL:[NSURL URLWithString:avatarURL]
                                    forState:UIControlStateNormal
                            placeholderImage:[ImageBundle imagewithBundleName:@"profile_accountImg"]];

    self.iconV.layer.cornerRadius = 11;
    self.iconV.layer.masksToBounds = YES;
    //关注
 
    self.guanzhubtn.layer.borderWidth = 1.5;
    self.guanzhubtn.layer.cornerRadius = 11;
    self.guanzhubtn.layer.masksToBounds = YES;
    // 设置按钮标题
    [self.guanzhubtn setTitle:YZMsg(@"RankCell_FollowButton") forState:UIControlStateNormal];
    [self.guanzhubtn setTitle:YZMsg(@"upmessageInfo_followed") forState:UIControlStateSelected];
    self.guanzhubtn.titleLabel.minimumScaleFactor = 0.2;
    self.guanzhubtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    // 设置按钮标题颜色
    [self.guanzhubtn setTitleColor:vkColorHex(0xff5fed) forState:UIControlStateNormal];
    [self.guanzhubtn setTitleColor:vkColorHex(0xc8c8c8) forState:UIControlStateSelected];

    
    
    if ([_model.uid isEqual:[Config getOwnID]]) {
        self.guanzhubtn.hidden = YES;
    }else{
        self.guanzhubtn.hidden = NO;
        if ([_model.isattention isEqual:@"0"]) {
            self.guanzhubtn.selected = NO;
            self.guanzhubtn.layer.borderColor = vkColorHex(0xff5fed).CGColor; // #ff5fed
        }
        else
        {
            self.guanzhubtn.selected = YES;
            self.guanzhubtn.layer.borderColor = vkColorHex(0xc8c8c8).CGColor; // #ff5fed
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addLiveBorderWithAnimation:model.isLive];
    });
    self.gifImgAndLiveTag.hidden = !model.isLive;
}

+(fans *)cellWithTableView:(UITableView *)tv{
    fans *cell = [tv dequeueReusableCellWithIdentifier:@"a"];
    if (!cell) {
       cell = [[XBundle currentXibBundleWithResourceName:@"fans"]loadNibNamed:@"fans" owner:self options:nil].lastObject;
    }
    return cell;
    
}
- (IBAction)gaunzhuBTN:(UIButton *)btn{
    if ([[Config getOwnID] isEqual:_model.uid]) {
        [MBProgressHUD showError:YZMsg(@"RankVC_FollowMeError")];
            return;
    }
    [self.guanzhuDelegate doGuanzhu:_model.uid button:btn];
}

- (UIView *)gifImgAndLiveTag {
    if (!_gifImgAndLiveTag) {
        UIView *control = [[UIView alloc] init];

        NSString *gifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:@"living_animation_white" ofType:@"gif"];
        YYAnimatedImageView *gifImg = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        LiveGifImage *imgAnima = (LiveGifImage*)[LiveGifImage imageWithData:[NSData dataWithContentsOfFile:gifPath]];
        [imgAnima setAnimatedImageLoopCount:0];
        gifImg.image = imgAnima;
        gifImg.runloopMode = NSRunLoopCommonModes;
        gifImg.animationRepeatCount = 0;
        [gifImg startAnimating];
        
        UIView *tagView = [[UIView alloc] init];
        tagView.layer.masksToBounds = YES;
        tagView.backgroundColor = RGB_COLOR(@"#F251BB", 1);

        UILabel *label = [[UILabel alloc] init];
        label.text = YZMsg(@"Live Streaming");
        label.font = [UIFont systemFontOfSize:8];
        label.textColor = [UIColor whiteColor];
        [control addSubview:tagView];
        [tagView addSubview:gifImg];
        [tagView addSubview:label];
        [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(control);
            make.height.mas_equalTo(11);
        }];
        
        [gifImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tagView.mas_left).offset(2);
            make.centerY.equalTo(tagView);
            make.height.mas_equalTo(8);
            make.width.mas_equalTo(8);
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(tagView).inset(2);
            make.right.equalTo(tagView).inset(2);
            make.left.equalTo(gifImg.mas_right).offset(3);
        }];
        _gifImgAndLiveTag = control;
        _gifImgAndLiveTag.hidden = YES;
    }
    return _gifImgAndLiveTag;
}

- (void)addLiveBorderWithAnimation:(BOOL)isLive {
    [self.iconV.layer.sublayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
        if ([layer.name isEqualToString:@"LiveBorderLayer"]) {
            [layer removeFromSuperlayer];
        }
    }];

    if (isLive) {
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.name = @"LiveBorderLayer";
        borderLayer.strokeColor = RGB_COLOR(@"#F251BB", 1).CGColor;
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        borderLayer.lineWidth = 2.0;

        CGFloat extraPadding = 4.0;  // 調整這個值來改變間距
        CGFloat borderWidth = borderLayer.lineWidth;
        CGFloat newSize = self.iconV.bounds.size.width + extraPadding * 2;

        // 設定邊框 Frame 並讓它居中
        borderLayer.frame = CGRectMake(0, 0, newSize, newSize);
        borderLayer.position = CGPointMake(CGRectGetMidX(self.iconV.bounds),
                                           CGRectGetMidY(self.iconV.bounds));
        
        // 設定圓角，確保邊框仍然是圓形
        borderLayer.cornerRadius = newSize / 2;
        
        // 修正 UIBezierPath，讓邊框完整包圍 avatar
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(borderWidth / 2 + extraPadding,
                                                                               borderWidth / 2 + extraPadding,
                                                                               newSize - borderWidth - extraPadding * 2,
                                                                               newSize - borderWidth - extraPadding * 2)];
        borderLayer.path = path.CGPath;

        // 添加呼吸動畫（閃爍效果）
        CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
        pulse.fromValue = @(1.0);
        pulse.toValue = @(0.3);
        pulse.duration = 0.8;
        pulse.autoreverses = YES;
        pulse.repeatCount = HUGE_VALF;
        [borderLayer addAnimation:pulse forKey:@"pulseAnimation"];

        [self.iconV.layer addSublayer:borderLayer];
    }
}
@end
