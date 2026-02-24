//
//  GameTypeCell.m
//  phonelive2
//
//  Created by lucas on 2021/4/16.
//  Copyright © 2021 toby. All rights reserved.
//

#import "GameTypeCell.h"
#import "UIImageView+WebCache.h"

@implementation GameTypeCell

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

- (void)setMeun:(rightMeun *)meun{
    _meun = meun;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.leftLab.textColor = selected?[UIColor whiteColor]:vkColorHex(0x97a4b0);
    if (self.selected) {
//        self.bgImgV.image = [ImageBundle imagewithBundleName:@"bg_act"];
        self.bgImgV.backgroundColor = vkColorHex(0x7341ff);
        if (self.meun.urlSelectName && self.meun.urlSelectName.length>0) {
            [self.imgV sd_setImageWithURL:[NSURL URLWithString:self.meun.urlSelectName]];
        }
    }else{
//        self.bgImgV.image = [ImageBundle imagewithBundleName:@"bg_nor"];
        self.bgImgV.backgroundColor = vkColorHex(0xffffff);
        if (self.meun.urlName && self.meun.urlName.length>0) {
            [self.imgV sd_setImageWithURL:[NSURL URLWithString:self.meun.urlName]];
        }
    }
}

-(void)setupUI{
    [self addSubview:self.bgImgV];
    [self.bgImgV addSubview:self.leftLab];
    [self.bgImgV addSubview:self.imgV];
    
    [self.bgImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.right.mas_equalTo(-12);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-10);
    }];

    [self.imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.left.mas_equalTo(8);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imgV.mas_right).offset(5);
        make.right.mas_equalTo(-5);
        make.centerY.mas_equalTo(0);
    }];
}

#pragma mark lazy
-(UILabel *)leftLab{
    if (!_leftLab) {
        _leftLab = [[UILabel alloc] init];
        _leftLab.font = [UIFont systemFontOfSize:14];
        _leftLab.textColor = RGB_COLOR(@"#483F9D", 1);
        _leftLab.adjustsFontSizeToFitWidth = YES;
        _leftLab.minimumScaleFactor = 0.2;
//        _leftLab.numberOfLines = 2;
        _leftLab.textAlignment = NSTextAlignmentCenter;
    }
    return _leftLab;
}

-(UIImageView *)bgImgV{
    if (!_bgImgV) {
//        _bgImgV = [[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:@"bg_nor"]];
        _bgImgV = [UIImageView new];
        _bgImgV.backgroundColor = UIColor.whiteColor;
        _bgImgV.layer.cornerRadius = 12;
        _bgImgV.layer.shadowOpacity = 0.3;
        _bgImgV.layer.shadowColor = RGB_COLOR(@"#664CCB", 1).CGColor;
        _bgImgV.layer.shadowOffset = CGSizeMake(0, 2);
    }
    return _bgImgV;
}

-(UIImageView *)imgV{
    if (!_imgV) {
        _imgV = [[UIImageView alloc] init];
        _imgV.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imgV;
}
@end
