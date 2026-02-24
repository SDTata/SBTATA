//
//  SDCollectionViewCell.m
//  SDCycleScrollView
//
//  Created by aier on 15-3-22.
//  Copyright (c) 2015年 GSD. All rights reserved.
//


/*
 
 *********************************************************************************
 *
 * 🌟🌟🌟 新建SDCycleScrollView交流QQ群：185534916 🌟🌟🌟
 *
 * 在您使用此自动轮播库的过程中如果出现bug请及时以以下任意一种方式联系我们，我们会及时修复bug并
 * 帮您解决问题。
 * 新浪微博:GSD_iOS
 * Email : gsdios@126.com
 * GitHub: https://github.com/gsdios
 *
 * 另（我的自动布局库SDAutoLayout）：
 *  一行代码搞定自动布局！支持Cell和Tableview高度自适应，Label和ScrollView内容自适应，致力于
 *  做最简单易用的AutoLayout库。
 * 视频教程：http://www.letv.com/ptv/vplay/24038772.html
 * 用法示例：https://github.com/gsdios/SDAutoLayout/blob/master/README.md
 * GitHub：https://github.com/gsdios/SDAutoLayout
 *********************************************************************************
 
 */


#import "SDCollectionViewCell.h"
#import <Masonry/Masonry.h>

@implementation SDCollectionViewCell
{
    __weak UILabel *_titleLabel;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupImageView];
        [self setupTitleLabel];
    }
    
    return self;
}

- (void)setTitleLabelBackgroundColor:(UIColor *)titleLabelBackgroundColor
{
    _titleLabelBackgroundColor = titleLabelBackgroundColor;
    _titleLabel.backgroundColor = titleLabelBackgroundColor;
}

- (void)setTitleLabelTextColor:(UIColor *)titleLabelTextColor
{
    _titleLabelTextColor = titleLabelTextColor;
    _titleLabel.textColor = titleLabelTextColor;
}

- (void)setTitleLabelTextFont:(UIFont *)titleLabelTextFont
{
    _titleLabelTextFont = titleLabelTextFont;
    _titleLabel.font = titleLabelTextFont;
}

- (void)setupImageView
{
    SDAnimatedImageView *imageView = [[SDAnimatedImageView alloc] init];
    _imageView = imageView;
    [self.contentView addSubview:imageView];
}

- (void)setupTitleLabel
{
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    _titleLabel.hidden = YES;
    _titleLabel.numberOfLines = 2;
    [self.contentView addSubview:titleLabel];
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    switch (self.titleType) {
        case SDCycleScrollViewTitleTypeNormal:
        case SDCycleScrollViewTitleTypeOnly:
            _titleLabel.text = [NSString stringWithFormat:@"   %@", title];
            break;
        case SDCycleScrollViewTitleTypeBottom:
            _titleLabel.text = [NSString stringWithFormat:@"%@", title];
            break;

        default:
            break;
    }

    if (_titleLabel.hidden) {
        _titleLabel.hidden = NO;
    }
}

-(void)setTitleLabelTextAlignment:(NSTextAlignment)titleLabelTextAlignment
{
    _titleLabelTextAlignment = titleLabelTextAlignment;
    _titleLabel.textAlignment = titleLabelTextAlignment;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch (self.titleType) {
        case SDCycleScrollViewTitleTypeNormal:
            _imageView.frame = self.bounds;
            CGFloat titleLabelW = self.sd_width;
            CGFloat titleLabelH = _titleLabelHeight;
            CGFloat titleLabelX = 0;
            CGFloat titleLabelY = self.sd_height - titleLabelH;
            _titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
            break;
        case SDCycleScrollViewTitleTypeOnly:
            _titleLabel.frame = self.bounds;
            break;
        case SDCycleScrollViewTitleTypeBottom:
        {
            [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(AD(5));
                make.top.equalTo(self.contentView).offset(AD(5));
                make.right.equalTo(self.contentView).offset(-AD(5));
                make.height.equalTo(@(self.sd_height - AD(22)));
            }];

            [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_imageView.mas_bottom);
                make.left.right.equalTo(self.contentView);
            }];

            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
            _titleLabel.layer.shadowOffset = CGSizeMake(0, 0);
            _titleLabel.layer.shadowOpacity = 1;
            _titleLabel.layer.shadowRadius = 2;
            _titleLabel.clipsToBounds = NO;
            _titleLabel.layer.shouldRasterize = true;
            _titleLabel.layer.rasterizationScale =  [UIScreen mainScreen].scale;
        }
            break;

        default:
            break;
    }
}

@end
