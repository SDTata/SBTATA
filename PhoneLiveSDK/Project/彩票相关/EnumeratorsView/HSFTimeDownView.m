//
//  HSFTimeDownView.m
//  TimeLabel
//
//  Created by 黄山锋 on 2018/7/16.
//  Copyright © 2018年 JustCompareThin. All rights reserved.
//

#import "HSFTimeDownView.h"

#import "HSFTimeNumberView.h"
#import "HSFTimeDownConfig.h"




@interface HSFTimeDownView()


@property (nonatomic,strong) HSFTimeDownConfig *config;
@property(nonatomic,assign)NSInteger number;
@property(nonatomic,copy)void(^change)(NSInteger);
@property(nonatomic,copy)void(^end)(void);
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)BOOL bCreateUI;

@property (nonatomic,strong) UILabel *dayLB;

@property(nonatomic,strong)HSFTimeNumberView *hourH;
@property(nonatomic,strong)HSFTimeNumberView *hourL;

@property(nonatomic,strong)HSFTimeNumberView *minuteH;
@property(nonatomic,strong)HSFTimeNumberView *minuteL;

@property(nonatomic,strong)HSFTimeNumberView *secondH;
@property(nonatomic,strong)HSFTimeNumberView *secondL;

@end


@implementation HSFTimeDownView
/* 初始化方法 */
-(instancetype)initWityFrame:(CGRect)frame config:(HSFTimeDownConfig *)config timeChange:(void(^)(NSInteger time))timeChange timeEnd:(void(^)(void))timeEnd{
    if (self = [super initWithFrame:frame]) {
        self.config = config;
        self.change = timeChange;
        self.end = timeEnd;
    }
    return self;
}

//添加view
-(void)addTimeViews:(NSInteger)day {
    if(self.bCreateUI) return;
    self.bCreateUI = true;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGFloat px = width;
    CGFloat placeW = 8.f;
    CGFloat space = 1.f;
    CGFloat itemW = (width-placeW*3-space*3)/6.f;
    CGFloat dayW = 0.f;
    if (day > 0) {
        NSString *dayStr = [NSString stringWithFormat:@"%ld",(long)day];
        CGSize size = [self sizeWithString:dayStr font:[UIFont systemFontOfSize:self.config.fontSize] maxSize:CGSizeMake(MAXFLOAT, height)];
        dayW = size.width;
        if (self.config.timeType == HSFTimeType_HOUR_MINUTE_SECOND) {
            itemW = (width-placeW*4-space*3-dayW)/7.f;
        }
        else if (self.config.timeType == HSFTimeType_HOUR_MINUTE) {
            itemW = (width-placeW*3-space*2-dayW)/4.f;
        }
    }else{
        if (self.config.timeType == HSFTimeType_HOUR_MINUTE_SECOND) {
            itemW = (width-placeW*4-space*3)/6.f;
        }
        else if (self.config.timeType == HSFTimeType_HOUR_MINUTE) {
            itemW = (width-placeW*3-space*2)/4.f;
        }
    }
    
    if (self.config.timeType == HSFTimeType_HOUR_MINUTE_SECOND) {
        
        px -= placeW;
        UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(px, 0, placeW, height)];
        secondLabel.textAlignment = NSTextAlignmentCenter;
        secondLabel.text = @"";
        secondLabel.font = [UIFont systemFontOfSize:self.config.fontSize_placeholder];
        secondLabel.textColor = self.config.fontColor_placeholder;
        [self addSubview:secondLabel];
        
        px -= itemW;
        self.secondL = [[HSFTimeNumberView alloc] initWithFrame:CGRectMake(px, 0, itemW, height) maxNumber:9 fontSize:self.config.fontSize fontColor:self.config.fontColor bgColor:self.config.bgColor cornerRadius:self.config.cornerRadius];
        [self addSubview:self.secondL];
        
        px -= (itemW + space);
        self.secondH = [[HSFTimeNumberView alloc] initWithFrame:CGRectMake(px, 0, itemW, height) maxNumber:5 fontSize:self.config.fontSize fontColor:self.config.fontColor bgColor:self.config.bgColor cornerRadius:self.config.cornerRadius];
        [self addSubview:self.secondH];
        
    }
    
    px -= placeW;
    UILabel *minuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(px, 0, placeW, height)];
    minuteLabel.textAlignment=NSTextAlignmentCenter;
    minuteLabel.text=@":";
    minuteLabel.font=[UIFont systemFontOfSize:self.config.fontSize_placeholder];
    minuteLabel.textColor=self.config.fontColor_placeholder;
    [self addSubview:minuteLabel];
    
    px -= itemW;
    self.minuteL = [[HSFTimeNumberView alloc] initWithFrame:CGRectMake(px, 0, itemW, height) maxNumber:9 fontSize:self.config.fontSize fontColor:self.config.fontColor bgColor:self.config.bgColor cornerRadius:self.config.cornerRadius];
    [self addSubview:self.minuteL];
    
    px -= (itemW + space);
    self.minuteH = [[HSFTimeNumberView alloc] initWithFrame:CGRectMake(px, 0, itemW, height) maxNumber:5 fontSize:self.config.fontSize fontColor:self.config.fontColor bgColor:self.config.bgColor cornerRadius:self.config.cornerRadius];
    [self addSubview:self.minuteH];
    
    
    px -= placeW;
    UILabel *hourLabel = [[UILabel alloc]initWithFrame:CGRectMake(px, 0, placeW, height)];
    hourLabel.textAlignment=NSTextAlignmentCenter;
    hourLabel.text=@":";
    hourLabel.font = [UIFont systemFontOfSize:self.config.fontSize_placeholder];
    hourLabel.textColor = self.config.fontColor_placeholder;
    [self addSubview:hourLabel];
    
    px -= itemW;
    self.hourL=[[HSFTimeNumberView alloc]initWithFrame:CGRectMake(px, 0, itemW, height) maxNumber:9 fontSize:self.config.fontSize fontColor:self.config.fontColor bgColor:self.config.bgColor cornerRadius:self.config.cornerRadius];
    [self addSubview:self.hourL];
    
    px -= (itemW + space);
    self.hourH = [[HSFTimeNumberView alloc]initWithFrame:CGRectMake(px, 0, itemW, height) maxNumber:5 fontSize:self.config.fontSize fontColor:self.config.fontColor bgColor:self.config.bgColor cornerRadius:self.config.cornerRadius];
    [self addSubview:self.hourH];
   
    
    if (day > 0) {
        px -= placeW*2;
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(px, 0, placeW*2, height)];
        dayLabel.textAlignment=NSTextAlignmentCenter;
        dayLabel.text=YZMsg(@"public_Day");
        dayLabel.tag = 1000000;
        dayLabel.font=[UIFont systemFontOfSize:self.config.fontSize_placeholder];
        dayLabel.textColor=self.config.fontColor_placeholder;
        [self addSubview:dayLabel];
        
        px -= dayW;
        self.dayLB = [[UILabel alloc] initWithFrame:CGRectMake(px, 0, dayW, height)];
        self.dayLB.textAlignment=NSTextAlignmentCenter;
        self.dayLB.text=@"0";
        self.dayLB.font=[UIFont systemFontOfSize:self.config.fontSize];
        self.dayLB.textColor=self.config.fontColor_day;
        [self addSubview:self.dayLB];
    }
}


- (void)setcurentTime:(NSInteger)curentTime{
    if (curentTime<=0) {
        return;
    }
    NSInteger day = curentTime/(3600*24);
    
    if (curentTime >= 24*60*60) {
        
        [self addTimeViews:day];
        self.dayLB.text = [NSString stringWithFormat:@"%ld",day];
    }else{
        [self addTimeViews:0];
        if (self.dayLB) {
            self.dayLB.text = [NSString stringWithFormat:@"%d",0];
            self.dayLB.hidden = YES;
            UILabel *subDL = [self viewWithTag:1000000];
            if (subDL) {
                subDL.hidden = YES;
            }
        }
    }
    
    self.number = curentTime;
    
    NSInteger hour = curentTime/3600;
    
    if (day>0) {
        hour=(curentTime%(3600*24))/3600;
    }
    
    
    NSInteger hourLeft = hour/10;
    NSInteger hourRight=hour%10;
    [self.hourH setCurentNumber:hourLeft];
    [self.hourL setCurentNumber:hourRight];
    
    
    if (day>0) {
        //分钟
        curentTime-=(hour*3600+day*3600*24);
    }else{
        //分钟
        curentTime-=hour*3600;
    }
    
    
    NSInteger minute = curentTime/60;
    NSInteger minuteLeft = minute/10;
    NSInteger minuteRight = minute%10;
    [self.minuteH setCurentNumber:minuteLeft];
    [self.minuteL setCurentNumber:minuteRight];
    
    
    if (self.config.timeType == HSFTimeType_HOUR_MINUTE_SECOND) {
        curentTime -= minute * 60;
        NSInteger secondLeft = curentTime/10;
        NSInteger secondRight = curentTime%10;
        [self.secondH setCurentNumber:secondLeft];
        [self.secondL setCurentNumber:secondRight];
    }
   
    if(!self.timer){
        self.timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(numberChange) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

-(void)refreshNumber:(NSInteger)num{
    [self setcurentTime:num];
//    if(!self.timer && num >= 0){
//        self.timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(numberChange) userInfo:nil repeats:YES];
//    }
//    self.number = num;
//
//    [self.hourH numberChange];
//    [self.hourL numberChange];
}

-(void)numberChange{
    if (!self.superview || !self.hourH || !self.hourL || !self.minuteH || !self.minuteL) {
        [self.timer invalidate];
        self.timer = nil;
        return;
    }
    self.number--;
    if (self.number<=0) {
        if (self.number==0) {
            if (self.end) {
                self.end();
            }
        }else{
            [self.timer invalidate];
            self.timer=nil;
            return;
        }
    }else{
        if (self.change) {
            self.change(self.number);
        }
    }
    NSInteger curentTime=self.number;
    NSInteger day=curentTime/(3600*24);
    NSInteger hour=curentTime/3600;
    
    if (day>0) {
        hour=(curentTime%(3600*24))/3600;
        //天
        self.dayLB.text = [NSString stringWithFormat:@"%ld",day];
    }else{
        if (self.dayLB) {
            self.dayLB.text = [NSString stringWithFormat:@"%d",0];
            self.dayLB.hidden = YES;
            UILabel *subDL = [self viewWithTag:1000000];
            if (subDL) {
                subDL.hidden = YES;
            }
        }
        
    }
    
    NSInteger hourLeft=hour/10;
    NSInteger hourRight=hour%10;
  
    if (day>0) {
        if(self.hourH.curentNumber == 0){
            [self.hourH setCurentNumber:hourLeft];
        }
        if(self.hourL.curentNumber == 0){
            [self.hourL setCurentNumber:hourRight];
        }
    }
    
    //小时
    if (self.hourH.curentNumber!=hourLeft) {
        [self.hourH numberChange];
    }
    if (self.hourL.curentNumber!=hourRight) {
        [self.hourL numberChange];
    }

   
    
    if (day>0) {
        //分钟
        curentTime-=(hour*3600+day*3600*24);
    }else{
        //分钟
        curentTime-=hour*3600;
    }
    
    
    NSInteger minute=curentTime/60;
    NSInteger minuteLeft=minute/10;
    NSInteger minuteRight=minute%10;
    
    if (day>0) {
        if(self.minuteH.curentNumber == 0){
            [self.minuteH setCurentNumber:minuteLeft];
        }
        if(self.minuteL.curentNumber == 0){
            [self.minuteL setCurentNumber:minuteRight];
        }
    }
    
    if (self.minuteH.curentNumber!=minuteLeft) {
        [self.minuteH numberChange];
    }
    if (self.minuteL.curentNumber!=minuteRight) {
        [self.minuteL numberChange];
    }
    
    //秒
    if (self.config.timeType==HSFTimeType_HOUR_MINUTE_SECOND) {
        curentTime-=minute*60;
        NSInteger secondLeft=curentTime/10;
        NSInteger secondRight=curentTime%10;
        
        if (day>0 && self.secondH.curentNumber == 0) {
            [self.secondH setCurentNumber:secondLeft];
           
        }
        if (day>0 && self.secondL.curentNumber == 0) {
            [self.secondL setCurentNumber:secondRight];
        }
        
        
        if (self.secondH.curentNumber!=secondLeft) {
            [self.secondH numberChange];
        }
        if (self.secondL.curentNumber!=secondRight) {
            [self.secondL numberChange];
        }
    }
}

-(void)invaliTimer{
    if (self.timer) {
        [self.timer invalidate];
        self.timer=nil;
    }
}

-(void)dealloc{
    if (self.timer) {
        [self.timer invalidate];
        self.timer=nil;
    }
}

//获取字符串size
-(CGSize)sizeWithString:(NSString *)string font:(UIFont *)font maxSize:(CGSize)maxSize{
    if (!string) {
        return CGSizeZero;
    }
    NSDictionary *dict = @{NSFontAttributeName : font};
    
    CGSize size = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    
    return size;
}




@end
