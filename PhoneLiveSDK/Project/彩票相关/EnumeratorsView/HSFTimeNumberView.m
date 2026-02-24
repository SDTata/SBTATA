//
//  HSFTimeNumberView.m
//  TimeLabel
//
//  Created by 黄山锋 on 2018/7/16.
//  Copyright © 2018年 JustCompareThin. All rights reserved.
//

#import "HSFTimeNumberView.h"

@interface HSFTimeNumberView()

@property(nonatomic,strong)UILabel *label0;
@property(nonatomic,strong)UILabel *label1;
@property(nonatomic,assign)NSInteger maxNumber;

@property (nonatomic,strong) UIColor *bgColor;//背景颜色
@property (nonatomic,assign) CGFloat fontSize;//字体大小
@property (nonatomic,strong) UIColor *fontColor;//字体颜色
@property (nonatomic,assign) CGFloat cornerRadius;//圆角

@end

@implementation HSFTimeNumberView
/* 初始化方法 */
-(instancetype)initWithFrame:(CGRect)frame maxNumber:(NSInteger)maxNumber fontSize:(CGFloat)fontSize fontColor:(UIColor *)fontColor bgColor:(UIColor *)bgColor cornerRadius:(CGFloat)cornerRadius{
    if (self = [super initWithFrame:frame]) {
        //初始化赋值
        self.maxNumber = maxNumber;
        self.fontSize = fontSize;
        self.fontColor = fontColor;
        self.bgColor = bgColor;
        self.cornerRadius = cornerRadius;
        
        //frame
        CGFloat w = frame.size.width;
        CGFloat h = frame.size.height;
        
        self.contentSize = CGSizeMake(w, h*2);
        self.contentOffset = CGPointMake(0, h);
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        self.backgroundColor = self.bgColor;
        self.layer.cornerRadius = self.cornerRadius;
        self.scrollEnabled = NO;
        
        self.label0 = [[UILabel alloc]initWithFrame:CGRectMake(0, h, w, h)];
        self.label0.textAlignment = NSTextAlignmentCenter;
        self.label0.font = [UIFont systemFontOfSize:self.fontSize];
        self.label0.textColor = self.fontColor;
        [self addSubview:self.label0];
        self.label0.text = @"0";
        
        self.label1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, w, h)];
        self.label1.textAlignment = NSTextAlignmentCenter;
        self.label1.font = [UIFont systemFontOfSize:self.fontSize];
        self.label1.textColor = self.fontColor;
        [self addSubview:self.label1];
        self.label1.text = @"0";
    }
    return self;
}

- (void)setCurentNumber:(NSInteger)curentNumber{
    if (curentNumber > self.maxNumber) {
        curentNumber = self.maxNumber;
    }
    if (curentNumber < 0) {
        curentNumber = 0;
    }
    _curentNumber = curentNumber;

    self.label0.text=[NSString stringWithFormat:@"%ld",(long)curentNumber];
    NSInteger next=curentNumber-1;
    if (next<0) {
        next=self.maxNumber;
    }
    self.label1.text=[NSString stringWithFormat:@"%ld",(long)next];
}

-(void)numberChange{
    WeakSelf
    [UIView animateWithDuration:0.5 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.contentOffset=CGPointMake(0, 0);
    } completion:^(BOOL finished) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf.curentNumber--;
        if (strongSelf.curentNumber<0) {
            strongSelf.curentNumber=strongSelf.maxNumber;
        }
        strongSelf.label0.text=[NSString stringWithFormat:@"%ld",(long)strongSelf.curentNumber];
        strongSelf.contentOffset=CGPointMake(0, strongSelf.frame.size.height);
        NSInteger next=strongSelf.curentNumber-1;
        if (next<0) {
            next=strongSelf.maxNumber;
        }
        strongSelf.label1.text=[NSString stringWithFormat:@"%ld",(long)next];
    }];
}

@end
