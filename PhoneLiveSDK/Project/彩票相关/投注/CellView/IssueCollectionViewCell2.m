//
//  IssueCollectionViewCell2.m
//

#import "IssueCollectionViewCell2.h"

@implementation IssueCollectionViewCell2

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.titile setFont:[UIFont boldSystemFontOfSize:17.f]];
    self.titile.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.titile.layer.shadowOffset = CGSizeMake(0, 0);
    self.titile.layer.shadowRadius = 1;
    self.titile.adjustsFontSizeToFitWidth = YES;
    self.titile.minimumScaleFactor = 0.5;
    
    self.extendLabel.adjustsFontSizeToFitWidth = YES;
    self.extendLabel.minimumScaleFactor = 0.5;
    // Initialization code
}

//- (void)setSelected:(BOOL)selected {
//    [super setSelected:selected];
//}

-(void)resetDisplay:(NSInteger)lotteryType{
    self.extendLabel.hidden = YES;
    self.titile.text = @"";
    
    // 分析 和 赛车才有阴影
    if(lotteryType == 0 || [GameToolClass isSC:lotteryType]){
        self.titile.layer.shadowOpacity = 0.4;
    }else{
        self.titile.layer.shadowOpacity = 0;
    }
    
    self.result1Imageview.layer.cornerRadius = 0;
    self.result1Imageview.backgroundColor = [UIColor clearColor];
    [self.result1Imageview mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY).offset(0);
        make.centerX.equalTo(self.mas_centerX).offset(0);
        make.width.equalTo(self.mas_width);
        make.height.equalTo(self.mas_width);
    }];
    [self.extendLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY).offset(0);
    }];
}

-(void)setAnalysis:(NSString *)resultStr{
    [self resetDisplay:0];
    resultStr = minstr(resultStr);
    self.titile.text = resultStr;
    [self.titile setFont:[UIFont boldSystemFontOfSize:12.f]];
    [self.titile setTextColor:[UIColor whiteColor]];
    [self.result1Imageview setImage:nil];
    self.result1Imageview.layer.borderWidth = 0;
    self.result1Imageview.layer.cornerRadius = 3;
    if([resultStr containsString:@"单"] || [resultStr containsString:@"小"] || [resultStr containsString:@"虎"]){
        [self.result1Imageview setBackgroundColor:RGB_COLOR(@"#51a6f0", 1)];
    }else{
        [self.result1Imageview setBackgroundColor:RGB_COLOR(@"#c23931", 1)];
    }
    [self.result1Imageview mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY).offset(0);
        make.centerX.equalTo(self.mas_centerX).offset(0);
        make.width.equalTo(self.mas_width).offset(0);
        make.height.equalTo(self.mas_height).offset(0);
    }];
    [self.result1Imageview layoutIfNeeded];
}

-(void)setNumber:(NSString*)number lotteryType:(NSInteger)lotteryType extinfo:(id)extinfo{
    [self resetDisplay:lotteryType];
    if(lotteryType == 11 || lotteryType == 6){
        // 时时彩
        //self.backgroundImage.backgroundColor = [UIColor colorWithRed:218/255.0 green:28/255.0 blue:34/255.0 alpha:1];
        //self.backgroundImage.layer.cornerRadius = self.height / 2;
        self.result1Imageview.hidden = NO;
        [self.result1Imageview setImage:[ImageBundle imagewithBundleName:@"redball.png"]];
        self.titile.text = number;
        [self.titile setTextColor:[UIColor whiteColor]];
    }else if(lotteryType == 10){
        // 牛牛
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
        self.titile.text = [NSString stringWithFormat:@"%ld", iNumber];
    }else if(lotteryType == 13 || lotteryType == 22 || lotteryType == 23 || lotteryType == 26 || lotteryType == 27){
        // 快三
        self.result1Imageview.hidden = NO;
        
        [self.result1Imageview setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@.png", number]]];
        
        self.titile.text = @"";
    }else if(lotteryType == 8 ||lotteryType == 32 ||lotteryType == 7 ){
        BOOL isTeMa = false;
        if(extinfo){
            NSInteger index = [extinfo[@"index"] integerValue];
            if(index == 7){
                isTeMa = true;
            }
        }
        // 六合彩
        NSInteger iNumber = [number integerValue];
        // 红波：01-02-07-08-12-13-18-19-23-24-29-30-34-35-40-45-46
        if(iNumber == 1 || iNumber == 2 || iNumber == 7 || iNumber == 8 || iNumber == 12 || iNumber == 13 || iNumber == 18 || iNumber == 19 || iNumber == 23 || iNumber == 24 || iNumber == 29 || iNumber == 30 || iNumber == 34 || iNumber == 35 || iNumber == 40 || iNumber == 45 || iNumber == 46){
            //[self.foregroundImage setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lhc-%@.png", @"red"]]];
            
            
            self.result1Imageview.layer.borderColor = RGB_COLOR(@"#ec4c3a", 1).CGColor;
            self.result1Imageview.layer.borderWidth = 1;
            if(isTeMa){
                [self.titile setTextColor:[UIColor whiteColor]];
                [self.result1Imageview setBackgroundColor:RGB_COLOR(@"#ec4c3a", 1)];
            }else{
                [self.titile setTextColor:RGB_COLOR(@"#ec4c3a", 1)];
                [self.result1Imageview setBackgroundColor:[UIColor whiteColor]];
            }
        }
        // 蓝波：03-04-09-10-14-15-20-25-26-31-36-37-41-42-47-48
        else if(iNumber == 3 || iNumber == 4 || iNumber == 9 || iNumber == 10 || iNumber == 14 || iNumber == 15 || iNumber == 20 || iNumber == 25 || iNumber == 25 || iNumber == 26 || iNumber == 31 || iNumber == 36 || iNumber == 37 || iNumber == 41 || iNumber == 42 || iNumber == 47 || iNumber == 48){
            //[self.foregroundImage setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lhc-%@.png", @"blue"]]];

            self.result1Imageview.layer.borderColor = RGB_COLOR(@"#398cef", 1).CGColor;
            self.result1Imageview.layer.borderWidth = 1;
            if(isTeMa){
                [self.titile setTextColor:[UIColor whiteColor]];
                [self.result1Imageview setBackgroundColor:RGB_COLOR(@"#398cef", 1)];
            }else{
                [self.titile setTextColor:RGB_COLOR(@"#398cef", 1)];
                [self.result1Imageview setBackgroundColor:[UIColor whiteColor]];
            }
        }
        // 绿波：05-06-11-16-17-21-22-27-28-32-33-38-39-43-44-49
        else if(iNumber == 5 || iNumber == 6 || iNumber == 11 || iNumber == 16 || iNumber == 17 || iNumber == 21 || iNumber == 22 || iNumber == 27 || iNumber == 28 || iNumber == 32 || iNumber == 33 || iNumber == 38 || iNumber == 39 || iNumber == 43 || iNumber == 44 || iNumber == 49){
            //[self.foregroundImage setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lhc-%@.png", @"green"]]];
            
            self.result1Imageview.layer.borderColor = RGB_COLOR(@"#4aa35a", 1).CGColor;
            self.result1Imageview.layer.borderWidth = 1;
            if(isTeMa){
                [self.titile setTextColor:[UIColor whiteColor]];
                [self.result1Imageview setBackgroundColor:RGB_COLOR(@"#4aa35a", 1)];
            }else{
                [self.titile setTextColor:RGB_COLOR(@"#4aa35a", 1)];
                [self.result1Imageview setBackgroundColor:[UIColor whiteColor]];
            }
        }
        self.result1Imageview.layer.cornerRadius = self.width / 2;
        [self.result1Imageview mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY).offset(-5);
        }];
        
        
        if(iNumber > 0){
            //[self.titile setTextColor:[UIColor blackColor]];
            self.titile.text = [NSString stringWithFormat:@"%02ld", (long)iNumber];
            
            if(extinfo){
                NSInteger index = [extinfo[@"index"] integerValue];
                NSString *extString = extinfo[@"info"][index];
                self.extendLabel.hidden = NO;
                [self.extendLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.mas_centerY).offset(15);
                }];
                self.extendLabel.text = extString;
                [self.extendLabel setTextColor:[UIColor darkGrayColor]];
                [self.extendLabel setFont:[UIFont systemFontOfSize:9.f]];
            }
            
            self.result1Imageview.hidden = NO;
        }else{
            [self.titile setTextColor:[UIColor blackColor]];
            self.titile.text = number;
            
            self.result1Imageview.hidden = YES;
        }
        [self.titile setFont:[UIFont boldSystemFontOfSize:15.f]];
    }else{
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@(%ld)",YZMsg(@"BetOption2_errorAlert"),lotteryType]];
    }
    
}

@end
