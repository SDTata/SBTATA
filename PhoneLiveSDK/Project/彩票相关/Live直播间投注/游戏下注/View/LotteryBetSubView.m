//
//  LotteryBetSubView.m
//  phonelive2
//
//  Created by 400 on 2022/6/18.
//  Copyright © 2022 toby. All rights reserved.
//

#import "UIControl+Category.h"
#import "LotteryBetSubView.h"
@interface LotteryBetSubView()
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (weak, nonatomic) IBOutlet UIButton *contentButton;
@property(nonatomic,copy)LotteryBetBlock blockCallBack;

@end
@implementation LotteryBetSubView

+ (instancetype)instanceLotteryBetSubViewwWithFrame:(CGRect)frame contentEdge:(float)bottom  withBlock:(LotteryBetBlock)block
{
    LotteryBetSubView *instance = [[[XBundle currentXibBundleWithResourceName:@""] loadNibNamed:@"LotteryBetSubView" owner:nil options:nil] lastObject];
    instance.blockCallBack = block;
    instance.frame = frame;
    instance.contentButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    instance.contentButton.titleLabel.minimumScaleFactor = 0.5;
    
    [instance.contentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, bottom, 0)];
    instance.betInfos = [NSMutableArray array];
    return instance;
}

-(void)setIsHiddenTopView:(BOOL)isHiddenTopView
{
    _isHiddenTopView = isHiddenTopView;
    if (isHiddenTopView) {
        _sureButton.hidden = YES;
        _cancelButton.hidden = YES;
    }else{
        _sureButton.hidden = NO;
        _cancelButton.hidden = NO;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
{
    if (_isHiddenTopView) {
        return nil;
    }
    
    CGPoint sureBtnPoint = [self convertPoint:point toView:_sureButton];
    if ([_sureButton pointInside:sureBtnPoint withEvent:event]) {
        return _sureButton;
    }
    CGPoint cancelBtnPoint = [self convertPoint:point toView:_cancelButton];
    if ([_cancelButton pointInside:cancelBtnPoint withEvent:event]) {
        return _cancelButton;
    }
    
    return nil;
}

- (IBAction)cancelAction:(UIButton *)sender {
    if (self.blockCallBack) {
        self.blockCallBack(false);
    }
    
}
- (IBAction)sureAction:(UIButton *)sender {
    if (self.blockCallBack) {
        
        self.blockCallBack(true);
    }
}

-(void)addBetNum:(NSString*)number ways:(NSString*)ways
{
    NSString *numBet = self.contentButton.OrderTags; // 已加总的rateCurrency

    double rateCurrency = [YBToolClass getRateCurrencyWithoutK:number].doubleValue;
    double numNowBet = numBet.doubleValue+rateCurrency;
    
    NSString *title = [YBToolClass currencyCoverToK:[NSString stringWithFormat: numNowBet == (int)numNowBet ? @"%.0f" : @"%.2f", numNowBet]];
    [self.contentButton setTitle:title forState:UIControlStateNormal];
    [self.contentButton setOrderTags: [NSString stringWithFormat: @"%f",numNowBet]]; //OrderTags用来保存rateCurrency计算使用
    [self.betInfos addObject:@{@"way":ways,@"money": [NSString stringWithFormat: @"%f",numNowBet], @"rmbMoney": number}];
    self.isHiddenTopView = false;
}

-(void)updateMineNumb:(double)mine
{
    NSString *title = [YBToolClass currencyCoverToK:[NSString stringWithFormat:mine == (int)mine ? @"%.0f" : @"%.2f",mine]];
    [self.contentButton setTitle:title forState:UIControlStateNormal];
    [self.contentButton setOrderTags: [NSString stringWithFormat: @"%f",mine]];
    self.isHiddenTopView = YES;
}

-(void)sureBetView
{
    [_betInfos removeAllObjects];
}
-(void)clearBetView
{
    double numberShow = self.contentButton.OrderTags.doubleValue;
    for (NSDictionary *subDic in self.betInfos) {
        double numberBet = [[subDic objectForKey:@"money"] doubleValue];
        numberShow = numberShow - numberBet;
    }
    
    [_betInfos removeAllObjects];
    if (numberShow <= 0) {
        [self removeFromSuperview];
    }else{
        [self updateMineNumb:numberShow];
    }
}
@end
