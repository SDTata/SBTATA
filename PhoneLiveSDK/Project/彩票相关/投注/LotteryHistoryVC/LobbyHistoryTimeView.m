//
//  LobbyHistoryTimeView.m
//  phonelive2
//
//  Created by test on 2021/7/10.
//  Copyright © 2021 toby. All rights reserved.
//

#import "LobbyHistoryTimeView.h"
#import "BRDatePickerView.h"
@interface LobbyHistoryTimeView()
{
    NSDate *_defaultStart;
    NSDate *_defaultEnd;
    NSDate *_startDate;
    NSString *_startValue;
    NSDate *_endDate;
    NSString *_endValue;
}
@property (weak, nonatomic) IBOutlet UILabel *lb_start;
@property (weak, nonatomic) IBOutlet UILabel *lb_end;
@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet UIButton *btn_cancel;
@property (weak, nonatomic) IBOutlet UIButton *btn_sure;
@property (weak, nonatomic) IBOutlet UIView *alert;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layout_bottomMargin;
@property (weak, nonatomic) IBOutlet UIView *v_topTime;
@property (weak, nonatomic) IBOutlet UIView *v_bottomTime;
@end

@implementation LobbyHistoryTimeView

- (void)initTimeViewWithStartTime:(NSDate *)start andEndTime:(NSDate *)end{
    BRDatePickerView *startPickerView = [[BRDatePickerView alloc]init];
    startPickerView.pickerMode = BRDatePickerModeYMD;
    //startPickerView.title = @"请选择月日";
    startPickerView.selectDate = start;
    startPickerView.minDate = [NSDate br_getNewDate:[NSDate date] addDays:-7];
    startPickerView.maxDate = [NSDate date];
    startPickerView.isAutoSelect = YES;
    //datePickerView.addToNow = YES;
    //datePickerView.showToday = YES;
    //datePickerView.showWeek = YES;
    startPickerView.showUnitType = BRShowUnitTypeNone;
    WeakSelf
    startPickerView.resultBlock = ^(NSDate *selectDate, NSString *selectValue) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->_startDate = selectDate;
        strongSelf->_startValue = selectValue;
    };
    [startPickerView addPickerToView:self.v_topTime];
    BRDatePickerView *endPickerView = [[BRDatePickerView alloc]init];
    endPickerView.pickerMode = BRDatePickerModeYMD;
    //startPickerView.title = @"请选择月日";
    endPickerView.selectDate = end;
    endPickerView.minDate = [NSDate br_getNewDate:[NSDate date] addDays:-7];
    endPickerView.maxDate = [NSDate date];
    endPickerView.isAutoSelect = YES;
    //datePickerView.addToNow = YES;
    //datePickerView.showToday = YES;
    //datePickerView.showWeek = YES;
    endPickerView.showUnitType = BRShowUnitTypeNone;
    endPickerView.resultBlock = ^(NSDate *selectDate, NSString *selectValue) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        strongSelf->_endDate = selectDate;
        strongSelf->_endValue = selectValue;
    };
    [endPickerView addPickerToView:self.v_bottomTime];
}

+ (instancetype)instanceStateAlertWithStartTime:(NSDate *)start andEndTime:(NSDate *)end{
    LobbyHistoryTimeView *alert = [[[XBundle currentXibBundleWithResourceName:@"LobbyHistoryTimeView"] loadNibNamed:@"LobbyHistoryTimeView" owner:nil options:nil] firstObject];
    alert->_defaultStart = start;
    alert->_defaultEnd = end;
    [alert.btn_cancel setTitle:YZMsg(@"public_cancel") forState:UIControlStateNormal];
    [alert.btn_sure setTitle:YZMsg(@"publictool_sure") forState:UIControlStateNormal];
    alert.lb_title.text = YZMsg(@"time_sel");
    alert.lb_start.text = YZMsg(@"history_starttime");
    alert.lb_end.text = YZMsg(@"history_endtime");
    [alert initTimeViewWithStartTime:start andEndTime:end];
    alert.frame = CGRectMake(0, 0, _window_width, _window_height);
    alert.layout_bottomMargin.constant = -416;
    [alert layoutIfNeeded];
    return alert;
}
- (void)alertShowAnimationWithSuperView:(UIView *)superView{
    self.frame = CGRectMake(0, 0, _window_width, _window_height);
    [superView addSubview:self];
    self.layout_bottomMargin.constant = 0;
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
    }];
}

-(void)dismissView
{
    //dismiss alert
    self.layout_bottomMargin.constant = -416;
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
- (IBAction)didClickSure:(UIButton *)sender {
    if (self.completeHandler) {
        if (! _startDate) {
             _startDate =  _defaultStart;
             _startValue = [NSDate br_getDateString: _defaultStart format:@"yyyy-MM-dd"];
        }
        if (! _endDate) {
             _endDate =  _defaultEnd;
             _endValue = [NSDate br_getDateString: _defaultEnd format:@"yyyy-MM-dd"];
        }
        self.completeHandler( _startDate,  _startValue, _endDate, _endValue);
    }
    [self dismissView];
}

- (IBAction)didClickCancel:(UIButton *)sender {
    [self dismissView];
}

@end
