//
//  AttentionHeader.m
//  phonelive2
//
//  Created by test on 4/9/21.
//  Copyright © 2021 toby. All rights reserved.
//

#import "AttentionHeader.h"

@interface AttentionHeader(){
    YBNoWordView *noNetwork;
}
@property(nonatomic,assign)NSInteger sourceType;
@property(nonatomic,strong)void(^noNetHandler)(void);
@end
@implementation AttentionHeader

- (instancetype)initWithSourceType:(NSInteger)sourceType noNetHandler:(void(^)(void))noNetHandler{
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        _sourceType = sourceType;
        _noNetHandler = noNetHandler;
    }
    return self;
}
- (void)createSubView{
    self.frame = CGRectMake(AD(0), AD(0), _window_width, AD(57));
    UIView *background = [[UIView alloc]initWithFrame:CGRectMake(AD(0), AD(12), _window_width, AD(45))];
    background.backgroundColor = [UIColor clearColor];
    [self addSubview:background];
//    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(AD(13), AD(19), AD(32), AD(11))];
//    imgView.contentMode = UIViewContentModeScaleAspectFit;
//    [imgView setImage:[ImageBundle imagewithBundleName:@"bg_gza.png"]];
//    [background addSubview:imgView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(AD(13), AD(15), AD(160), AD(15))];
    [label setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium]];
    [label setTextColor:RGB(51, 51, 51)];
    //    [labTitle setTextAlignment:NSTextAlignmentCenter];
    if (_sourceType == 1001) {
        [label setText:YZMsg(@"AttentionHeader_myAttention")];
    }else{
        [label setText:YZMsg(@"AttentionHeader_Popular_Hot")];
    }
    [background addSubview:label];
    [label sizeToFit];
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(label.right - 29, label.bottom +3, 30, AD(3))];
    line.backgroundColor = RGB(184, 92, 238);
    line.layer.masksToBounds = YES;
    line.layer.cornerRadius = 1.5;
    [background addSubview:line];
}
- (void)createNowordView{
    self.frame = CGRectMake(AD(0), AD(0), _window_width, AD(150));
//    WeakSelf
//    noNetwork = [[YBNoWordView alloc]initWithImageName:NULL andTitle:self.sourceType == 1001?YZMsg(@"AttentionHeader_No_Attention"):YZMsg(@"AttentionHeader_No_Hot") withBlock:^(id  _Nullable msg) {
//        STRONGSELF
//        if (strongSelf.noNetHandler) {
//            strongSelf.noNetHandler();
//        }
//    } AddTo:self];
//    noNetwork.hidden = NO;
    
    UIImageView * noDataImgView = [[UIImageView alloc] initWithFrame:CGRectMake(AD(80),AD(50), _window_width - AD(160), AD(140))];
    noDataImgView.image =  [ImageBundle imagewithBundleName:@"gz_di1"];
    [self addSubview:noDataImgView];
}
- (void)reloadDatas:(NSArray *)data{
    for (UIView *s in self.subviews) {
        [s removeFromSuperview];
    }
    noNetwork = nil;
    if (data.count == 0) {
        [self createSubView];
        [self createNowordView];
    }else{
        [self createSubView];
    }
    
}

@end
