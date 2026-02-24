//
//  HotCollectionViewCell.m
//  yunbaolive
//
//  Created by Boom on 2018/9/21.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "HotCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIView+Shake.h"

#import "LiveGifImage.h"


@interface HotCollectionViewCell()
{
    BOOL isWobble;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_imgWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_lbWidthConstaint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *regionleftConstaint;

@property (weak, nonatomic) IBOutlet UIView *showGameView;

@property (weak, nonatomic) IBOutlet YYAnimatedImageView *livinggifImgV;
@property (nonatomic, strong) LiveGifImage *hotGiftAnimation;
@property (nonatomic, strong) LiveGifImage *vibratorGiftAnimation;


@end
@implementation HotCollectionViewCell

+(CGFloat)ratio {
    return 8 / 7.0;
}

+(CGFloat)minimumLineSpacing {
    return 10.0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    
    NSString *vibratorGifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:@"bluesdeviceicon" ofType:@"gif"];
    
    self.vibratorGiftAnimation =  (LiveGifImage *)[LiveGifImage imageWithData:[NSData dataWithContentsOfFile:vibratorGifPath]];
    [self.vibratorGiftAnimation setAnimatedImageLoopCount:0];
//    self.vibratorGiftAnimation.loopCount = 0;

    NSString *gifPath = [[XBundle currentXibBundleWithResourceName:@""] pathForResource:@"living_animation" ofType:@"gif"];
    self.hotGiftAnimation =  (LiveGifImage *)[LiveGifImage  imageWithData:[NSData dataWithContentsOfFile:gifPath]];

    _livinggifImgV.runloopMode = NSRunLoopCommonModes;
    [_hotGiftAnimation setAnimatedImageLoopCount:0];
    
 
    // 设置灰色半透明背景
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(_livinggifImgV.x-5,_livinggifImgV.y-5 , _livinggifImgV.width+10, _livinggifImgV.height+10)];
    backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1]; // 灰色半透明
    backgroundView.layer.cornerRadius = 11; // 圆角半径
    backgroundView.layer.masksToBounds = YES; // 裁剪超出圆角部分
    backgroundView.tag = 1101010;

    [_livinggifImgV.superview addSubview:backgroundView];
    [_livinggifImgV.superview addSubview:_livinggifImgV];

    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_livinggifImgV.mas_centerX);
        make.centerY.equalTo(_livinggifImgV.mas_centerY);
        make.width.equalTo(_livinggifImgV.mas_width).offset(5);
        make.height.equalTo(_livinggifImgV.mas_width).offset(5);
    }];
   
    
}

#define RADIANS(degrees) (((degrees) * M_PI) / 180.0)
- (void)startWobble {
    if(isWobble){
        return;
    }
    if (_btn_redBag!= nil) {
        isWobble = true;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startWobble) object:nil];
    WeakSelf
    [_btn_redBag shakeWithOptions:SCShakeOptionsDirectionRotate | SCShakeOptionsForceInterpolationLinearDown | SCShakeOptionsAtEndComplete force:0.15 duration:0.55 iterationDuration:0.05 completionHandler:^{
        STRONGSELF
        if (strongSelf==nil) {
            return;
        }
        if(strongSelf->isWobble){
            [strongSelf performSelector:@selector(startWobble) withObject:nil afterDelay:1.0f];
            strongSelf->isWobble = false;
        }
    }];
    
}

- (void)stopWobble {
    isWobble = false;
    [_btn_redBag endShake];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startWobble) object:nil];
    
}

- (void)setModel:(hotModel *)model{
    _model = model;
    if (![PublicObj checkNull:_model.zhuboImage]) {
        [_thumbImageView sd_setImageWithURL:[NSURL URLWithString:_model.zhuboImage] placeholderImage:[ImageBundle imagewithBundleName:@"image_placehold"]];
    }else{
        [_thumbImageView sd_setImageWithURL:[NSURL URLWithString:_model.avatar_thumb] placeholderImage:[ImageBundle imagewithBundleName:@"image_placehold"]];
    }
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_model.zhuboIcon]];
    _nameLabel.text = _model.zhuboName;
    if (_isNear) {
        _numImgView.image = [ImageBundle imagewithBundleName:@"live_distence"];
        _numsLabel.text = _model.distance;
    }else{
//        NSLog([NSString stringWithFormat:@"_model.onlineCount = [%@]", _model.onlineCount]);
        _numsLabel.text = [YBToolClass formatLikeNumber:_model.onlineCount];
        _numImgView.image = [ImageBundle imagewithBundleName:@"img_huo"];
    }
    _titleLabel.text = _model.title;
    if (_model.title.length > 0) {
        if (_jianju1.constant == 5) {
            _jianju1.constant += 5;
            _jianju2.constant += 5;

        }
    }else{
        if (_jianju1.constant == 10) {
            _jianju1.constant -= 5;
            _jianju2.constant -= 5;
            
        }
    }
    int type = [_model.type intValue];
    _liveTypeImageView.hidden = NO;
    switch (type) {
        case 0:
            [_liveTypeImageView setImage:[ImageBundle imagewithBundleName:YZMsg(@"HotCollectionViewCell_Nomal_Room")]];
            _liveTypeImageView.hidden = YES;
            break;
        case 1:
            [_liveTypeImageView setImage:[ImageBundle imagewithBundleName:YZMsg(@"HotCollectionViewCell_PWD_Room")]];
            break;
        case 2:
            [_liveTypeImageView setImage:[ImageBundle imagewithBundleName:YZMsg(@"HotCollectionViewCell_Pay_Room")]];
            break;
        case 3:
            [_liveTypeImageView setImage:[ImageBundle imagewithBundleName:YZMsg(@"HotCollectionViewCell_Time_Room")]];
            break;
        default:
            break;
    }
    [self.btn_redBag setBackgroundImage:[ImageBundle imagewithBundleName:@"redpack-right"] forState:UIControlStateNormal];
    [self.btn_redBag setBackgroundImage:[UIImage new] forState:UIControlStateDisabled];
    if (_model.have_red_envelope.boolValue) {
        [self startWobble];
    }else{
        [self stopWobble];
    }
    [self.btn_redBag setEnabled:_model.have_red_envelope.boolValue];
    if(_model.lottery_type > 0){
        _lotteryLabel.text = _model.lottery_name;
        _lotteryLabel.hidden = NO;
        _lotteryImageView.hidden = NO;
        _showGameView.hidden = NO;
        if (_model.lottery_name.length > 0) {
            NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
            CGSize size = [_model.lottery_name sizeWithAttributes:attrs];
            self.layout_lbWidthConstaint.constant = size.width + 2;
            self.layout_imgWidthConstraint.constant = size.width + 30;
        }
    }else{
        _lotteryLabel.hidden = YES;
        _lotteryImageView.hidden = YES;
        _showGameView.hidden = YES;
    }
    if ([PublicObj checkNull:_model.live_region_icon]) {
        self.regionleftConstaint.constant = 5;
    }else{
        self.regionleftConstaint.constant = 30;
    }
    [self.regionImgV sd_setImageWithURL:[NSURL URLWithString:_model.live_region_icon] placeholderImage:[ImageBundle imagewithBundleName:@""]];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 2;//阴影半径，默认值3
    shadow.shadowColor = [UIColor blackColor];//阴影颜色
    shadow.shadowOffset = CGSizeMake(0,2);//阴影偏移量，x向右偏移，y向下偏移，默认是（0，-3）
    NSAttributedString * attributedText = [[NSAttributedString alloc] initWithString:_model.live_region?:@"" attributes:@{NSShadowAttributeName:shadow}];
    self.regionLabel.attributedText = attributedText;
    
  
  
    // 如果 loopCount 为 1，强制修改
    if (_livinggifImgV.animationRepeatCount == 1) {
        _livinggifImgV.animationRepeatCount = 0; // 0 代表无限循环
    }
    
    if (model.supportVibrator && [model.supportVibrator boolValue]) {
        _livinggifImgV.image = self.vibratorGiftAnimation;
        [_livinggifImgV startAnimating];
        _livinggifImgV.hidden = NO;
        UIView *bgV =  [_livinggifImgV.superview viewWithTag:1101010];
        if (bgV) {
            bgV.hidden = NO;
        }
    } else if(model.isvideo && [model.isvideo boolValue]){
        _livinggifImgV.hidden = YES;
        UIView *bgV =  [_livinggifImgV.superview viewWithTag:1101010];
        if (bgV) {
            bgV.hidden = YES;
        }
        
        [_livinggifImgV stopAnimating];
        
    }else{
        _livinggifImgV.image = self.hotGiftAnimation;
        [_livinggifImgV startAnimating];
        _livinggifImgV.hidden = NO;
        UIView *bgV =  [_livinggifImgV.superview viewWithTag:1101010];
        if (bgV) {
            bgV.hidden = NO;
        }
    }
}



//- (void)setVideoModel:(NearbyVideoModel *)videoModel{
//    _videoModel = videoModel;
//    [_thumbImageView sd_setImageWithURL:[NSURL URLWithString:_videoModel.videoImage]];
//    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:_videoModel.userAvatar]];
//    _nameLabel.text = _videoModel.userName;
//    _numsLabel.text = _videoModel.views;
//    _numImgView.image = [ImageBundle imagewithBundleName:@"我的视频观看人数"];
//    _titleLabel.text = _videoModel.videoTitle;
//    _liveTypeImageView.image = [UIImage new];
//    if (_videoModel.videoTitle.length > 0) {
//        if (_jianju1.constant == 5) {
//            _jianju1.constant += 5;
//            _jianju2.constant += 5;
//        }
//    }else{
//        if (_jianju1.constant == 10) {
//            _jianju1.constant -= 5;
//            _jianju2.constant -= 5;
//            
//        }
//    }
//
//
//}
@end
