//
//  withdrawPopView.m
//  phonelive2
//
//  Created by lucas on 2021/4/20.
//  Copyright © 2021 toby. All rights reserved.
//

#import "withdrawPopView.h"
@interface withdrawPopView (){

}

@end

@implementation withdrawPopView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

-(void)cancelAction:(UIButton *)btn{
    [self gy_popViewdismiss];
    if (self.cancelBtnClickBlock) {
        self.cancelBtnClickBlock(btn);
    }
}

-(void)submitAction:(UIButton *)btn{
    if (self.submitBtnClickBlock) {
        self.submitBtnClickBlock(btn);
    }
}


#pragma mark - Setup UI
- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];

    [self addSubview:self.titleLbl];
    [self addSubview:self.billingLab];
    [self addSubview:self.cancelBtn];
    [self addSubview:self.submitBtn];
    
    [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(21);
    }];
    [self.billingLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLbl.mas_bottom).offset(29.f);
        make.left.equalTo(self).offset(22.f);
        make.right.equalTo(self).offset(-22.f);
    }];
    
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor =RGB_COLOR(@"#666666", 0.3);
    [self addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(22);
        make.right.equalTo(self).offset(-22);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(self.billingLab.mas_bottom).offset(20.f);
    }];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).multipliedBy(0.5);
        make.bottom.equalTo(self).offset(-16);
        make.height.mas_equalTo(44.f);
        make.width.mas_equalTo(112);
    }];
    
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).multipliedBy(1.5);
        make.bottom.equalTo(self.cancelBtn);
        make.height.width.equalTo(self.cancelBtn);
    }];
    
}

#pragma mark - Lazy Init
- (UILabel *)titleLbl {
    if (!_titleLbl) {
        _titleLbl= [[UILabel alloc] init];
        _titleLbl.text = YZMsg(@"withdrawPopView_tip");
        _titleLbl.textColor = RGB_COLOR(@"#666666", 1);
        _titleLbl.font = [UIFont systemFontOfSize:18];
    }
    return _titleLbl;
}

- (UILabel *)billingLab {
    if (!_billingLab) {
        _billingLab = [[UILabel alloc] init];
        _billingLab.text = YZMsg(@"withdrawPopView_Error_tip_BindPhone");
        _billingLab.textColor = RGB_COLOR(@"#333333", 1);
        _billingLab.font = [UIFont systemFontOfSize:15];
        _billingLab.textAlignment = NSTextAlignmentCenter;
    }
    return _billingLab;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_cancelBtn setTitle:YZMsg(@"public_cancel") forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:RGB_COLOR(@"#000000", 1) forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.layer.borderColor = RGB_COLOR(@"#E3E3E3", 1).CGColor;
        _cancelBtn.layer.borderWidth = 0.5;
        _cancelBtn.layer.cornerRadius = 22;
        _cancelBtn.layer.masksToBounds = YES;
    }
    return _cancelBtn;
}

- (UIButton *)submitBtn {
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc] init];
        _submitBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_submitBtn setTitle:YZMsg(@"publictool_sure") forState:UIControlStateNormal];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_submitBtn addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
        _submitBtn.backgroundColor = RGB_COLOR(@"#FF34CD", 1);
        _submitBtn.layer.cornerRadius = 22;
        _submitBtn.layer.masksToBounds = YES;
    }
    return _submitBtn;
}



@end
