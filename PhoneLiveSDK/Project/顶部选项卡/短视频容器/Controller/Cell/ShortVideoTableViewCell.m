//
//  ShortVideoTableViewCell.m
//  phonelive2
//
//  Created by s5346 on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import "ShortVideoTableViewCell.h"
#import "ShortVideoManager.h"

@interface ShortVideoTableViewCell()

@property(nonatomic, strong, nullable) ShortVideoManager *manager;

@end

@implementation ShortVideoTableViewCell

- (instancetype)initWithTabbarHeight:(CGFloat)height style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.tabbarHeight = height;
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)dealloc {
    [self removePlayerManager];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.coverImgView.image = nil;
    [self.manager.player.currentPlayerManager stop];
}

- (void)removePlayerManager {
    [self.controlView removeFromSuperview];
    self.controlView = nil;
    [self.manager.player.currentPlayerManager stop];
    [self.manager reset];
    self.manager = nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)update:(ShortVideoModel*)model isShowCreateTime:(BOOL)isShow {
    self.controlView.showCreateTime = isShow;
    self.controlView.model = model;

//    if (model.isNeedPay) {
//        [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.cover_path]];
//    } else {
//        self.coverImgView.image = nil;
//    }

    self.coverImgView.contentMode = model.meta.isProtrait ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;

//    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.cover_path]];
//    self.coverImgView.contentMode = model.meta.isProtrait ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;
//    WeakSelf
//    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.cover_path] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        STRONGSELF
//        if (image.size.width > image.size.height) {
//            strongSelf.coverImgView.contentMode = UIViewContentModeScaleAspectFit;
//        } else {
//            strongSelf.coverImgView.contentMode = UIViewContentModeScaleAspectFill;
//        }
//    }];
}

- (void)layoutSubviews {
    self.controlView.frame = self.bounds;
}

#pragma mark - UI
- (void)setupViews {
    self.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.coverImgView];
    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.contentView addSubview:self.controlView];
}

#pragma mark - lazy
- (ShortVideoPortraitControlView *)controlView {
    if (!_controlView) {
        _controlView = [[ShortVideoPortraitControlView alloc] initWithTabbarHeight:self.tabbarHeight frame:CGRectZero];
        _controlView.clipsToBounds = YES;
    }
    return _controlView;
}

- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [[UIImageView alloc] init];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFit;
        _coverImgView.userInteractionEnabled = YES;
        _coverImgView.clipsToBounds = YES;
    }
    return _coverImgView;
}

- (ShortVideoManager *)manager {
    if (!_manager) {
        _manager = [[ShortVideoManager alloc] init];
//        _manager.delegate = self;
    }
    return _manager;
}
@end
