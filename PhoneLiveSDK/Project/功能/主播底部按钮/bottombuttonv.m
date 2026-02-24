//
//  bottombuttonv.m
//  yunbaolive
//
//  Created by 王敏欣 on 2017/8/2.
//  Copyright © 2017年 cat. All rights reserved.
//
#import "bottombuttonv.h"
#import <AVFoundation/AVFoundation.h>//调用闪光灯需要导入该框架

@interface bottombuttonv ()
{
    UIView *bottomv;
}
@property(nonatomic,strong)NSMutableArray *buttonarray;
@end
@implementation bottombuttonv
-(instancetype)initWithFrame:(CGRect)frame music:(buttonblock)music meiyan:(buttonblock)meiyan coast:(buttonblock)coast light:(buttonblock)light camera:(buttonblock)camera game:(buttonblock)game jingpai:(buttonblock)jingpai hongbao:(buttonblock)hongbao lianmai:(buttonblock)lianmai jishi:(buttonblock)jishiblock piaofang:(buttonblock)piaofangblock showjingpai:(NSString *)isjingpai showgame:(NSArray *)gametypearray showcoase:(int)coastshow hideself:(buttonblock)hide andIsTorch:(BOOL)isTorch{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        _buttonarray = [NSMutableArray array];
        self.musicblock = music;
        self.gameblock = game;
        self.lightblock = light;
        self.meiyanblock = meiyan;
        self.coastblock = coast;
        self.camerablock = camera;
        self.jingpaiblock = jingpai;
        self.hideselfblock = hide;
        self.redBagblock = hongbao;
        self.linkblock = lianmai;
        self.jishiblock = jishiblock;
        self.piaofangblock = piaofangblock;
        bottomv = [[UIView alloc]initWithFrame:CGRectMake(10, _window_height - _window_width/5 * 3.5, _window_width-20, _window_width/5 * 3.5-55-ShowDiff)];
        
        
        bottomv.backgroundColor = [UIColor whiteColor];
        bottomv.layer.cornerRadius = 10;
        bottomv.layer.masksToBounds = YES;
        [self addSubview:bottomv];
//        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, _window_width,40)];
//        label1.font = fontMT(17);
//        label1.text = @"功能";
//        label1.textColor = RGB(92, 92, 92);
//        [bottomv addSubview:label1];
        
        
//        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(20,40, _window_width - 40,1)];
//        label2.backgroundColor = [UIColor groupTableViewBackgroundColor];
//        [bottomv addSubview:label2];
        
        
        //图片名字 命名
//        _buttonarray =[NSMutableArray arrayWithObjects: @"coast-button",@"beaytiful-button",@"Flip-button",@"music-button",@"game-button",@"Auction-button",@"light-button", nil];
        _buttonarray = @[YZMsg(@"bottombuttonv_beauty"),YZMsg(@"bottombuttonv_flip"),YZMsg(@"bottombuttonv_flash"),YZMsg(@"bottombuttonv_music"),YZMsg(@"bottombuttonv_share"),YZMsg(@"bottombuttonv_redBag"),YZMsg(@"bottombuttonv_timing"),YZMsg(@"bottombuttonv_tickets")].mutableCopy;
        
        //判断如果游戏数量为0 则不添加游戏按钮
        if ([[common share_type] count] == 0) {
            [_buttonarray removeObject:YZMsg(@"bottombuttonv_share")];
        }
      
        CGFloat X = (_window_width-20-250)/6;
        CGFloat Y = (bottomv.height-100)/3;
        for (int i=0; i<_buttonarray.count; i++) {
            UIButton *btn = [UIButton buttonWithType:0];
            [btn addTarget:self action:@selector(doaction:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitleColor:[UIColor clearColor] forState:0];
            btn.frame = CGRectMake(X+i%5*(X + 50), Y+i/5*(Y+50), 50, 50);
            btn.tag = i + 1000;
            [bottomv addSubview:btn];
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(12.5, 0, 25, 25)];
            if ([_buttonarray[i] isEqual:YZMsg(@"bottombuttonv_flash")]) {
                if (isTorch) {
                    imgView.image = [ImageBundle imagewithBundleName:@"Function_Flash_On"];
                }else{
                    imgView.image = [ImageBundle imagewithBundleName:@"Function_Flash_off"];
                }
            }else if([_buttonarray[i] isEqual:YZMsg(@"bottombuttonv_timing")]){
                imgView.image = [ImageBundle imagewithBundleName:@"jishi"];
            }else if([_buttonarray[i] isEqual:YZMsg(@"bottombuttonv_tickets")]){
                imgView.image = [ImageBundle imagewithBundleName:@"menpiao"];
            }else if([_buttonarray[i] isEqual:YZMsg(@"bottombuttonv_beauty")]){
                imgView.image = [ImageBundle imagewithBundleName:@"Function_Beauty"];
            }else if([_buttonarray[i] isEqual:YZMsg(@"bottombuttonv_flip")]){
                imgView.image = [ImageBundle imagewithBundleName:@"Function_Flip"];
            }else if([_buttonarray[i] isEqual:YZMsg(@"bottombuttonv_music")]){
                imgView.image = [ImageBundle imagewithBundleName:@"Function_Accompaniment"];
            }else if([_buttonarray[i] isEqual:YZMsg(@"bottombuttonv_share")]){
                imgView.image = [ImageBundle imagewithBundleName:@"Function_Share"];
            }else if([_buttonarray[i] isEqual:YZMsg(@"bottombuttonv_redBag")]){
                imgView.image = [ImageBundle imagewithBundleName:@"Function_Red_Envelope"];
            }
            [btn addSubview:imgView];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 32, btn.width, 18)];
            label.textAlignment = NSTextAlignmentCenter;
            label.adjustsFontSizeToFitWidth = YES;
            label.minimumScaleFactor = 0.5;
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = RGB_COLOR(@"#959697", 1);
            label.text = YZMsg(_buttonarray[i]);
            [btn addSubview:label];
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
-(void)hide{
    self.hideselfblock(@"1");
}
-(void)hidebtn{
//    for (UIButton *btn in bottomv.subviews) {
//          if ([btn isKindOfClass:[UIButton class]]) {
//
//        if ([btn.titleLabel.text isEqual:@"Auction-button"]) {
//            btn.hidden = YES;
//        }
//
//          }
//    }
}
-(void)showbtn{
//    for (UIButton *btn in bottomv.subviews) {
//        if ([btn isKindOfClass:[UIButton class]]) {
//        if ([btn.titleLabel.text isEqual:@"Auction-button"]) {
//            btn.hidden = NO;
//        }
//    }
//    }
}
-(void)doaction:(UIButton *)sender{
    NSString *str = _buttonarray[sender.tag - 1000];
    if ([str isEqual:YZMsg(@"bottombuttonv_share")]) {
        self.coastblock(@"1");
    }
    else if ([str isEqual:YZMsg(@"bottombuttonv_beauty")]) {
        self.meiyanblock(@"1");
    }
    else if ([str isEqual:YZMsg(@"bottombuttonv_flip")]) {
        self.camerablock(@"1");
    }
    else if ([str isEqual:YZMsg(@"bottombuttonv_music")]) {
        self.musicblock(@"1");
    }
    else if ([sender.titleLabel.text isEqual:@"Auction-button"]) {
        self.jingpaiblock(@"1");
    }
    else if ([str isEqual:YZMsg(@"bottombuttonv_flash")]) {
        self.lightblock(@"1");
    }
    else if ([str isEqual:YZMsg(@"bottombuttonv_redBag")]) {
        self.redBagblock(@"1");
    }
    else if([str isEqual:YZMsg(@"bottombuttonv_timing")]){
        self.jishiblock(@"1");
    }else if([str isEqual:YZMsg(@"bottombuttonv_tickets")]){
        self.piaofangblock(@"1");
    }
    self.hideselfblock(@"1");
}


@end
