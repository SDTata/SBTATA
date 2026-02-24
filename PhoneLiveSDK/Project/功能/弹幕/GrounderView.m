//
//  GrounderView.m
//  GrounderDemo
//
//  Created by 贾楠 on 16/3/8.
//  Copyright © 2016年 贾楠. All rights reserved.
//
#import "GrounderView.h"
#import "SDImageCache.h"
#import "UIButton+WebCache.h"
@interface GrounderView()<UIGestureRecognizerDelegate>
{
    UILabel * titleLabel;
    UIButton * headImage;
    UILabel * nameLabel;
    UIView * titleBgView;
    float viewWidth;
    UITapGestureRecognizer* singleTap;
    CAGradientLayer *titleBgViewLayer;
}
@end
@implementation GrounderView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 30/2;

        titleBgView = [[UIView alloc] init];
        titleBgView.layer.cornerRadius = 3;
        titleBgView.layer.masksToBounds = YES;
        [self addSubview:titleBgView];


        titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:12];
        [self addSubview:titleLabel];

        nameLabel = [[UILabel alloc] init];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:nameLabel];


        headImage = [[UIButton alloc] init];
        headImage.backgroundColor = [UIColor whiteColor];
        headImage.contentMode = UIViewContentModeScaleAspectFill;
        headImage.frame = CGRectMake(0, 0, 30, 30);
        headImage.layer.cornerRadius = 30/2;
        headImage.layer.borderWidth = 0.5;
        headImage.layer.masksToBounds = YES;
        headImage.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:headImage];

        titleBgViewLayer = [CAGradientLayer layer];
        titleBgViewLayer.colors = @[(__bridge id)RGB_COLOR(@"#F83600", 1).CGColor,(__bridge id)RGB_COLOR(@"#FACC22", 1).CGColor];
        titleBgViewLayer.startPoint = CGPointMake(0, 0);
        titleBgViewLayer.endPoint = CGPointMake(1.0, 0);
        [titleBgView.layer addSublayer:titleBgViewLayer];
    }
    return self;
}
- (void)setContent:(id)model{
        NSLog(@"%@",model);
    CGFloat addWidth = 40;
    nameLabel.text = [model valueForKey:@"name"];
    nameLabel.frame = CGRectMake(35, 2, [GrounderView calculateMsgWidth:nameLabel.text andWithLabelFont:[UIFont systemFontOfSize:10] andWithHeight:10], 10);
    titleLabel.text = [model valueForKey:@"title"];
    titleLabel.frame = CGRectMake(35, 12, [GrounderView calculateMsgWidth:titleLabel.text andWithLabelFont:[UIFont systemFontOfSize:12] andWithHeight:18]+20, 18);
    titleBgView.frame = CGRectMake(15, 12, [GrounderView calculateMsgWidth:titleLabel.text andWithLabelFont:[UIFont systemFontOfSize:12] andWithHeight:18]+addWidth-10, 17);
    viewWidth = titleLabel.frame.size.width + addWidth;
    if (nameLabel.frame.size.width > titleLabel.frame.size.width) {
        viewWidth = nameLabel.frame.size.width + addWidth;
    }
    [headImage sd_setImageWithURL:[NSURL URLWithString:[model valueForKey:@"icon"]] forState:UIControlStateNormal placeholderImage:[ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"]];
    [headImage addTarget:self action:@selector(clickIcon) forControlEvents:UIControlEventTouchUpInside];
    self.frame = CGRectMake(kScreenWidth + 20, self.selfYposition, viewWidth, 30);

    titleBgViewLayer.frame = titleBgView.bounds;
}
-(void)clickIcon
{
    NSLog(@"icon click");
}
- (void)grounderAnimation:(id)model{
    float second = 0.0;
    if (titleLabel.text.length < 30){
        second = 10.0f;
    }else{
        second = titleLabel.text.length/2.5;
    }
    self.userInteractionEnabled = YES;
    WeakSelf
    [UIView animateWithDuration:second delay:0 options:(UIViewAnimationOptionAllowUserInteraction) animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.frame = CGRectMake( - strongSelf->viewWidth - 20, strongSelf.frame.origin.y, strongSelf->viewWidth, 30);
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf removeFromSuperview];
        strongSelf.isShow = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"nextView" object:nil];
    }];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"nextView" object:nil];
}
+ (CGFloat)calculateMsgWidth:(NSString *)msg andWithLabelFont:(UIFont*)font andWithHeight:(NSInteger)height {
    if ([msg isEqual:@""]) {
        return 0;
    }
    CGFloat messageLableWidth = [msg boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:font}
                                                  context:nil].size.width;
    return messageLableWidth + 1;
}

@end
