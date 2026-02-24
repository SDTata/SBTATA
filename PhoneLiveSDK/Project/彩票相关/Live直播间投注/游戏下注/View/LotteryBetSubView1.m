//
//  LotteryBetSubView.m
//  phonelive2
//
//  Created by 400 on 2022/6/18.
//  Copyright © 2022 toby. All rights reserved.
//

#import "LotteryBetSubView1.h"
@interface LotteryBetSubView1()
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *sureButton;
@property (weak, nonatomic) IBOutlet UIButton *contentButton;
@property(nonatomic,copy)LotteryBetBlock blockCallBack;

@end
@implementation LotteryBetSubView1

+ (instancetype)instanceLotteryBetSubViewwWithFrame:(CGRect)frame contentEdge:(float)bottom  withBlock:(LotteryBetBlock)block
{
    LotteryBetSubView1 *instance = [[[XBundle currentXibBundleWithResourceName:@""] loadNibNamed:@"LotteryBetSubView1" owner:nil options:nil] lastObject];
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
    NSInteger numBet = [self.contentButton.titleLabel.text integerValue];
    NSInteger numNowBet = numBet+[number integerValue];
    [self.contentButton setTitle:[NSString stringWithFormat:@"%ld",numNowBet] forState:UIControlStateNormal];
    [self.betInfos addObject:@{@"way":ways,@"money":number}];
    self.isHiddenTopView = false;
}

-(void)updateMineNumb:(NSInteger)mine
{
    [self.contentButton setTitle:[NSString stringWithFormat:@"%ld",mine] forState:UIControlStateNormal];
    self.isHiddenTopView = YES;
}

-(void)sureBetView
{
    [_betInfos removeAllObjects];
}
-(void)clearBetView
{
    NSInteger numberShow = [self.contentButton.titleLabel.text integerValue];
    for (NSDictionary *subDic in self.betInfos) {
        NSInteger numberBet = [[subDic objectForKey:@"money"] integerValue];
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
