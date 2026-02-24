//
//  LanguageCell.m
//  phonelive2
//
//  Created by 400 on 2021/8/16.
//  Copyright © 2021 toby. All rights reserved.
//

#import "LanguageCell.h"

@implementation LanguageCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self = [[XBundle currentXibBundleWithResourceName:@"LanguageCell"]loadNibNamed:@"LanguageCell" owner:self options:nil].lastObject;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
