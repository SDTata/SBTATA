//
//  HANKCollectionViewCell.m
//  phonelive2
//
//  Created by user on 2023/11/13.
//  Copyright © 2023 toby. All rights reserved.
//

#import "BetOptionCollectionViewCell_Fullscreen.h"


@implementation BetOptionCollectionViewCell_Fullscreen

typedef NS_ENUM(NSInteger, DirectionStyle){
    DirectionStyleToUnder = 0,  //向下
    DirectionStyleToUn = 1      //向上
};

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    // Initialization code
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 15;                           //圆角弧度
//    self.imageView.layer.borderWidth = 1;
//    self.imageView.layer.borderColor=[UIColor colorWithRed:188/255.0 green:190/255.0 blue:197/255.0 alpha:0.3].CGColor;
    self.imageView.layer.shadowOffset = CGSizeMake(0.4, 0.4);             //阴影的偏移量
    ////    cell.layer.shadowRadius = 5;
    self.imageView.layer.shadowOpacity = 0.4;                         //阴影的不透明度
    self.imageView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;  //阴影的颜色
    
    self.titleCenterConstraint.constant = -10;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.5;
    self.rate.adjustsFontSizeToFitWidth = YES;
    self.rate.minimumScaleFactor = 0.7;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
//    if(selected){
//        self.imageView.image = [UIImage imageNamed:@"yfks_dx_di"];
//        self.titile.textColor = [UIColor whiteColor];
//    }else{
//        self.imageView.image = [UIImage imageNamed:@"yfks_czh_di"];
//        self.titile.textColor = [UIColor whiteColor];
//    }
    
    if(selected){
        self.imageView.image = [UIImage sd_imageWithColor:[UIColor colorWithRed:192/255.0 green:70/255.0 blue:176/255.0 alpha:1] size:CGSizeMake(250,250)] ;
        self.titleLabel.textColor = [UIColor whiteColor];
    }else{
        self.imageView.image = [UIImage sd_imageWithColor: RGB_COLOR(@"#000000", 0.22) size:CGSizeMake(250, 250)];
        self.titleLabel.textColor = [UIColor whiteColor];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.foregroundImage1.hidden = YES;
    self.foregroundImage2.hidden = YES;
    self.foregroundImage3.hidden = YES;
    self.titleLabel.hidden = NO;
}

- (void)setImage {
    if ([self.way containsString:@"豹子"]) {
        self.foregroundImage1.hidden = NO;
        self.foregroundImage2.hidden = NO;
        self.foregroundImage3.hidden = NO;
        self.titleLabel.hidden = ![self.titleLabel.text isEqualToString:@"1-6"];
        if (![self.titleLabel.text isEqualToString:@"1-6"]) {
            self.titleCenterConstraint.priority = 250;
            self.rateCenterConstraint.priority = 250;
        } else {
            self.titleCenterConstraint.priority = 1000;
            self.rateTopToTitleConstraint.priority = 250;
            self.rateCenterConstraint.priority = 250;
            self.rateTopToImage3Constraint.priority = 1000;
        }
        self.img3CenterConstraint.priority = 1000;
        self.img3CenterConstraint.constant = 20;
        [self.foregroundImage1 setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@.png", self.titleLabel.text]]];
        [self.foregroundImage2 setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@.png", self.titleLabel.text]]];
        [self.foregroundImage3 setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@.png", self.titleLabel.text]]];
    } else if ([self.way containsString:@"对子"]) {
        self.titleLabel.hidden = YES;
        self.foregroundImage2.hidden = NO;
        self.foregroundImage3.hidden = NO;
        [self.foregroundImage2 setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@.png", self.titleLabel.text]]];
        [self.foregroundImage3 setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@.png", self.titleLabel.text]]];
        self.rateCenterConstraint.priority = 250;
        self.img3CenterConstraint.priority = 1000;
        self.rateTopToTitleConstraint.priority = 250;
        self.rateTopToImage3Constraint.priority = 1000;
        self.img3CenterConstraint.constant = 5;

    } else if ([self.way containsString:@"单骰"]) {
        self.titleLabel.hidden = YES;
        self.foregroundImage3.hidden = NO;
        [self.foregroundImage3 setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@.png", self.titleLabel.text]]];
        self.rateCenterConstraint.priority = 250;
        self.img3CenterConstraint.priority = 1000;
        self.img3CenterConstraint.constant = -10;
    }
    self.img1WidthConstraint.constant = ((SCREEN_WIDTH / 7) / 2);
    self.img2WidthConstraint.constant = ((SCREEN_WIDTH / 7) / 2);
    self.img3WidthConstraint.constant = ((SCREEN_WIDTH / 7) / 2);
}

/**
 *  渐变色
 *  @param red              红色
 *  @param green            绿色
 *  @param blue             蓝色
 *  @param startAlpha       开始的透明度
 *  @param endAlpha         结束的透明度
 *  @param direction        那个方向
 *  @param frame            大小
 */
//- (UIImage *)LW_gradientColorWithRed:(CGFloat)red
//                          green:(CGFloat)green
//                           blue:(CGFloat)blue
//                         endRed:(CGFloat)endRed
//                       endGreen:(CGFloat)endGreen
//                        endBlue:(CGFloat)endBlue
//                     startAlpha:(CGFloat)startAlpha
//                       endAlpha:(CGFloat)endAlpha
//                      direction:(DirectionStyle)direction
//                          frame:(CGRect)frame
//{
//    //底部上下渐变效果背景
//    // The following methods will only return a 8-bit per channel context in the DeviceRGB color space. 通过图片上下文设置颜色空间间
//    UIGraphicsBeginImageContext(frame.size);
//    // 添加圆角
//    [[UIBezierPath bezierPathWithRoundedRect:frame
//                                cornerRadius:10] addClip];
//    //获得当前的上下文
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    //创建颜色空间 /* Create a DeviceRGB color space. */
//    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
//    //通过矩阵调整空间变换
//    CGContextScaleCTM(context, frame.size.width, frame.size.height);
//
//    //通过颜色组件获得渐变上下文
//    CGGradientRef backGradient;
//    //253.0/255.0, 163.0/255.0, 87.0/255.0, 1.0,
////    if (direction == DirectionStyleToUnder) {
////        //向下
////        //设置颜色 矩阵
////        CGFloat colors[] = {
////            red, green, blue, startAlpha,
////            endRed, endGreen, endBlue, endAlpha,
////        };
////        backGradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
////    } else {
////        //向上
////        CGFloat colors[] = {
////            endRed, endGreen, endBlue, endAlpha,
////            red, green, blue, startAlpha,
////        };
////        backGradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
////    }
//
//    //释放颜色渐变
//    CGColorSpaceRelease(rgb);
//    //通过上下文绘画线色渐变
////    CGContextDrawLinearGradient(context, nil, CGPointMake(0.5, 0), CGPointMake(0.5, 1), kCGGradientDrawsBeforeStartLocation);
//    //通过图片上下文获得照片
//    return UIGraphicsGetImageFromCurrentImageContext();
//}

@end
