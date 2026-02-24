//
//  LobbyHistoryTypeView.m
//  phonelive2
//
//  Created by test on 2021/7/3.
//  Copyright © 2021 toby. All rights reserved.
//

#import "LobbyHistoryTypeView.h"
@interface LobbyHistoryTypeView(){
    NSInteger _state;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_bottomMargin;
@property (weak, nonatomic) IBOutlet UIView *alertView;
///事件容器
@property (weak, nonatomic) IBOutlet UIView *v_container;
@property (weak, nonatomic) IBOutlet UIButton *btn_cancel;
@property (weak, nonatomic) IBOutlet UILabel *lb_title;

@end

@implementation LobbyHistoryTypeView
+ (instancetype)instanceStateAlertWithSate:(NSInteger)state andInfoData:(nonnull NSArray<BetLotterysInfoModel *> *)lotteryInfo{
    LobbyHistoryTypeView *alert = [[[XBundle currentXibBundleWithResourceName:@"LobbyHistoryTypeView"] loadNibNamed:@"LobbyHistoryTypeView" owner:nil options:nil] firstObject];
    alert.frame = CGRectMake(0, 0, _window_width, _window_height);
    alert.layout_bottomMargin.constant = -300;
    [alert layoutIfNeeded];
    CGFloat buttonWidth = (_window_width - 40)/3.0;
    [alert initialActionBoard:buttonWidth andInfoData:lotteryInfo andSate:state];
    alert.lb_title.text = YZMsg(@"history_typetitle");
    [alert.btn_cancel setTitle:YZMsg(@"public_cancel") forState:UIControlStateNormal];
    alert->_state = state;
    return alert;
}

- (void)initialActionBoard:(CGFloat)width andInfoData:(nonnull NSArray<BetLotterysInfoModel *> *)lotteryInfo andSate:(NSInteger)state{
    NSMutableArray *mut_info = lotteryInfo.mutableCopy;
    BetLotterysInfoModel *all = [[BetLotterysInfoModel alloc] init];
    all.lname = YZMsg(@"all_type");
    all.lid = @"0";
    [mut_info insertObject:all atIndex:0];
    int idx = 0;
    CGFloat containerHeight = 234 - 30 - 22;
    NSInteger rowCount = ((mut_info.count) % 3 == 0)? mut_info.count / 3 : mut_info.count / 3 + 1;
    CGFloat height = (containerHeight - (rowCount + 1) * 10)/rowCount;
    for (BetLotterysInfoModel *model in mut_info) {
        NSInteger row = idx/3;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10 + (idx % 3) * 10 + width * (idx % 3), 10 + row * height + 10 * row, width, height);
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.titleLabel.minimumScaleFactor = 0.5;
        [btn setTitleColor:[[UIColor blackColor]colorWithAlphaComponent:0.85] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(actionEventButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = model.lid.integerValue + 1000;
        [btn setTitle:model.lname forState:UIControlStateNormal];
        if (state == model.lid.integerValue) {
            [self actionStateChangedWithAction:btn andSate:YES];
        }else{
            [self actionStateChangedWithAction:btn andSate:NO];
        }
        [self.v_container addSubview:btn];
        idx++;
    }
}

- (void)actionEventButtonClick:(UIButton *)sender{
    [self buttonEventUIChange:sender];
    if (sender.selected && self.completeHandler) {
        self.completeHandler(sender);
        [self dismissView];
    }
}

- (void)actionStateChangedWithAction:(UIButton *)action andSate:(BOOL)selected{
    if(selected == YES){
        action.selected = YES;
        action.backgroundColor = RGB(216, 30, 7);
    }else{
        action.selected = NO;
         action.backgroundColor = [UIColor whiteColor];
    }
}

- (void)alertShowAnimationWithSuperView:(UIView *)superView{
    self.frame = CGRectMake(0, 0, _window_width, _window_height);
    [superView addSubview:self];
    self.layout_bottomMargin.constant = 0;
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
    }];
}

- (IBAction)cancel:(UIButton *)sender {
    //取消
    [self dismissView];
}

- (void)buttonEventUIChange:(UIButton *)sender{
    for (UIView *itemView in self.alertView.subviews) {
        if ([itemView isKindOfClass:[UIButton class]]) {
            UIButton *item = (UIButton *)itemView;
            if (![item.titleLabel.text isEqualToString:YZMsg(@"public_cancel")]) {
                [self actionStateChangedWithAction:item andSate:NO];
            }
        }
    }
    sender.selected = !sender.isSelected;
    [self actionStateChangedWithAction:sender andSate:sender.selected];
}

-(void)dismissView
{
    //dismiss alert
    self.layout_bottomMargin.constant = -300;
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor clearColor];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.cancelHandler) {
            self.cancelHandler();
        }
    }];
}
@end
