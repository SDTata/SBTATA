//
//  YBNoWordView.m
//  yunbaolive
//
//  Created by Boom on 2018/10/31.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "YBNoWordView.h"

@implementation YBNoWordView{
    UIButton *refrashBtn;
}
- (instancetype)initWithImageName:(NSString *)imageName andTitle:(NSString *)title withBlock:(refrashBtnBlock)bbbbb AddTo:(UIView *)superView{
    self = [super init];
    [superView addSubview:self];
    self.frame = superView.bounds;
    self.block = bbbbb;
    if (self) {
        [self creatUIWithImageName:imageName andTitle:title];
    }
    self.hidden = YES;
    return self;
}
- (void)creatUIWithImageName:(nullable NSString *)imageName andTitle:(nullable NSString *)title{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 160, 70)];
    if (imageName) {
        imageView.image = [ImageBundle imagewithBundleName:imageName];
    }else{
        imageView.image = [ImageBundle imagewithBundleName:@"noNetWorking"];
    }
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, imageView.bottom+16, 160, 16)];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.textColor = RGB(124, 121, 124);//RGB_COLOR(@"#333333", 1);
    label1.font = [UIFont systemFontOfSize:13];
    if (title) {
        label1.text = title;
    }else{
        label1.text =YZMsg(@"public_networkError");
    }
    [self addSubview:label1];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(refrashBtnClick:)];
    [self addGestureRecognizer:tap];
    /*
    refrashBtn = [UIButton buttonWithType:0];
    refrashBtn.frame = CGRectMake(45, label1.bottom+12, 70, 25);
    refrashBtn.layer.cornerRadius = 12.5;
    refrashBtn.layer.masksToBounds = YES;
    [refrashBtn setBackgroundColor:normalColors];
    [refrashBtn setTitle:@"重试" forState:0];
    refrashBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [refrashBtn addTarget:self action:@selector(refrashBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:refrashBtn];
    */
}
- (void)refrashBtnClick:(UITapGestureRecognizer *)tap{
    self.block(nil);
}
- (void)layoutSubviews{
    [super layoutSubviews];
    for (UIView *v in self.subviews) {
        CGFloat width = self.width / 2.0;
        CGFloat wh = MIN(width, self.height - AD(14));
        if ([v isKindOfClass:[UIImageView class]]) {
            v.frame = CGRectMake((self.width - wh)/2.0,(self.height - wh)/2.0 - AD(14), wh, wh);
        }else if ([v isKindOfClass:[UILabel class]]){
            v.frame = CGRectMake(0, ((self.height - wh)/2.0 - AD(14)) + wh + AD(2), self.width, AD(12));
        }
    }
}

@end
