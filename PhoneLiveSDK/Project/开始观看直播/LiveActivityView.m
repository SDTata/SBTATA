//
//  LiveActivityView.m
//  yunbaolive
//
//  Created by Mac on 2020/7/22.
//  Copyright © 2020 cat. All rights reserved.
//

#import "LiveActivityView.h"
#import "UIImageView+WebCache.h"
#define CP  _window_width/375.0f
@interface LiveActivityButton (){
    UIImage *_normalImage;
    UIImage *_selectImage;
    NSString *_normalTitle;
    NSString *_selectTitle;
    UIColor *_normalColor;
    UIColor *_selectColor;
    BOOL _isSelect;
    BOOL _hasText;
}
@property(nonatomic, strong) UIButton *clickBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconImgV;

@property (nonatomic, strong) ActivityClickBlock activityActionBlock;

@end

@implementation LiveActivityButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.iconImgV];
        [self addSubview:self.clickBtn];
        [self addSubview:self.titleLabel];
        [self.clickBtn addTarget:self action:@selector(clickBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        self.alpha = 1;
        _hasText = NO;
        [self selected:NO];
//        self.hidden = YES;
    }
    return self;
}

- (void)selected:(BOOL)selected{
    _isSelect = selected;
    if (_isSelect && _selectImage) {
        self.iconImgV.image = _selectImage;
        self.titleLabel.text = _selectTitle;
        self.titleLabel.textColor = _selectColor;
    }else{
        self.iconImgV.image = _normalImage;
        self.titleLabel.text = _normalTitle;
        self.titleLabel.textColor = _normalColor;
    }
}
- (void)setTitle:(NSString *)title forState:(UIControlState)state{
    if ([PublicObj checkNull:title]) {
        return;
    }
    _hasText = YES;
    self.titleLabel.hidden = NO;
    _iconImgV.frame = CGRectMake(AD(5), AD(5), self.width - AD(10), self.height - AD(22));
    self.titleLabel.frame = CGRectMake(0, self.height - AD(17), self.width, AD(12));
    switch (state) {
        case UIControlStateNormal:
            _normalTitle = title;
            break;
        case UIControlStateSelected:
            _selectTitle = title;
            break;
        default:
            break;
    }
    if (_normalTitle) {
        if (_isSelect && _selectTitle) {
            self.titleLabel.text = minstr(_selectTitle);
        }else{
            self.titleLabel.text = minstr(_normalTitle);
        }
    }else{
        if (_selectTitle && _isSelect) {
            self.titleLabel.text = minstr(_selectTitle);
        }
    }
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.3;
}
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state{
    _hasText = YES;
    self.titleLabel.hidden = NO;
    _iconImgV.frame = CGRectMake(AD(5), AD(5), self.width - AD(10), self.height - AD(22));
    self.titleLabel.frame = CGRectMake(0, self.height - AD(17), self.width, AD(12));
    switch (state) {
        case UIControlStateNormal:
            _normalColor = color;
            break;
        case UIControlStateSelected:
            _selectColor = color;
            break;
        default:
            break;
    }
    if (_normalColor) {
        if (_isSelect && _selectColor) {
            self.titleLabel.textColor = _selectColor;
        }else{
            self.titleLabel.textColor = _normalColor;
        }
    }else{
        if (_selectColor && _isSelect) {
            self.titleLabel.textColor = _selectColor;
        }
    }
}
- (void)setButtonImageWithUrl:(NSString *)imageUrl forState:(UIControlState)state{

    
    if ([PublicObj checkNull:imageUrl]) {
        return;
    }
    NSURL *imgUrl = [NSURL URLWithString:imageUrl];
    if (imgUrl == nil) {
        return;
    }
    WeakSelf
    [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf setButtonImage:image forState:state fromNetwork:YES];
    }];
}
- (void)setButtonImageWithUrl:(NSString *)imageUrl placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state {
    if ([PublicObj checkNull:imageUrl]) {
        return;
    }
    NSURL *imgUrl = [NSURL URLWithString:imageUrl];
    if (imgUrl == nil) {
        return;
    }
    WeakSelf
    [self.iconImgV sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:placeholderImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [strongSelf setButtonImage:image forState:state fromNetwork:YES];
    }];
}
- (void)setButtonImage:(UIImage *)image forState:(UIControlState)state {
    [self setButtonImage:image forState:state fromNetwork:NO];
}
- (void)setButtonImage:(UIImage *)image forState:(UIControlState)state fromNetwork:(BOOL)isFromNetwork {
    switch (state) {
        case UIControlStateNormal:
            _normalImage = image;
            if (isFromNetwork) {
                self.iconImgV.image = _normalImage;
                return;
            }
            break;
        case UIControlStateSelected:
            _selectImage = image;
            if (isFromNetwork) {
                self.iconImgV.image = _selectImage;
                return;
            }
            break;
        default:
            break;
    }
    if (_normalImage) {
        if (_isSelect && _selectImage) {
            self.iconImgV.image = _selectImage;
        }else{
            self.iconImgV.image = _normalImage;
        }
    }else{
        if (_selectImage && _isSelect) {
            self.iconImgV.image = _selectImage;
        }
    }
}

- (void)setTargetClick:(ActivityClickBlock)activityActionBlock{
    if (activityActionBlock) {
        self.activityActionBlock = activityActionBlock;
    }
}
- (void)clickBtnAction:(UIButton *)btn {
    if (self.activityActionBlock) {
        if (self.tagString) {
            self.activityActionBlock(self.tagString,self);
        }else{
            self.activityActionBlock(@"",self);
        }
    }
}

#pragma mark - lazy load
- (UIImageView *)iconImgV {
    if (!_iconImgV) {
        _iconImgV = [[UIImageView alloc] initWithFrame:CGRectMake(AD(5), AD(11), self.width - AD(10), self.height - AD(22))];
        _iconImgV.contentMode = UIViewContentModeScaleAspectFit;
        _iconImgV.clipsToBounds = YES;
    }
    return _iconImgV;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.height - AD(12), self.width, AD(12))];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        _titleLabel.textColor = [UIColor whiteColor];
//        _titleLabel.strokeColor = [UIColor blackColor];
//        _titleLabel.strokeWidth = 0.5;
        _titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _titleLabel.layer.shadowOffset = CGSizeMake(0, 0);
        _titleLabel.layer.shadowOpacity = 1;
        _titleLabel.layer.shadowRadius = 2;
        _titleLabel.clipsToBounds = NO;
        _titleLabel.layer.shouldRasterize = true;
        _titleLabel.layer.rasterizationScale =  [UIScreen mainScreen].scale;

        _titleLabel.hidden = YES;
    }
    return _titleLabel;
}

- (UIButton *)clickBtn {
    if (!_clickBtn) {
        _clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _clickBtn.frame = self.bounds;
        _clickBtn.backgroundColor = [UIColor clearColor];
    }
    return _clickBtn;
}

- (BOOL)isSelected {
    return _isSelect;
}

- (NSString*)getTitle {
    return _normalTitle;
}

- (CGRect)getIconFrame {
    return _iconImgV.frame;
}

- (UIImage*)getSelectImage {
    return _selectImage;
}


@end
