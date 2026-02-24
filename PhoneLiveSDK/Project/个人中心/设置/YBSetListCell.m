//
//  YBSetListCell.m
//  phonelive2
//
//  Created by lucas on 2021/4/8.
//  Copyright © 2021 toby. All rights reserved.
//

#import "YBSetListCell.h"

@implementation YBSetListCell

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

-(void)setupUI{
    [self addSubview:self.line];
    [self addSubview:self.nameLab];
    [self addSubview:self.versionLab];
    [self addSubview:self.detailsLab];
    [self addSubview:self.updateBtn];
    [self addSubview:self.switchButton];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(self);
    }];
    
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(17);
        make.height.equalTo(@44);
        make.width.equalTo(@150);
    }];
    
    [self.versionLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.nameLab.mas_right).offset(10);
    }];
    
    [self.detailsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-50);
    }];
    
    [self.updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-20);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(60);
    }];
    
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-20);
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
        _nameLab.font = [UIFont systemFontOfSize:15];
        _nameLab.textColor = RGB_COLOR(@"#333333", 1);
        _nameLab.numberOfLines = 2;
    }
    return _nameLab;
}

-(UILabel *)versionLab{
    if (!_versionLab) {
        _versionLab = [[UILabel alloc] init];
        _versionLab.font = [UIFont systemFontOfSize:15];
        _versionLab.textColor = RGB_COLOR(@"#333333", 1);
    }
    return _versionLab;
}

-(UILabel *)detailsLab{
    if (!_detailsLab) {
        _detailsLab = [[UILabel alloc] init];
        _detailsLab.font = [UIFont systemFontOfSize:15];
        _detailsLab.textColor = RGB_COLOR(@"#333333", 1);
    }
    return _detailsLab;
}

-(UIButton *)updateBtn{
    if (!_updateBtn) {
        _updateBtn = [[UIButton alloc] init];
        [_updateBtn setImage:[ImageBundle imagewithBundleName:YZMsg(@"YBSetListCell_updateBtnIcon")] forState:UIControlStateNormal];
    }
    return _updateBtn;
}

- (UISwitch *)switchButton {
    if (!_switchButton) {
        _switchButton = [UISwitch new];
        _switchButton.userInteractionEnabled = NO;
    }
    return _switchButton;
}

@end
