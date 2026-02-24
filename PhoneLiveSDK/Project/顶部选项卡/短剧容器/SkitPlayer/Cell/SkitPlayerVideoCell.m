//
//  SkitPlayerVideoCell.m
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitPlayerVideoCell.h"
#import "SkitPlayerManager.h"

@interface SkitPlayerVideoCell ()

@property(nonatomic, strong, nullable) SkitPlayerManager *manager;

@end

@implementation SkitPlayerVideoCell

+ (CGFloat)itemHeight {
    return VK_SCREEN_H;
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
//    [self.controlView removeFromSuperview];
//    self.controlView = nil;
    self.coverImgView.image = nil;
    [self.manager.player.currentPlayerManager stop];
//    [self.manager reset];
//    self.manager = nil;
}

- (void)removePlayerManager {
    [self.controlView removeFromSuperview];
    self.controlView = nil;
    [self.manager.player.currentPlayerManager stop];
    [self.manager reset];
    self.manager = nil;
}

- (void)update:(SkitVideoInfoModel*)model infoModel:(HomeRecommendSkit*)infoModel {
    self.controlView.model = model;
    self.controlView.infoModel = infoModel;
    if (model.isNeedPay) {
        WeakSelf
        [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.cover_path] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            if (error != nil) {
                [strongSelf.coverImgView sd_setImageWithURL:[NSURL URLWithString:infoModel.cover_path]];
            }
        }];
    } else {
        self.coverImgView.image = nil;
    }

    self.coverImgView.contentMode = model.meta.isProtrait ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;

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
    self.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:self.coverImgView];
    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    [self.contentView addSubview:self.controlView];
}

#pragma mark - lazy
- (SkitPlayerVideoPortraitControlView *)controlView {
    if (!_controlView) {
        _controlView = [[SkitPlayerVideoPortraitControlView alloc] initWithFrame:UIScreen.mainScreen.bounds];
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
        _coverImgView.tag = 11111111;
    }
    return _coverImgView;
}

- (SkitPlayerManager *)manager {
    if (!_manager) {
        _manager = [[SkitPlayerManager alloc] init];
    }
    return _manager;
}

@end
