//
//  IssueCollectionViewCell.m
//

#import "IssueCollectionViewCell.h"

@implementation IssueCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//- (void)setSelected:(BOOL)selected {
//    [super setSelected:selected];
//}
-(void)setNumber:(NSString*)number lotteryType:(NSInteger)lotteryType {
    [self setNumber:number lotteryType:lotteryType isFullscreen: NO];
}

-(void)setNumber:(NSString*)number lotteryType:(NSInteger)lotteryType isFullscreen:(BOOL)isFullscreen {
    
//    self.backgroundImage.hidden = YES;
//    self.foregroundImage.hidden = YES;
    self.titile.text = @"";
    [self.titile setFont:[UIFont systemFontOfSize:17.f]];
    self.titile.adjustsFontSizeToFitWidth = YES;
    self.titile.minimumScaleFactor = 0.2;
    self.backgroundImage.layer.cornerRadius = 0;
    self.backgroundImage.backgroundColor = [UIColor clearColor];
    if(lotteryType == 11 || lotteryType == 6){
        // 时时彩
        //self.backgroundImage.backgroundColor = [UIColor colorWithRed:218/255.0 green:28/255.0 blue:34/255.0 alpha:1];
        //self.backgroundImage.layer.cornerRadius = self.height / 2;
        self.backgroundImage.hidden = NO;
        self.foregroundImage.hidden = YES;
        
        if (_isSpareType) {
            NSString *checkedNumString = [number stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
            if (checkedNumString.length > 0) {
                self.backgroundImage.backgroundColor = ([number isEqualToString:@"小"] || [number isEqualToString:@"单"]) ? [UIColor colorWithRed:1/255.0 green:126/255.0 blue:72/255.0 alpha:1] : UIColor.redColor;
            } else {
                self.backgroundImage.backgroundColor = [UIColor orangeColor];
            }
            self.backgroundImage.image = nil;
            self.backgroundImage.layer.cornerRadius = 8;
        } else {
            [self.backgroundImage setImage:[ImageBundle imagewithBundleName:@"redball.png"]];
        }
        self.titile.text = number;
        [self.titile setTextColor:[UIColor whiteColor]];
    }else if(lotteryType == 10){
        // 牛牛
        self.cardImage.hidden = NO;
        self.backgroundImage.hidden = YES;
        self.foregroundImage.hidden = YES;
        
        NSString *imgName = minstr([PublicObj getPokerNameBy:number]);
        [self.cardImage setImage:[ImageBundle imagewithBundleName:imgName]];
        self.cardImage.contentMode = UIViewContentModeScaleAspectFit;
        if([number isEqualToString:@"vs"] || [number isEqualToString:@"VS"]){
            self.cardImage.hidden = NO;
            self.backgroundImage.hidden = YES;
            self.foregroundImage.hidden = YES;
            NSString *imgName = @"nn_vs.png";
            [self.cardImage setImage:[ImageBundle imagewithBundleName:imgName]];
        }
        self.titile.text = @"";
        [self.titile setTextColor:[UIColor whiteColor]];
    }else if(lotteryType == 14 || lotteryType == 9){
        // 赛车
//        self.backgroundImage.hidden = YES;
//        self.foregroundImage.hidden = NO;
//        [self.foregroundImage setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"14-%@.png", number]]];
//        self.titile.text = @"";
        
        self.backgroundImage.hidden = NO;
        self.foregroundImage.hidden = YES;
        self.backgroundImage.layer.cornerRadius = 5;
        NSInteger iNumber = [number integerValue];
        if(iNumber == 1){
            self.backgroundImage.backgroundColor = UIColorFromRGB(0xe6dc49);
        }
        if(iNumber == 2){
            self.backgroundImage.backgroundColor = UIColorFromRGB(0x3d92d7);
        }
        if(iNumber == 3){
            self.backgroundImage.backgroundColor = UIColorFromRGB(0x4b4b4b);
        }
        if(iNumber == 4){
            self.backgroundImage.backgroundColor = UIColorFromRGB(0xef7d31);
        }
        if(iNumber == 5){
            self.backgroundImage.backgroundColor = UIColorFromRGB(0x67dfe3);
        }
        if(iNumber == 6){
            self.backgroundImage.backgroundColor = UIColorFromRGB(0x4b3ff5);
        }
        if(iNumber == 7){
            self.backgroundImage.backgroundColor = UIColorFromRGB(0xbfbfbf);
        }
        if(iNumber == 8){
            self.backgroundImage.backgroundColor = UIColorFromRGB(0xeb3f25);
        }
        if(iNumber == 9){
            self.backgroundImage.backgroundColor = UIColorFromRGB(0x6e190b);
        }
        if(iNumber == 10){
            self.backgroundImage.backgroundColor = UIColorFromRGB(0x57bb37);
        }
        self.titile.text = [NSString stringWithFormat:@"%ld", iNumber];
    }else if(lotteryType == 13 || lotteryType == 22 || lotteryType == 23 || lotteryType == 26 || lotteryType == 27){
        // 快三
        self.backgroundImage.hidden = YES;
        self.foregroundImage.hidden = NO;
        
        if (_isSpareType) {
            NSString *checkedNumString = [number stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
            if (checkedNumString.length > 0) {
                self.backgroundImage.backgroundColor = ([number isEqualToString:@"小"] ||  [number isEqualToString:@"单"]) ? [UIColor colorWithRed:1/255.0 green:126/255.0 blue:72/255.0 alpha:1] : UIColor.redColor;
            } else {
                self.backgroundImage.backgroundColor = [UIColor orangeColor];
            }
            self.titile.text = number;
            [self.titile setTextColor:[UIColor whiteColor]];
            self.backgroundImage.hidden = NO;
            self.foregroundImage.hidden = YES;
            
            self.backgroundImage.layer.cornerRadius = 8;
        } else {
            self.backgroundImage.hidden = YES;
            self.foregroundImage.hidden = NO;
            [self.foregroundImage setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@.png", number]]];
            self.titile.text = @"";
        }
        
    }else if(lotteryType == 8||lotteryType == 7||lotteryType == 32){
        // 六合彩
        NSInteger iNumber = [number integerValue];
        // 红波：01-02-07-08-12-13-18-19-23-24-29-30-34-35-40-45-46
        if(iNumber == 1 || iNumber == 2 || iNumber == 7 || iNumber == 8 || iNumber == 12 || iNumber == 13 || iNumber == 18 || iNumber == 19 || iNumber == 23 || iNumber == 24 || iNumber == 29 || iNumber == 30 || iNumber == 34 || iNumber == 35 || iNumber == 40 || iNumber == 45 || iNumber == 46){
            [self.foregroundImage setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lhc-%@.png", @"red"]]];
        }
        // 蓝波：03-04-09-10-14-15-20-25-26-31-36-37-41-42-47-48
        else if(iNumber == 3 || iNumber == 4 || iNumber == 9 || iNumber == 10 || iNumber == 14 || iNumber == 15 || iNumber == 20 || iNumber == 25 || iNumber == 25 || iNumber == 26 || iNumber == 31 || iNumber == 36 || iNumber == 37 || iNumber == 41 || iNumber == 42 || iNumber == 47 || iNumber == 48){
            [self.foregroundImage setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lhc-%@.png", @"blue"]]];
        }
        // 绿波：05-06-11-16-17-21-22-27-28-32-33-38-39-43-44-49
        else if(iNumber == 5 || iNumber == 6 || iNumber == 11 || iNumber == 16 || iNumber == 17 || iNumber == 21 || iNumber == 22 || iNumber == 27 || iNumber == 28 || iNumber == 32 || iNumber == 33 || iNumber == 38 || iNumber == 39 || iNumber == 43 || iNumber == 44 || iNumber == 49){
            [self.foregroundImage setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"lhc-%@.png", @"green"]]];
        }
        
        
        if(iNumber > 0){
            [self.titile setTextColor:[UIColor blackColor]];
            self.titile.text = [NSString stringWithFormat:@"%02ld", (long)iNumber];
            
            self.backgroundImage.hidden = YES;
            self.foregroundImage.hidden = NO;
        }else{
            [self.titile setTextColor:[UIColor whiteColor]];
            self.titile.text = number;
            
            self.backgroundImage.hidden = YES;
            self.foregroundImage.hidden = YES;
        }
        [self.titile setFont:[UIFont systemFontOfSize:15.f]];
    }else if(lotteryType == 28 || lotteryType == 31){
      
        if (_isOldType) {
            self.backgroundImage.hidden = NO;
            self.backgroundImage.image = [[UIImage sd_imageWithColor:[UIColor colorWithWhite:0 alpha:0.4] size:CGSizeMake(self.width-20, self.height)] sd_imageByRoundCornerRadius:self.height/2.0];
            self.backgroundImage.contentMode = UIViewContentModeScaleToFill;
        }else{
            self.backgroundImage.hidden = NO;
            self.backgroundImage.backgroundColor = ([number isEqualToString:@"闲胜"] || [number isEqualToString:@"龙"]) ? [UIColor colorWithRed:0/255.0 green:72/255.0 blue:255/255.0 alpha:1] : UIColor.redColor;
            self.backgroundImage.layer.cornerRadius = 8;
        }
       
        self.foregroundImage.hidden = YES;
        [self.titile setFont:[UIFont systemFontOfSize:12.f]];
        
        self.titile.text =  [NSString stringWithFormat:@"%@ ",number];
    }else if(lotteryType == 30){
        self.backgroundImage.hidden = NO;
        self.foregroundImage.hidden = YES;
        
        NSArray * arr = @[@"32",@"4",@"21",@"25",@"34",@"27",@"36",@"30",@"23",@"5",@"16",@"1",@"14",@"9",@"18",@"7",@"12",@"3"];
        if ([number isEqualToString:@"0"]) {
            self.backgroundImage.backgroundColor = [UIColor greenColor];
        }else if ([arr containsObject:number]){
            self.backgroundImage.backgroundColor = [UIColor redColor];
        }else{
            self.backgroundImage.backgroundColor = [UIColor blackColor];
        }
        [self.titile setFont:[UIFont systemFontOfSize:14.f]];
        if (isFullscreen) {
            self.backgroundImageWidthConstraint.priority = 1000;
            self.backgroundImageLeadiingConstraint.priority = 750;
            self.backgroundImageTrailingConstraint.priority = 750;
            [self.contentView layoutIfNeeded];
            self.backgroundImage.layer.cornerRadius = self.backgroundImage.frame.size.width / 2.0;
            self.backgroundImage.layer.masksToBounds = YES;
            self.titile.text =  number;
        } else {
            self.backgroundImage.layer.cornerRadius = 17.5;
            self.titile.text =  [NSString stringWithFormat:@" %@ ",number];
        }
    }else if(lotteryType == 29){
       
        if (_isOldType) {
            self.backgroundImage.hidden = NO;
            self.backgroundImage.image = [[UIImage sd_imageWithColor:[UIColor colorWithWhite:0 alpha:0.4] size:CGSizeMake(self.width-20, self.height)] sd_imageByRoundCornerRadius:self.height/2.0];
            self.backgroundImage.contentMode = UIViewContentModeScaleToFill;
            
            self.backgroundImage.hidden = NO;
            self.foregroundImage.hidden = NO;
            self.foregroundImage.contentMode = UIViewContentModeScaleAspectFit;
            if ([number containsString:@"玩家一"]) {
                self.foregroundImage.image = [ImageBundle imagewithBundleName:@"zjh_player_1"];
            }else if ([number containsString:@"玩家二"]) {
                self.foregroundImage.image = [ImageBundle imagewithBundleName:@"zjh_player_2"];
            }else if ([number containsString:@"玩家三"]) {
                self.foregroundImage.image = [ImageBundle imagewithBundleName:@"zjh_player_3"];
            }
            
        }else{
            self.backgroundImage.hidden = NO;
            self.foregroundImage.hidden = YES;
            self.backgroundImage.contentMode = UIViewContentModeScaleAspectFit;
            if ([number containsString:@"玩家一"]) {
                self.backgroundImage.image = [ImageBundle imagewithBundleName:@"zjh_player_1"];
            }else if ([number containsString:@"玩家二"]) {
                self.backgroundImage.image = [ImageBundle imagewithBundleName:@"zjh_player_2"];
            }else if ([number containsString:@"玩家三"]) {
                self.backgroundImage.image = [ImageBundle imagewithBundleName:@"zjh_player_3"];
            }
        }
        
    }else{
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@(%ld)",YZMsg(@"BetOption2_errorAlert"),lotteryType]];
    }
    
}

@end
