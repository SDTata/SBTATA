//
//  SearchResultLiveStreamCell.m
//  phonelive2
//
//  Created by user on 2024/9/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SearchResultLiveStreamCell.h"
#import "hotModel.h"
#import "LiveGifImage.h"
@interface SearchResultLiveStreamCell ()
@property (nonatomic, strong) UIImageView *coverImgView;
@property(nonatomic, strong) hotModel *model;
@property(nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) UIView *enterRoom;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *tagView;
@property (nonatomic, strong) UIView *gifImgAndLiveTag;
@property (nonatomic, strong) UIImageView *hotIcon;
@property (nonatomic, strong) UILabel *numbersLabel;
@property (nonatomic, strong) UIView *gradientView;
@end

@implementation SearchResultLiveStreamCell
- (void)layoutSubviews {
    [super layoutSubviews];

    self.gradientView.verticalColors = @[RGB_COLOR(@"#000000", 0.0), RGB_COLOR(@"#000000", 0.2)];
}

- (void)updateView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 16;
    self.contentView.layer.masksToBounds = YES;
    
    [self.contentView addSubview:self.coverImgView];
    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];

    UIView *gradientView = [[UIView alloc] init];
    gradientView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:gradientView];
    [gradientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.height.equalTo(@(RatioBaseWidth390(48)));
    }];
    self.gradientView = gradientView;

    [self.contentView addSubview:self.gifImgAndLiveTag];
    [self.contentView addSubview:self.hotIcon];
    [self.contentView addSubview:self.numbersLabel];
    [self.numbersLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView).inset(6);
        make.right.mas_equalTo(self.contentView).inset(12);
        make.height.mas_equalTo(14);
    }];
    [self.hotIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView).inset(6);
        make.right.mas_equalTo(self.numbersLabel.mas_left).inset(4);
        make.size.mas_equalTo(14);
    }];
    
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentLeading;
    stackView.spacing = 3;
    [self.contentView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(10);
        make.bottom.mas_equalTo(self.contentView).inset(4);
        make.right.mas_equalTo(self.hotIcon.mas_left).inset(4);
    }];
    [stackView addArrangedSubview:self.nameLabel];
    [stackView addArrangedSubview:self.contentLabel];
    
    [self.gifImgAndLiveTag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(4);
        make.bottom.mas_equalTo(stackView.mas_top).inset(4);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(self.contentView);
    }];
}

- (void)updateData {
    hotModel* model = self.itemModel;
    self.nameLabel.text = model.zhuboName;
    self.contentLabel.text = model.title;
    self.numbersLabel.text = model.nums ?  model.nums : @"0";
    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.zhuboImage]];
}

- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [[UIImageView alloc] init];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImgView.userInteractionEnabled = YES;
    }
    return _coverImgView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:12];
        _nameLabel.textColor = UIColor.whiteColor;
        _nameLabel.numberOfLines = 0;
        _nameLabel.layer.shadowOpacity = 0.5;
        _nameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _nameLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    }
    return _nameLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:11];
        _contentLabel.textColor = vkColorRGBA(1, 1, 1, 0.3);
        _contentLabel.numberOfLines = 0;
        _contentLabel.layer.shadowOpacity = 0.1;
        _contentLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _contentLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    }
    return _contentLabel;
}

- (UIView *)tagView {
    if (!_tagView) {
        _tagView = [[UIView alloc] init];
        _tagView.layer.cornerRadius = 3;
        _tagView.layer.masksToBounds = YES;
        _tagView.backgroundColor = RGB_COLOR(@"#F251BB", 1);

        UILabel *label = [[UILabel alloc] init];
        label.text = YZMsg(@"Live Streaming");
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor whiteColor];
        [_tagView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_tagView).inset(2);
            make.left.right.equalTo(_tagView).inset(4);
        }];

    }
    return _tagView;
}

- (UIView *)gifImgAndLiveTag {
    if (!_gifImgAndLiveTag) {
        UIView *control = [[UIView alloc] init];

        NSString *gifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:@"living_animation" ofType:@"gif"];
        YYAnimatedImageView *gifImg = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 18)];
        LiveGifImage *imgAnima = (LiveGifImage*)[LiveGifImage imageWithData:[NSData dataWithContentsOfFile:gifPath]];
        [imgAnima setAnimatedImageLoopCount:0];
        gifImg.image = imgAnima;
        gifImg.runloopMode = NSRunLoopCommonModes;
        gifImg.animationRepeatCount = 0;
        [gifImg startAnimating];
        [control addSubview:gifImg];
        [gifImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(control).offset(10);
            make.centerY.equalTo(control);
            make.height.mas_equalTo(10);
            make.width.mas_equalTo(18);
        }];
        
        UIView *tagView = [[UIView alloc] init];
        tagView.layer.cornerRadius = 5;
        tagView.layer.masksToBounds = YES;
        tagView.backgroundColor = RGB_COLOR(@"#F251BB", 1);

        UILabel *label = [[UILabel alloc] init];
        label.text = YZMsg(@"Live Streaming");
        label.font = [UIFont systemFontOfSize:10];
        label.textColor = [UIColor whiteColor];
        [tagView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_tagView).inset(2);
            make.left.right.equalTo(_tagView).inset(4);
        }];
        [control addSubview:tagView];
        [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(gifImg.mas_right).offset(5);
            make.centerY.equalTo(gifImg);
            make.height.mas_equalTo(20);
        }];
        _gifImgAndLiveTag = control;
    }
    return _gifImgAndLiveTag;
}

- (UIImageView *)hotIcon {
    if (!_hotIcon) {
        UIImageView *hotIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        hotIcon.contentMode = UIViewContentModeScaleAspectFit;
        hotIcon.image = [ImageBundle imagewithBundleName:@"HomeLongVideoFireIcon"];
        _hotIcon = hotIcon;
    }
    return _hotIcon;
}

- (UILabel *)numbersLabel {
    if (!_numbersLabel) {
        _numbersLabel = [[UILabel alloc] init];
        _numbersLabel.text = @"0";
        [_numbersLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        _numbersLabel.font = [UIFont systemFontOfSize:10];
        _numbersLabel.textColor = UIColor.whiteColor;
        _numbersLabel.numberOfLines = 0;
        _numbersLabel.layer.shadowOpacity = 0.5;
        _numbersLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        _numbersLabel.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    }
    return _numbersLabel;
}
@end
