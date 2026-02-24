//
//  ChartCollectionViewCell.m
//  phonelive2
//
//  Created by 400 on 2022/6/27.
//  Copyright © 2022 toby. All rights reserved.
//

#import "ChartCollectionViewCell.h"

@implementation ChartCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView1.backgroundColor = RGB_COLOR(@"#000000", 0.3);
    self.contentView2.backgroundColor = RGB_COLOR(@"#000000", 0.3);
    self.contentView3.backgroundColor = RGB_COLOR(@"#000000", 0.3);
    self.contentView4.backgroundColor = RGB_COLOR(@"#000000", 0.3);
    self.contentView5.backgroundColor = RGB_COLOR(@"#000000", 0.3);
    self.contentView6.backgroundColor = RGB_COLOR(@"#000000", 0.3);

//    UIImageView *subIm1 = [UIImageView]
    // Initialization code
}

@end
