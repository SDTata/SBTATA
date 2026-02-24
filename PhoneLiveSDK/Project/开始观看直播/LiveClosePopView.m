//
//  LiveClosePopView.m
//  yunbaolive
//
//  Created by lucas on 2021/9/7.
//  Copyright © 2021 cat. All rights reserved.
//

#import "LiveClosePopView.h"
#import "UIView+GYPop.h"
@implementation LiveClosePopView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Setup UI
- (void)setupUI {
    [self addSubview:self.bjView];
    [self.bjView addSubview:self.titleLbl];
    [self.bjView addSubview:self.titleImgV];
    [self.bjView addSubview:self.resultLbl];
    [self.bjView addSubview:self.startBtn];
    [self.bjView addSubview:self.lookBtn];
    [self.bjView addSubview:self.closeBtn];
    
    [self.bjView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
        make.height.mas_equalTo(AD(290));
        make.width.mas_equalTo(AD(270));
    }];
    
    [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bjView).offset(AD(20));
        make.left.equalTo(self.bjView).offset(AD(24));
        make.size.mas_equalTo(CGSizeMake(AD(78), AD(26)));
    }];
    
    [self.titleImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bjView).offset(AD(30));
        make.centerX.equalTo(self.bjView);
        make.size.mas_equalTo(CGSizeMake(AD(64), AD(64)));
    }];
    
    [self.resultLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleImgV.mas_bottom).offset(AD(25));
        make.left.equalTo(self.bjView).offset(AD(15));
        make.right.equalTo(self.bjView).offset(AD(-15));
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.resultLbl.mas_bottom).offset(AD(20));
        make.centerX.equalTo(self.bjView);
        make.height.mas_equalTo(AD(36.f));
        make.width.mas_equalTo(AD(200));
    }];
    
    [self.lookBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bjView);
        make.top.equalTo(self.startBtn.mas_bottom).offset(AD(20));
        make.size.width.equalTo(self.startBtn);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bjView).offset(AD(10));
        make.right.equalTo(self.bjView).offset(AD(-10));
        make.size.mas_equalTo(CGSizeMake(AD(30), AD(30)));
    }];
    
}

-(void)bindPhone{
    if (self.lookBtnClickBlock) {
        self.lookBtnClickBlock();
    }
}

-(void)close{
    [self gy_popViewdismiss];
}

-(void)setPass{
    if (self.startBtnClickBlock) {
        self.startBtnClickBlock();
    }
}

#pragma mark - Lazy Init
-(UIImageView *)bjView{
    if (!_bjView) {
        _bjView = [[UIImageView alloc] init];
        _bjView.image = [ImageBundle imagewithBundleName:@"gztc1"];
        _bjView.userInteractionEnabled = YES;
    }
    return _bjView;
}


-(UIImageView *)titleImgV{
    if (!_titleImgV) {
        _titleImgV = [[UIImageView alloc] init];
        _titleImgV.backgroundColor = RGB_COLOR(@"#C1C1C1", 1);
        _titleImgV.layer.cornerRadius = AD(32);
        _titleImgV.layer.masksToBounds = YES;
    }
    return _titleImgV;
}

- (UILabel *)titleLbl {
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.text = YZMsg(@"liveclosepopview_hint");
        _titleLbl.textColor = RGB_COLOR(@"#D66395", 1);
        _titleLbl.backgroundColor =RGB_COLOR(@"#F0E0E6", 1);
        _titleLbl.font = [UIFont boldSystemFontOfSize:12];
        _titleLbl.textAlignment = NSTextAlignmentCenter;
        _titleLbl.layer.cornerRadius = AD(13);
        _titleLbl.layer.masksToBounds = YES;
        _titleLbl.adjustsFontSizeToFitWidth = YES;
        _titleLbl.minimumScaleFactor = 0.4;
    }
    return _titleLbl;
}

- (UILabel *)resultLbl {
    if (!_resultLbl) {
        _resultLbl = [[UILabel alloc] init];
        _resultLbl.text = YZMsg(@"liveclosepopview_title");
        _resultLbl.textColor = [UIColor blackColor];
        _resultLbl.font = [UIFont boldSystemFontOfSize:16];
        _resultLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _resultLbl;
}

- (UIButton *)startBtn {
    if (!_startBtn) {
        _startBtn = [[UIButton alloc] init];
        _startBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_startBtn setTitle:YZMsg(@"liveclosepopview_follow_exit") forState:UIControlStateNormal];
        [_startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _startBtn.layer.cornerRadius = AD(18);
        _startBtn.layer.masksToBounds = YES;
        [_startBtn setBackgroundImage:[ImageBundle imagewithBundleName:@"gztc_11"] forState:UIControlStateNormal];
        [_startBtn addTarget:self action:@selector(setPass) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startBtn;
}

- (UIButton *)lookBtn {
    if (!_lookBtn) {
        _lookBtn = [[UIButton alloc] init];
        _lookBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_lookBtn setTitle:YZMsg(@"liveclosepopview_leave") forState:UIControlStateNormal];
        [_lookBtn setTitleColor:RGB_COLOR(@"#D66395", 1) forState:UIControlStateNormal];
        [_lookBtn addTarget:self action:@selector(bindPhone) forControlEvents:UIControlEventTouchUpInside];
        _lookBtn.layer.borderColor = RGB_COLOR(@"#D66395", 1).CGColor;
        _lookBtn.layer.borderWidth = 1;
        _lookBtn.layer.cornerRadius = AD(18);
        _lookBtn.layer.masksToBounds = YES;
    }
    return _lookBtn;
}

-(UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setImage:[ImageBundle imagewithBundleName:@"gztc_03"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}


@end
