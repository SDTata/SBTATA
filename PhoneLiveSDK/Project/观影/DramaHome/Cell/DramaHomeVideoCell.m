//
//  DramaHomeVideoCell.m
//  DramaTest
//
//  Created by s5346 on 2024/5/3.
//

#import "DramaHomeVideoCell.h"
#import "DramaPlayerManager.h"

@interface DramaHomeVideoCell ()

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *episodeLabel;

@end

@implementation DramaHomeVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setModel:(DramaInfoModel *)model {
    _model = model;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.over]];
    self.nameLabel.text = model.name;

    DramaProgressModel *progressModel = [[DramaProgressModel alloc] initWithProgress:model.p_progress];
    CGFloat percent = (CGFloat)(progressModel.currentTime * 100 / progressModel.totalTime);
    self.episodeLabel.text = [NSString stringWithFormat:@"第%ld集 %d%%", progressModel.episode_number, (int)percent];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageView sd_cancelCurrentImageLoad];
    self.imageView.image = nil;
    self.nameLabel.text = @"";
    self.episodeLabel.text = @"";
}

#pragma mark - UI
- (void)setupViews {
    self.contentView.layer.cornerRadius = 15;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.backgroundColor = [UIColor whiteColor];

    [self.contentView addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    UIView *maskView = [[UIView alloc] init];
    maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.contentView addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@30);
    }];

    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(maskView.mas_top).offset(4);
        make.left.equalTo(self).offset(4);
    }];

    [self.contentView addSubview:self.episodeLabel];
    [self.episodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-8);
        make.bottom.equalTo(self).offset(-4);
    }];
}

#pragma mark - lazy
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:11];
    }
    return _nameLabel;
}

- (UILabel *)episodeLabel {
    if (!_episodeLabel) {
        _episodeLabel = [[UILabel alloc] init];
        _episodeLabel.textColor = [UIColor whiteColor];
        _episodeLabel.font = [UIFont systemFontOfSize:10];
    }
    return _episodeLabel;
}

@end
