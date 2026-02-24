//
//  BetOptionCollectionViewCell2.m
//

#import "BetOptionCollectionViewCell2.h"

@implementation BetOptionCollectionViewCell2

typedef NS_ENUM(NSInteger, DirectionStyle){
    DirectionStyleToUnder = 0,  //向下
    DirectionStyleToUn = 1      //向上
};

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setupDisplay{
    self.imageView.backgroundColor = RGB_COLOR(@"#5B5B5B", 0.4);
    [self setShadowDisplay:RGB_COLOR(@"#FF95CA", 1)];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if(selected) {
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.image = [UIView imageWithColors:@[vkColorRGBA(249 ,223, 247, 1), vkColorRGBA(244, 168, 224, 1)] size: CGSizeMake(100,40) isHorizontal:NO];
        self.imageView.layer.borderColor = vkColorRGBA(229, 136, 205, 1).CGColor;
        self.titile.textColor = vkColorRGBA(208, 43, 100, 1);
        self.rate.textColor = vkColorRGBA(208, 43, 100, 1);
    } else {
        self.imageView.backgroundColor = RGB_COLOR(@"#9D9D9D", 0.5);
        self.imageView.image = NULL;
        self.imageView.layer.borderColor = RGB_COLOR(@"#FF95CA", 1).CGColor;
        self.titile.textColor = self.result1Imageview.hidden ? UIColor.whiteColor : UIColor.blackColor;
        self.rate.textColor = UIColor.whiteColor;
        [self setShadowDisplay:RGB_COLOR(@"#c7c7c7", 0.4)];
    }
    // Configure the view for the selected state
}

-(void) setShadowDisplay:(UIColor *) borderColor{
    self.imageView.layer.cornerRadius = 10;                           //圆角弧度
    self.imageView.layer.borderWidth = 1.5;
    self.imageView.layer.borderColor = borderColor.CGColor;
    self.imageView.clipsToBounds = YES;
}

-(void) setText:(NSString *)text{
    self.titile.text = text;
    [self.titile setFont:[UIFont systemFontOfSize:16.f]];
    self.titile.adjustsFontSizeToFitWidth = YES;
    self.titile.minimumScaleFactor = 0.5;
    [self.titile setTextColor:[UIColor darkGrayColor]];
    self.result1Imageview.hidden = YES;
}

-(void) setNumber:(NSString*)number lotteryType:(NSInteger)lotteryType{
    self.titile.text = @"";
    [self.titile setFont:[UIFont boldSystemFontOfSize:17.f]];
    [self.titile setTextColor:[UIColor darkGrayColor]];
    
    self.result1Imageview.layer.cornerRadius = 0;
    self.result1Imageview.backgroundColor = [UIColor clearColor];
    if(lotteryType == 11 || lotteryType == 6){
        // 时时彩
        //self.backgroundImage.backgroundColor = [UIColor colorWithRed:218/255.0 green:28/255.0 blue:34/255.0 alpha:1];
        //self.backgroundImage.layer.cornerRadius = self.height / 2;
        self.result1Imageview.hidden = NO;
        [self.result1Imageview setImage:[ImageBundle imagewithBundleName:@"redball.png"]];
        self.titile.text = number;
        [self.titile setTextColor:[UIColor whiteColor]];
    }else if(lotteryType == 10){
//        // 牛牛
//        self.cardImage.hidden = NO;
//        self.backgroundImage.hidden = YES;
//        self.foregroundImage.hidden = YES;
//
//        NSInteger codeNumber = 1 + (arc4random() % 54);
//        NSString *imgName = [NSString stringWithFormat:@"poker_%d.jpg", codeNumber];
//        [self.cardImage setImage:[ImageBundle imagewithBundleName:imgName]];
//
//        if([number isEqualToString:@"vs"] || [number isEqualToString:@"VS"]){
//            self.cardImage.hidden = NO;
//            self.backgroundImage.hidden = YES;
//            self.foregroundImage.hidden = YES;
//            NSString *imgName = @"nn_vs.png";
//            [self.cardImage setImage:[ImageBundle imagewithBundleName:imgName]];
//        }
//        self.titile.text = @"";
//        [self.titile setTextColor:[UIColor whiteColor]];
    }else if(lotteryType == 14 || lotteryType == 9){
        // 赛车
//        self.backgroundImage.hidden = YES;
//        self.foregroundImage.hidden = NO;
//        [self.foregroundImage setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"14-%@.png", number]]];
//        self.titile.text = @"";
        
        self.result1Imageview.hidden = NO;
        self.result1Imageview.layer.cornerRadius = 5;
        NSInteger iNumber = [number integerValue];
        if(iNumber == 1){
            self.result1Imageview.backgroundColor = UIColorFromRGB(0xe6dc49);
        }
        if(iNumber == 2){
            self.result1Imageview.backgroundColor = UIColorFromRGB(0x3d92d7);
        }
        if(iNumber == 3){
            self.result1Imageview.backgroundColor = UIColorFromRGB(0x4b4b4b);
        }
        if(iNumber == 4){
            self.result1Imageview.backgroundColor = UIColorFromRGB(0xef7d31);
        }
        if(iNumber == 5){
            self.result1Imageview.backgroundColor = UIColorFromRGB(0x67dfe3);
        }
        if(iNumber == 6){
            self.result1Imageview.backgroundColor = UIColorFromRGB(0x4b3ff5);
        }
        if(iNumber == 7){
            self.result1Imageview.backgroundColor = UIColorFromRGB(0xbfbfbf);
        }
        if(iNumber == 8){
            self.result1Imageview.backgroundColor = UIColorFromRGB(0xeb3f25);
        }
        if(iNumber == 9){
            self.result1Imageview.backgroundColor = UIColorFromRGB(0x6e190b);
        }
        if(iNumber == 10){
            self.result1Imageview.backgroundColor = UIColorFromRGB(0x57bb37);
        }
        self.titile.text = [NSString stringWithFormat:@"%ld", (long)iNumber];
    }else if(lotteryType == 13 || lotteryType == 22 || lotteryType == 23 || lotteryType == 26 || lotteryType == 27){
        // 快三
        self.result1Imageview.hidden = NO;
        [self.result1Imageview setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@.png", number]]];
        
        self.titile.text = @"";
    }else if(lotteryType == 8 || lotteryType == 32 ||lotteryType == 7 ){
        // 六合彩
        NSInteger iNumber = [number integerValue];
        // 红波：01-02-07-08-12-13-18-19-23-24-29-30-34-35-40-45-46
        if(iNumber == 1 || iNumber == 2 || iNumber == 7 || iNumber == 8 || iNumber == 12 || iNumber == 13 || iNumber == 18 || iNumber == 19 || iNumber == 23 || iNumber == 24 || iNumber == 29 || iNumber == 30 || iNumber == 34 || iNumber == 35 || iNumber == 40 || iNumber == 45 || iNumber == 46){
            //[self.result1Imageview setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lhc-%@.png", @"red"]]];
            //[self.result1Imageview setBackgroundColor:RGB_COLOR(@"#ec4c3a", 1)];
            
            [self.titile setTextColor:RGB_COLOR(@"#ec4c3a", 1)];
            self.result1Imageview.layer.borderColor = RGB_COLOR(@"#ec4c3a", 1).CGColor;
            self.result1Imageview.layer.borderWidth = 1;
            [self.result1Imageview setBackgroundColor:[UIColor whiteColor]];
        }
        // 蓝波：03-04-09-10-14-15-20-25-26-31-36-37-41-42-47-48
        else if(iNumber == 3 || iNumber == 4 || iNumber == 9 || iNumber == 10 || iNumber == 14 || iNumber == 15 || iNumber == 20 || iNumber == 25 || iNumber == 25 || iNumber == 26 || iNumber == 31 || iNumber == 36 || iNumber == 37 || iNumber == 41 || iNumber == 42 || iNumber == 47 || iNumber == 48){
            //[self.result1Imageview setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lhc-%@.png", @"blue"]]];
            //[self.result1Imageview setBackgroundColor:RGB_COLOR(@"#398cef", 1)];
            
            [self.titile setTextColor:RGB_COLOR(@"#398cef", 1)];
            self.result1Imageview.layer.borderColor = RGB_COLOR(@"#398cef", 1).CGColor;
            self.result1Imageview.layer.borderWidth = 1;
            [self.result1Imageview setBackgroundColor:[UIColor whiteColor]];
        }
        // 绿波：05-06-11-16-17-21-22-27-28-32-33-38-39-43-44-49
        else if(iNumber == 5 || iNumber == 6 || iNumber == 11 || iNumber == 16 || iNumber == 17 || iNumber == 21 || iNumber == 22 || iNumber == 27 || iNumber == 28 || iNumber == 32 || iNumber == 33 || iNumber == 38 || iNumber == 39 || iNumber == 43 || iNumber == 44 || iNumber == 49){
            //[self.result1Imageview setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lhc-%@.png", @"green"]]];
            //[self.result1Imageview setBackgroundColor:RGB_COLOR(@"#4aa35a", 1)];
            
            [self.titile setTextColor:RGB_COLOR(@"#4aa35a", 1)];
            self.result1Imageview.layer.borderColor = RGB_COLOR(@"#4aa35a", 1).CGColor;
            self.result1Imageview.layer.borderWidth = 1;
            [self.result1Imageview setBackgroundColor:[UIColor whiteColor]];
        }
        self.result1Imageview.layer.cornerRadius = 14;
        
        if(iNumber > 0){
            //[self.titile setTextColor:[UIColor blackColor]];
            self.titile.text = [NSString stringWithFormat:@"%02ld", (long)iNumber];
            
            self.result1Imageview.hidden = NO;
        }else{
            //[self.titile setTextColor:[UIColor whiteColor]];
            self.titile.text = number;
            
            self.result1Imageview.hidden = YES;
        }
        [self.titile setFont:[UIFont boldSystemFontOfSize:15.f]];
    }else{
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@.(%ld) ",YZMsg(@"BetOption2_errorAlert"),(long)lotteryType]];
    }
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
- (UIImage *)LW_gradientColorWithRed:(CGFloat)red
                          green:(CGFloat)green
                           blue:(CGFloat)blue
                         endRed:(CGFloat)endRed
                       endGreen:(CGFloat)endGreen
                        endBlue:(CGFloat)endBlue
                     startAlpha:(CGFloat)startAlpha
                       endAlpha:(CGFloat)endAlpha
                      direction:(DirectionStyle)direction
                          frame:(CGRect)frame
{
    //底部上下渐变效果背景
    // The following methods will only return a 8-bit per channel context in the DeviceRGB color space. 通过图片上下文设置颜色空间间
    UIGraphicsBeginImageContext(frame.size);
    // 添加圆角
    [[UIBezierPath bezierPathWithRoundedRect:frame
                                cornerRadius:5] addClip];
    //获得当前的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //创建颜色空间 /* Create a DeviceRGB color space. */
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    //通过矩阵调整空间变换
    CGContextScaleCTM(context, frame.size.width, frame.size.height);
    
    //通过颜色组件获得渐变上下文
    CGGradientRef backGradient;
    //253.0/255.0, 163.0/255.0, 87.0/255.0, 1.0,
    if (direction == DirectionStyleToUnder) {
        //向下
        //设置颜色 矩阵
        CGFloat colors[] = {
            red, green, blue, startAlpha,
            endRed, endGreen, endBlue, endAlpha,
        };
        backGradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
    } else {
        //向上
        CGFloat colors[] = {
            endRed, endGreen, endBlue, endAlpha,
            red, green, blue, startAlpha,
        };
        backGradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
    }
    
    //释放颜色渐变
    CGColorSpaceRelease(rgb);
    //通过上下文绘画线色渐变
    CGContextDrawLinearGradient(context, backGradient, CGPointMake(0.5, 0), CGPointMake(0.5, 1), kCGGradientDrawsBeforeStartLocation);
    //通过图片上下文获得照片
    return UIGraphicsGetImageFromCurrentImageContext();
}

@end
