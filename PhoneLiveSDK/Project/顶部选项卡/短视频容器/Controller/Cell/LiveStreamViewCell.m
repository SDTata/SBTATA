//
//  LiveStreamViewCell.m
//  phonelive2
//
//  Created by s5346 on 2024/7/19.
//  Copyright © 2024 toby. All rights reserved.
//

#import "LiveStreamViewCell.h"
#import "RandomRule.h"
#import "LiveGifImage.h"
@interface LiveStreamViewCell ()<NodePlayerDelegate>

@property (nonatomic, strong) UIImageView *coverImgView;
@property(nonatomic, strong) NodePlayer *nplayer;
@property(nonatomic, strong) hotModel *model;
@property(nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) UIView *enterRoom;
// bottom
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *tagView;

@property(nonatomic, assign) BOOL isPlay;
@property(nonatomic, assign) int volume;

@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, assign) NSInteger remainingSeconds;
@property(nonatomic, assign) BOOL isEnterRoom;
@end

@implementation LiveStreamViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isEnterRoom = NO;
        [self setupViews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)mute {
    if (self.isEnterRoom) {
        return;
    }
    self.volume = 0;
    self.nplayer.volume = self.volume;
    [self startCountdown];
}

- (void)pause:(BOOL)isPause {
    self.isPlay = !isPause;
    [self.nplayer pause:isPause];
}

- (void)stop {
    [self.nplayer stop];
}

- (void)update:(hotModel*)model {
    self.isPlay = YES;
    self.volume = 0;
    self.model = model;
    self.nameLabel.text = model.zhuboName;
    self.contentLabel.text = model.title;
    [self updateCover:model.zhuboImage];
    self.nplayer.nodePlayerDelegate = self;

    [self checkIfEncryption];

    NSString * url = [minstr(self.model.pull) stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = true;
    [self.nplayer start:url];
    [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = false;
}

- (void)play {
    [self cancelCountdown];
    self.isPlay = YES;
    self.volume = 1;
    self.nplayer.volume = self.volume;
    if ([self.nplayer isPause]) {
        [self.nplayer pause:NO];
    }
    self.isEnterRoom = NO;
}

- (void)updateCover:(NSString*)cover_path {
    WeakSelf
    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:cover_path] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        if (image.size.width > image.size.height) {
            strongSelf.coverImgView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            strongSelf.coverImgView.contentMode = UIViewContentModeScaleAspectFill;
        }
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.coverImgView.image = nil;
    [self.nplayer stop];
}

- (void)setupNPlayer:(NodePlayer*)tempPlayer {
    self.nplayer = tempPlayer;
    self.nplayer.nodePlayerDelegate = self;
    [self.nplayer attachView:self.videoView];
    // TODO: bill 先留著，因進入個人首頁再進入直播，nplayer 會再被處理過，導致回來沒有畫面，這邊再做一次 start
    NSString * url = [minstr(self.model.pull) stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = true;
    [self.nplayer start:url];
    [YBToolClass sharedInstance].shouldUseHookedMethodForTimer = false;
}

- (void)removePlayer {
    if (self.isEnterRoom) {
        return;
    }
    [self.nplayer stop];
    [self.nplayer detachView];
    self.nplayer = nil;
}

#pragma mark - UI
- (void)setupViews {
    self.contentView.backgroundColor = [UIColor blackColor];

    [self.contentView addSubview:self.coverImgView];
    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    [self.contentView addSubview:self.enterRoom];
    [self.enterRoom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.left.greaterThanOrEqualTo(self.contentView).offset(50);
        make.right.lessThanOrEqualTo(self.contentView).offset(-50);
        make.bottom.equalTo(self.contentView).offset(-200);
        make.height.mas_equalTo(40);
    }];

    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentLeading;
    stackView.spacing = 10;
    [self.contentView addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView).inset(10);
    }];

    [stackView addArrangedSubview:self.tagView];
    [stackView addArrangedSubview:self.nameLabel];
    [stackView addArrangedSubview:self.contentLabel];
}

#pragma mark - Action
- (void)tapEnterRoom {
    if ([self.delegate respondsToSelector:@selector(liveStreamViewCellDelegateForTapLiveStream:nplayer:cell:)]) {
        self.isEnterRoom = YES;
        [self.delegate liveStreamViewCellDelegateForTapLiveStream:self.model nplayer:self.nplayer cell:self];
    }
}

#pragma mark - Data
-(void)checkIfEncryption {
    if (self.model == nil) {
        return;
    }
    NSString *zhubID = self.model.zhuboID;
    if (self.model.encryption) {
        NSString *randomEnCodeStr = [[YBToolClass sharedInstance].dicForKeyPlay objectForKey:minnum(zhubID)];
        if([YBToolClass sharedInstance].dicForKeyPlay== nil ||[PublicObj checkNull:randomEnCodeStr]){
            randomEnCodeStr = [[RandomRule randomWithColumn:4 Line:4 seeds:[zhubID integerValue] others:nil] substringToIndex:16];
            if([YBToolClass sharedInstance].dicForKeyPlay== nil ){
                [YBToolClass sharedInstance].dicForKeyPlay = [NSMutableDictionary dictionary];
            }

            [[YBToolClass sharedInstance].dicForKeyPlay setObject:minnum(zhubID) forKey:randomEnCodeStr];
        }
        [self.nplayer setCryptoKey:randomEnCodeStr];
    }else{
        [self.nplayer setCryptoKey:@""];
    }
}

#pragma mark - Lazy
- (NodePlayer *)nplayer {
    if (!_nplayer) {
        _nplayer  = [[NodePlayer alloc] initWithLicense:YBToolClass.decrypt_sdk_key];
        [_nplayer attachView:self.videoView];
        [_nplayer setBufferTime:400];
        [_nplayer setHWAccelEnable:false];
        [_nplayer setScaleMode:2];
        [_nplayer setLogLevel:0];
        _nplayer.scaleMode = 2;
        _nplayer.RTSPTransport = RTSP_TRANSPORT_TCP;
        _nplayer.volume = 0;
        _nplayer.nodePlayerDelegate = self;
    }
    return _nplayer;
}

- (UIView *)videoView {
    if (!_videoView) {
        _videoView = [[UIView alloc] init];
        [self.contentView insertSubview:_videoView belowSubview:self.enterRoom];
        [_videoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return _videoView;
}

- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [[UIImageView alloc] init];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFit;
        _coverImgView.userInteractionEnabled = YES;
    }
    return _coverImgView;
}

- (UIView *)enterRoom {
    if (!_enterRoom) {
        UIView *control = [[UIView alloc] init];
        control.userInteractionEnabled = YES;
        control.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        control.layer.cornerRadius = 20;
        control.layer.masksToBounds = YES;
        control.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        control.layer.borderWidth = 0.5;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEnterRoom)];
        [control addGestureRecognizer:tap];

        NSString *gifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:@"living_animation" ofType:@"gif"];
        YYAnimatedImageView *gifImg = [[YYAnimatedImageView alloc]init];
        LiveGifImage *imgAnima = (LiveGifImage*)[LiveGifImage imageWithData:[NSData dataWithContentsOfFile:gifPath]];
        [imgAnima setAnimatedImageLoopCount:0];
        gifImg.image = imgAnima;
        gifImg.runloopMode = NSRunLoopCommonModes;
        gifImg.animationRepeatCount = 0;
        [gifImg startAnimating];
        [control addSubview:gifImg];
        [gifImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(control).offset(15);
            make.centerY.equalTo(control);
            make.height.mas_equalTo(10);
            make.width.mas_equalTo(18);
        }];

        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor whiteColor];
        label.minimumScaleFactor = 0.5;
        label.adjustsFontSizeToFitWidth = YES;
        label.text = YZMsg(@"Tap to live stream room");
        label.layer.shadowOpacity = 0.5;
        label.layer.shadowColor = [UIColor blackColor].CGColor;
        label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
        [control addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(control);
            make.left.equalTo(gifImg.mas_right).offset(4);
            make.right.equalTo(control).offset(-15);
        }];

        _enterRoom = control;
    }
    return _enterRoom;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:14];
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
        _contentLabel.font = [UIFont systemFontOfSize:13];
        _contentLabel.textColor = UIColor.whiteColor;
        _contentLabel.numberOfLines = 0;
        _contentLabel.layer.shadowOpacity = 0.5;
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
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor whiteColor];
        [_tagView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_tagView).inset(2);
            make.left.right.equalTo(_tagView).inset(4);
        }];

    }
    return _tagView;
}

#pragma mark - NodePlayerDelegate
- (void)onEventCallback:(id)sender event:(int)event msg:(NSString *)msg {
    if (event == 1102) {
        [self.nplayer pause:!self.isPlay];
        self.nplayer.volume = self.volume;
        if (!self.isPlay) {
            [self startCountdown];
        }
    }
}

#pragma mark - 倒數計時
- (void)startCountdown {
    [self cancelCountdown];
    self.remainingSeconds = 15;
    self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(updateCountdown)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void)updateCountdown {
    if (self.remainingSeconds > 0) {
//        NSLog(@"剩餘時間: %ld 秒", (long)self.remainingSeconds);
        self.remainingSeconds--;
    } else {
        [self pause:YES];
        [self cancelCountdown];
    }
}

- (void)cancelCountdown {
    [self.countdownTimer invalidate];
    self.countdownTimer = nil;
}

@end
