//
//  LiveOpenListYFKSCell.m
//  phonelive2
//
//  Created by lucas on 10/7/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LiveOpenListYFKSCell.h"

@implementation LiveOpenListYFKSCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setModel:(lastResultModel *)model{
    _model = model;
    self.issuLab.text = [NSString stringWithFormat:YZMsg(@"OpenHistory_DateNow%@"), model.issue];
    NSArray *open_result = [model.open_result componentsSeparatedByString:@","];
    NSInteger result_count = open_result.count;
    if (open_result.count>2) {
        [self.img1 setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@.png", open_result[0]]]];
        [self.img2 setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@.png", open_result[1]]]];
        [self.img3 setImage:[ImageBundle imagewithBundleName:[NSString stringWithFormat:@"kuaisan_bg%@.png", open_result[2]]]];
       
        NSArray *result_str = model.spare_2;
        if (result_str && result_str.count>2) {
            self.lab1.text = result_str[0];
            self.lab2.text = result_str[1];
            self.lab3.text = result_str[2];
            self.lab4.hidden = YES;
            self.lab2.hidden = NO;
            self.lab3.hidden = NO;
            [self.lab1 setBackgroundColor: UIColor.orangeColor];
            [self.lab2 setBackgroundColor: [result_str[1] isEqualToString:@"小"] ?  [UIColor colorWithRed:1/255.0 green:126/255.0 blue:72/255.0 alpha:1] : UIColor.redColor];
            [self.lab3 setBackgroundColor: [result_str[2] isEqualToString:@"单"] ?  [UIColor colorWithRed:1/255.0 green:126/255.0 blue:72/255.0 alpha:1] : UIColor.redColor];
        }else{
            self.lab4.hidden = NO;
            if (result_str.count ==1 ) {
                self.lab4.text = result_str[0];
            }
            self.lab1.text = open_result[0];
            
            self.lab2.hidden = YES;
            self.lab3.hidden = YES;
        }
       
    }
  
    
}

- (void)updateConstraintsForFullscreen {
    self.issuLabLeadiingConstraint.constant = 20;
    self.imgV1LeadiingConstraint.priority = 250;
    self.imgV1HorizontalConstraint.priority = 1000;
    self.imgV1HorizontalConstraint.constant = 10;
    self.rigthtLabTrailingConstraint.constant = 20;
}

@end
