//
//  ExchangeRateCell.m
//  phonelive2
//
//  Created by lucas on 2021/9/24.
//  Copyright © 2021 toby. All rights reserved.
//

#import "ExchangeRateCell.h"

@implementation ExchangeRateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setupUI];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//    self.selectedBtn.selected = selected;
//}

-(void)setupUI{
//    [self addSubview:self.line];
    [self addSubview:self.nameLab];
    [self addSubview:self.currencyLab];
    [self addSubview:self.iconImgV];
    [self addSubview:self.selectedBtn];
    
//    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self);
//        make.height.mas_equalTo(1);
//        make.bottom.equalTo(self);
//    }];
    
    [self.iconImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(30);
    }];
    
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.iconImgV.mas_right).offset(10);
    }];
    
    [self.currencyLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.nameLab.mas_right).offset(10);
    }];
    
    [self.selectedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.contentView).offset(-20);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
}

#pragma mark lazy
-(UIView *)line{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = RGB_COLOR(@"#E3E3E3", 1);
    }
    return _line;
}


-(UILabel *)nameLab{
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.font = [UIFont systemFontOfSize:16];
        _nameLab.textColor = [UIColor blackColor];
        _nameLab.text = @"CN";
    }
    return _nameLab;
}

-(UILabel *)currencyLab{
    if (!_currencyLab) {
        _currencyLab = [[UILabel alloc] init];
        _currencyLab.font = [UIFont systemFontOfSize:16];
        _currencyLab.textColor = RGB_COLOR(@"#999999", 1);
        _currencyLab.text = @"(CNY)";
    }
    return _currencyLab;
}

-(UIImageView *)iconImgV{
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] initWithImage:[ImageBundle imagewithBundleName:@"C_CN"]];
        _iconImgV.layer.cornerRadius = 15;
        _iconImgV.layer.masksToBounds = YES;
    }
    return _iconImgV;
}

-(UIButton *)selectedBtn{
    if (!_selectedBtn) {
        _selectedBtn = [[UIButton alloc] init];
        [_selectedBtn setImage:[ImageBundle imagewithBundleName:@"selectedLanguage"] forState:UIControlStateSelected];
    }
    return _selectedBtn;
}



@end
