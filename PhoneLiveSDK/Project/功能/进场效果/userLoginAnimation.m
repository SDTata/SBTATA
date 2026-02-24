//
//  userLoginAnimation.m
//  yunbaolive
//
//  Created by 王敏欣 on 2017/2/21.
//  Copyright © 2017年 cat. All rights reserved.
//
#import "userLoginAnimation.h"
#import "UIImageView+WebCache.h"
#import <AFNetworking/AFImageDownloader.h>
@implementation userLoginAnimation
-(instancetype)init{
    self = [super init];
    if (self) {
        _isUserMove = 0;
        _userLogin = [NSMutableArray array];
    }
    return self;
}
-(void)addUserMove:(NSDictionary *)msg{
    
    if (msg == nil) {
        
        
        
    }
    else
    {
        [_userLogin addObject:msg];
    }
    if(_isUserMove == 0){
        [self userLoginOne];
    }
}
-(void)userLoginOne{
    
    if (_userLogin.count == 0 || _userLogin == nil) {
        return;
    }
    NSDictionary *Dic = [_userLogin firstObject];
    [_userLogin removeObjectAtIndex:0];
    [self userPlar:Dic];
}
/*
 vip_type 0表示无VIP，1表示普通VIP，2表示至尊VIP
 
 
 */
-(void)userPlar:(NSDictionary *)dic{
    _isUserMove = 1;

    float moveLeftSpace = 80;
    float avatarSize = 26;
    float avatarLeftSpace = 5 + 25;
    float enterRoomImageRightSpace = 100;
    float labelMaxWidth = _window_width - (avatarSize + avatarLeftSpace + enterRoomImageRightSpace);//_window_width*0.8-10;
    float imageScale = 2.0;

    UIImage *moveImage = [ImageBundle imagewithBundleName:@"enterRoomBg"];
    moveImage = [moveImage initWithCGImage:moveImage.CGImage scale:imageScale orientation:UIImageOrientationUp];
    CGFloat top = moveImage.size.height/2.0;
    CGFloat bottom = moveImage.size.height/2.0;
    CGFloat left = moveImage.size.width/2.0;
    CGFloat right = moveImage.size.width/2.0;
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    moveImage = [moveImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];

    float moveImageWidth = moveImage.size.width;
    float moveImageHeight = moveImage.size.height;
    _userMoveImageV = [[UIImageView alloc]initWithFrame:CGRectMake(_window_width + 20,-(moveImageHeight/3.0), _window_width*0.8,moveImageHeight)];
    [_userMoveImageV setImage:moveImage];
    [self addSubview:_userMoveImageV];
    _msgView = [[UIView alloc]initWithFrame:CGRectMake(-_window_width, 0, _window_width, moveImageHeight)];
    _msgView.backgroundColor = [UIColor clearColor];
    [self addSubview:_msgView];
    
    NSDictionary *ct = [dic valueForKey:@"ct"];

    UIImageView *iconImgView = [[UIImageView alloc]initWithFrame:CGRectMake(avatarLeftSpace,
                                                                            5,
                                                                            avatarSize,
                                                                            avatarSize)];
    iconImgView.layer.cornerRadius = avatarSize/2.0;
    iconImgView.layer.masksToBounds  =YES;
    iconImgView.layer.borderColor = [UIColor whiteColor].CGColor;
    iconImgView.layer.borderWidth = 1;
    [iconImgView sd_setImageWithURL:[NSURL URLWithString:minstr([ct valueForKey:@"avatar"])] placeholderImage:[ImageBundle imagewithBundleName:@"iconShortVideoDefaultAvatar"]];
    [_msgView addSubview:iconImgView];
    
    UIImageView *starImgView = [[UIImageView alloc]initWithFrame:CGRectMake(34, 19, 8, 8)];
    starImgView.image = [ImageBundle imagewithBundleName:@"loginStar"];
    [_msgView addSubview:starImgView];

    UILabel *nameL = [[UILabel alloc]initWithFrame:CGRectMake(iconImgView.right + 3, 2, labelMaxWidth,18)];
    nameL.textColor = [UIColor whiteColor];
    nameL.font = [UIFont systemFontOfSize:15];
    nameL.minimumScaleFactor = 0.3;
    nameL.adjustsFontSizeToFitWidth = YES;
    NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[ct valueForKey:@"user_nicename"]]];
    
    NSDictionary *levelDic = [common getUserLevelMessage:minstr([ct valueForKey:@"level"])];
    NSAttributedString *speaceString = [[NSAttributedString  alloc]initWithString:@" "];
    
    
    NSTextAttachment *shouAttchment = [[NSTextAttachment alloc]init];
    shouAttchment.bounds = CGRectMake(0, -2, 15, 15);//设置frame
    shouAttchment.image = [ImageBundle imagewithBundleName:YZMsg(@"chatModel_chat_shou")];//设置图片
    NSAttributedString *shouString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(shouAttchment)];
    
    NSTextAttachment *vipAttchment = [[NSTextAttachment alloc]init];
    vipAttchment.bounds = CGRectMake(0, -2, 30, 15);//设置frame
    vipAttchment.image = [ImageBundle imagewithBundleName:@"chat_vip"];//设置图片
    NSAttributedString *vipString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(vipAttchment)];
    
    NSTextAttachment *levelAttchment = [[NSTextAttachment alloc]init];
    levelAttchment.bounds = CGRectMake(0, -2, 30, 15);//设置frame
    
    NSTextAttachment *yearAttchment = [[NSTextAttachment alloc]init];
    yearAttchment.bounds = CGRectMake(0, -2, 15, 15);//设置frame
    yearAttchment.image = [ImageBundle imagewithBundleName:YZMsg(@"chatModel_chat_shou_year")];//设置图片
    NSAttributedString *yearString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(yearAttchment)];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *cacheKey1 = [manager cacheKeyForURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])]];
    UIImage *cachedImage1 = [[SDImageCache sharedImageCache] imageFromCacheForKey:cacheKey1];
    if (cachedImage1) {
        levelAttchment.image = cachedImage1;
        levelAttchment.bounds = CGRectMake(0, -2, (cachedImage1.size.width / cachedImage1.size.height) * 15, 15);
    }
    
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:minstr([levelDic valueForKey:@"thumb"])] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if (image) {
            levelAttchment.image = image;
        }

    }];
    
    
    NSString *king_icon = [NSString stringWithFormat:@"%@",[ct valueForKey:@"king_icon"]];
    if (king_icon!= nil && king_icon.length>0) {
        NSTextAttachment *kingAttchment = [[NSTextAttachment alloc]init];
        kingAttchment.bounds = CGRectMake(0, -2, 35, 15);//设置frame
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        NSString *cacheKey = [manager cacheKeyForURL:[NSURL URLWithString:king_icon]];
        UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:cacheKey];
        if (cachedImage) {
            kingAttchment.image = cachedImage;
            kingAttchment.bounds = CGRectMake(0, -2, (cachedImage.size.width / cachedImage.size.height) * 15, 15);
        }
        
        NSAttributedString *kingString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(kingAttchment)];
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:king_icon] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image) {
                kingAttchment.image = image;
            }

        }];
        [noteStr insertAttributedString:speaceString atIndex:0];//插入到第几个下标
        [noteStr insertAttributedString:kingString atIndex:0];//插入到第几个下标
    }

    NSAttributedString *levelString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(levelAttchment)];
    NSTextAttachment *liangAttchment = [[NSTextAttachment alloc]init];
    liangAttchment.bounds = CGRectMake(0, -2, 15, 15);//设置frame
    liangAttchment.image = [ImageBundle imagewithBundleName:YZMsg(@"chatModel_chat_liang")];//设置图片
    NSAttributedString *liangString = [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(liangAttchment)];

    //插入靓号图标
    if (![minstr([ct valueForKey:@"liangname"]) isEqual:@"0"] && ![minstr([ct valueForKey:@"liangname"]) isEqual:@"(null)"] && minstr([ct valueForKey:@"liangname"]) !=nil && minstr([ct valueForKey:@"liangname"]) !=NULL) {
        [noteStr insertAttributedString:speaceString atIndex:0];//插入到第几个下标
        [noteStr insertAttributedString:liangString atIndex:0];//插入到第几个下标
    }
    //插入守护图标
    if ([minstr([ct valueForKey:@"guard_type"]) isEqual:@"1"]) {
        [noteStr insertAttributedString:speaceString atIndex:0];//插入到第几个下标
        [noteStr insertAttributedString:shouString atIndex:0];//插入到第几个下标
    }
    if ([minstr([ct valueForKey:@"guard_type"]) isEqual:@"2"]) {
        [noteStr insertAttributedString:speaceString atIndex:0];//插入到第几个下标
        [noteStr insertAttributedString:yearString atIndex:0];//插入到第几个下标
    }

    NSString *vipType = [NSString stringWithFormat:@"%@",[ct valueForKey:@"vip_type"]];
    //插入VIP图标
    if ([vipType isEqual:@"1"]) {
        [noteStr insertAttributedString:speaceString atIndex:0];//插入到第几个下标
        [noteStr insertAttributedString:vipString atIndex:0];//插入到第几个下标
    }
   
    [noteStr insertAttributedString:speaceString atIndex:0];//插入到第几个下标
    [noteStr insertAttributedString:levelString atIndex:0];//插入到第几个下标
    
    [nameL setAttributedText:noteStr];

    CGSize nameLSize = [nameL sizeThatFits:CGSizeMake(1000, 20)];
    float contentWidth = nameLSize.width;
    if (contentWidth > labelMaxWidth) {
        contentWidth = labelMaxWidth;
    }
    float userMoveImageVWidth = avatarLeftSpace + avatarSize + contentWidth + enterRoomImageRightSpace;
    if (userMoveImageVWidth <= moveImageWidth) {
        userMoveImageVWidth = moveImageWidth;
    }
    _userMoveImageV.width = userMoveImageVWidth;
    [_msgView addSubview:nameL];

    UILabel *enterRoomTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(iconImgView.right + 3,
                                                                            CGRectGetMaxY(nameL.frame) - 3,
                                                                            labelMaxWidth,
                                                                            15)];
    enterRoomTitleLabel.text = YZMsg(@"nuserLoginAnimation_enter_room");
    enterRoomTitleLabel.textColor = [UIColor whiteColor];
    enterRoomTitleLabel.font = [UIFont systemFontOfSize:13];
    enterRoomTitleLabel.minimumScaleFactor = 0.3;
    enterRoomTitleLabel.adjustsFontSizeToFitWidth = YES;
    [_msgView addSubview:enterRoomTitleLabel];

    CGMutablePathRef path = CGPathCreateMutable();
    //CGPathAddArc函数是通过圆心和半径定义一个圆，然后通过两个弧度确定一个弧线。注意弧度是以当前坐标环境的X轴开始的。
    //需要注意的是由于ios中的坐标体系是和Quartz坐标体系中Y轴相反的，所以iOS UIView在做Quartz绘图时，Y轴已经做了Scale为-1的转换，因此造成CGPathAddArc函数最后一个是否是顺时针的参数结果正好是相反的，也就是说如果设置最后的参数为1，根据参数定义应该是顺时针的，但实际绘图结果会是逆时针的！
    //严格的说，这个方法只是确定一个中心点后，以某个长度作为半径，以确定的角度和顺逆时针而进行旋转，半径最低设置为1，设置为0则动画不会执行
    
    CGPathAddArc(path, NULL, iconImgView.centerX, iconImgView.centerY, 16, 0,M_PI * 2, 0);
    
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.path = path;
    CGPathRelease(path);
    animation.duration = 3;
    animation.repeatCount = 1;
    animation.autoreverses = NO;
    animation.rotationMode =kCAAnimationRotateAuto;
    animation.fillMode =kCAFillModeForwards;
    WeakSelf
    [UIView animateWithDuration:0.5 animations:^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
//        _userMoveImageV.frame = CGRectMake(-15,10,_window_width*0.8,40);
        strongSelf.userMoveImageV.x = moveLeftSpace;
        strongSelf.msgView.x = moveLeftSpace;
    }completion:^(BOOL finished) {
        [starImgView.layer addAnimation:animation forKey:nil];
    }];

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       STRONGSELF
       if (strongSelf == nil) {
           return;
       }
        
        [UIView animateWithDuration:1.5 animations:^{
//            _userMoveImageV.frame = CGRectMake(-15,10,_window_width*0.8,40);
//            _userMoveImageV.alpha = 0;
            if (strongSelf == nil) {
                return;
            }
            strongSelf.userMoveImageV.x = 10;
            strongSelf.msgView.x = 10;

        }] ;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       STRONGSELF
       if (strongSelf == nil) {
           return;
       }
        
        [UIView animateWithDuration:0.5 animations:^{
            if (strongSelf == nil) {
                return;
            }
            strongSelf.userMoveImageV.x = -_window_width;
            strongSelf.msgView.x = -_window_width;
        } completion:^(BOOL finished) {
            STRONGSELF
            if (strongSelf == nil) {
                return;
            }
            [strongSelf.userMoveImageV removeFromSuperview];
            strongSelf.userMoveImageV = nil;
            [strongSelf.msgView removeFromSuperview];
            strongSelf.msgView = nil;
            strongSelf.isUserMove = 0;
            if (strongSelf.userLogin.count >0) {
                [strongSelf addUserMove:nil];
            }
        }];

    });
}
@end
