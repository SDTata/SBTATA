//
//
#import "TYRotaryView.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"
#import "RotationModel.h"
#define perSection    M_PI*2/10

@interface TYRotaryView ()<CAAnimationDelegate>

@property (nonatomic, strong) UIImageView *gameBgView;
@property (nonatomic, assign) CGFloat lastAngle;

//@property (nonatomic, strong) UIImageView *textImgView;

@end

@implementation TYRotaryView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    self.gameBgView = [UIImageView new];
    self.gameBgView.image = [ImageBundle imagewithBundleName:@"rotation_group"];
    //self.gameBgView.layer.masksToBounds = YES;
    //self.gameBgView.layer.cornerRadius =  (315 - KPaddingR*2)*0.5f;
    [self addSubview:self.gameBgView];
    [self.gameBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0);
    }];
    
    
    self.startButton = [UIButton new];
    //[self.startButton setImage:[ImageBundle imagewithBundleName:YZMsg(@"TYRotaryView_jcdjcj")] forState:UIControlStateNormal];
    //[self.startButton setImage:[ImageBundle imagewithBundleName:YZMsg(@"TYRotaryView_jcdjcj")] forState:UIControlStateDisabled];
    [self.startButton setImage:[ImageBundle imagewithBundleName:YZMsg(@"rotaion_center_pointer")] forState:UIControlStateNormal];
    [self.startButton setImage:[ImageBundle imagewithBundleName:YZMsg(@"rotaion_center_pointer")] forState:UIControlStateDisabled];
    
    [self.startButton addTarget:self action:@selector(itemClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.startButton];
    
    
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
       // make.center.mas_equalTo(self);
       // make.width.height.mas_equalTo(80);
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-8);
        make.width.equalTo(@RatioBaseWidth375(65));
        make.height.equalTo(@RatioBaseWidth375(79));
    }];
    
//    [self.textImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.mas_equalTo(self);
//    }];
    [self loadTextLabel];
}
-(void)loadTextLabel{
    for (int i =0; i<10; i++) {
        UIView *bgView = [UIView new];
        bgView.tag = 301+i;
        [self.gameBgView addSubview:bgView];
        bgView.backgroundColor = [UIColor clearColor];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.gameBgView);
            make.width.mas_equalTo(self.gameBgView);
            make.height.mas_equalTo(20);
        }];
        
        UIImageView *imgV = [UIImageView new];
        imgV.tag = 100;
        imgV.backgroundColor = [UIColor clearColor];
        [bgView addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(bgView.mas_right).multipliedBy(0.71);
            make.centerY.mas_equalTo(bgView.mas_centerY);
            make.width.height.mas_equalTo(30);
        }];
        imgV.transform = CGAffineTransformRotate(imgV.transform,  M_PI/2);
        
        UILabel *label = [UILabel new];
        label.tag = 200;
        NSArray *textColors = @[RGB(137, 105, 246),
                                UIColor.whiteColor,
                                RGB(137, 105, 246),
                                RGB(137, 105, 246),
                                UIColor.whiteColor,
                                RGB(137, 105, 246),
                                RGB(92, 24, 200),
                                UIColor.whiteColor,
                                UIColor.whiteColor,
                                RGB(182, 189, 196)];
        label.textColor = textColors[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 1;
        label.font = [UIFont boldSystemFontOfSize:12];
        [bgView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(bgView.mas_right).multipliedBy(0.780);
            make.centerY.mas_equalTo(bgView.mas_centerY);
            make.height.mas_equalTo(20);
            make.width.mas_equalTo(60);
        }];
        label.transform = CGAffineTransformRotate(label.transform,  M_PI/2);
        
        
        UILabel *label1 = [UILabel new];
        label1.backgroundColor = RGB(160, 72, 249);
        label1.layer.cornerRadius = 5;
        label1.layer.masksToBounds = YES;
        label1.hidden = YES;
        label1.tag = 300;
        label1.textColor = [UIColor whiteColor];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.numberOfLines = 1;
        label1.font = [UIFont systemFontOfSize:8];
        [bgView addSubview:label1];
        [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(bgView.mas_right).multipliedBy(0.81);
            make.centerY.mas_equalTo(bgView.mas_centerY);
            make.height.mas_equalTo(10);
        }];
        label1.transform = CGAffineTransformRotate(label1.transform,  M_PI/2);
        
        bgView.transform = CGAffineTransformRotate(bgView.transform, (perSection*i +perSection*0.5) - perSection*3);

    }
}
-(void)itemClick{
    if (self.rotaryStartTurnBlock) {
        self.rotaryStartTurnBlock();
    }
}

-(void)loadLottery:(NSArray *)lotterysUI
{
    for (int i=0; i<lotterysUI.count; i++) {
        UIView *bgView = [self.gameBgView viewWithTag:301+i];
        UIImageView *imgV = [bgView viewWithTag:100];
        UILabel *label = [bgView viewWithTag:200];
        UILabel *label_time = [bgView viewWithTag:300];
        RotationSubModel *subModel = lotterysUI[i];
        NSURL *urlS = [NSURL URLWithString:subModel.item_icon];
        NSString *placeholderImage;
        if ([subModel.item_type isEqualToString:@"nothing"]) {
            placeholderImage = @"Luckydraw_nothing";
        } else if ([subModel.item_type isEqualToString:@"money"]) {
            placeholderImage = @"Luckydraw_money";
        } else if ([subModel.item_type isEqualToString:@"car"]) {
            placeholderImage = [NSString stringWithFormat:@"Luckydraw_%@%@",subModel.item_type, [subModel.item_name containsString:@"自行车"] ? @"2" : @""];
        }
        if (urlS) {
            [imgV sd_setImageWithURL:urlS placeholderImage:[ImageBundle imagewithBundleName:placeholderImage]];
        }
        if ([subModel.item_type isEqualToString:@"car"]) {
            // 正则表达式匹配方括号内的内容和方括号外的内容
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\](.*)" options:0 error:&error];
            if (!error) {
                NSTextCheckingResult *match = [regex firstMatchInString:subModel.item_name options:0 range:NSMakeRange(0, [subModel.item_name length])];
                if (match) {
                    // 提取方括号内的部分 (时间)
                    NSRange timeRange = [match rangeAtIndex:1];
                    NSString *timePart = [subModel.item_name substringWithRange:timeRange];
                    
                    // 提取方括号外的部分 (名称)
                    NSRange nameRange = [match rangeAtIndex:2];
                    NSString *namePart = [subModel.item_name substringWithRange:nameRange];
                    
                    label_time.hidden = NO;
                    label_time.text = [NSString stringWithFormat:@" %@ ",timePart];
                    label.text = namePart;
                }
            }
        } else if ([subModel.item_type isEqualToString:@"nothing"]) {
            label.text = subModel.item_name;
        } else {
            label.text = [YBToolClass getRateCurrency:minstr(subModel.item_num) showUnit:YES showComma:YES];
        }
//        if ([subModel.item_type isEqualToString:@"money"]) {
//            NSString *coin = minstr(subModel.item_num);
//            NSString *removeCommaCoin = [coin stringByReplacingOccurrencesOfString:@"," withString:@""];
//            NSString *currencyCoin = [YBToolClass getRateCurrency:removeCommaCoin showUnit:YES];
//            label1.text = currencyCoin;
//        } else {
//            label1.text = [NSString stringWithFormat:@"%@",subModel.item_num];
//        }
//
//        if (subModel.item_type&&[subModel.item_type isEqualToString:@"nothing"]) {
//            label1.text = @"";
//        }
    }
}
-(void)animationWithSelectonIndex:(NSInteger)index{
    
    [self backToStartPosition];
    self.startButton.enabled = NO;
   
    CABasicAnimation *layer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    
    //先转4圈 再选区 顺时针(所有这里需要用360-对应的角度) 逆时针不需要
    layer.toValue = @((M_PI*2 - (perSection*index )) + M_PI*2*4);
    layer.duration = 4;
    layer.removedOnCompletion = NO;
    layer.fillMode = kCAFillModeForwards;
    layer.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    layer.delegate = self;
    
    [self.gameBgView.layer addAnimation:layer forKey:nil];
}

-(void)backToStartPosition{
    CABasicAnimation *layer = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    layer.toValue = @(0);
    layer.duration = 0.001;
    layer.removedOnCompletion = NO;
    layer.fillMode = kCAFillModeForwards;
    [self.gameBgView.layer addAnimation:layer forKey:nil];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    //设置指针返回初始位置
    self.startButton.enabled = YES;
    if (self.rotaryEndTurnBlock) {
        self.rotaryEndTurnBlock();
    }
}
@end
