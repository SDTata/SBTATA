//
//  VideoTableViewCell.m
//  AAAA
//
//  Created by s5346 on 2024/4/30.
//

#import "VideoTableViewCell.h"

@implementation VideoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.coverImgView.image = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)update:(DramaVideoInfoModel*)model infoModel:(DramaInfoModel*)infoModel {
    self.controlView.model = model;
    self.controlView.infoModel = infoModel;
//    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.over]];
    WeakSelf
    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.over] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        STRONGSELF
        if (image.size.width > image.size.height) {
            strongSelf.coverImgView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            strongSelf.coverImgView.contentMode = UIViewContentModeScaleAspectFill;
        }
    }];
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:self.coverImgView];
    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self.contentView addSubview:self.controlView];
}

#pragma mark - lazy
- (DramaPortraitVideoControlView *)controlView {
    if (!_controlView) {
        _controlView = [[DramaPortraitVideoControlView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }
    return _controlView;
}

- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [[UIImageView alloc] init];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFit;
        _coverImgView.userInteractionEnabled = YES;
    }
    return _coverImgView;
}

@end
