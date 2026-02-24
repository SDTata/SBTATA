//
//  LotteryTypeListCell.m
//  phonelive2
//
//  Created by lucas on 2021/4/10.
//  Copyright © 2021 toby. All rights reserved.
//

#import "LotteryTypeListCell.h"

@implementation LotteryTypeListCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupUI];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    //self.leftLab.textColor = selected?[UIColor whiteColor]:RGB_COLOR(@"#666666", 1);
    if (self.selected) {
        self.bjView.image = [ImageBundle imagewithBundleName:@"bg_dh"];
    }else{
        self.bjView.image = NULL;
    }
}

-(void)setupUI{
    [self.contentView addSubview:self.bjView];
    [self.bjView addSubview:self.leftLab];
    
    [self.bjView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.mas_equalTo(self).inset(2);
        make.leading.mas_equalTo(self).offset(6);
    }];
    
    [self.leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bjView);
    }];
}

#pragma mark lazy
-(UILabel *)leftLab{
    if (!_leftLab) {
        _leftLab = [[UILabel alloc] init];
        _leftLab.font = [UIFont boldSystemFontOfSize:14];
        //_leftLab.textColor = RGB_COLOR(@"#666666", 1);
        _leftLab.textColor = UIColor.whiteColor;
        _leftLab.textAlignment = NSTextAlignmentCenter;
        _leftLab.adjustsFontSizeToFitWidth = YES;
        _leftLab.numberOfLines=2;
        _leftLab.lineBreakMode = NSLineBreakByWordWrapping;
        _leftLab.minimumScaleFactor = 0.5;
        _leftLab.layer.cornerRadius = 5;
        _leftLab.layer.masksToBounds = YES;
    }
    return _leftLab;
}

-(UIImageView *)bjView{
    if (!_bjView) {
        _bjView = [[UIImageView alloc] init];
        _bjView.backgroundColor = vkColorHexA(0x000000, 0.15);
        _bjView.layer.cornerRadius = 8;
        _bjView.layer.masksToBounds = YES;
        _bjView.layer.shadowOpacity = 0.1;
        _bjView.layer.shadowColor = RGB_COLOR(@"#949494", 1).CGColor;
        _bjView.layer.shadowOffset = CGSizeMake(0, 0);
    }
    return _bjView;
}




@end
