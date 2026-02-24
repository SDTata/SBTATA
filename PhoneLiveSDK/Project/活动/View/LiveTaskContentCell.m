//
//  TaskContentCell.m
//  phonelive
//
//  Created by 400 on 2020/9/21.
//  Copyright © 2020 toby. All rights reserved.
//

#import "LiveTaskContentCell.h"
@interface LiveTaskContentCell()
{
    NSInteger noFinishTaskType;
}
@end

@implementation LiveTaskContentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.downButton.layer.cornerRadius = 15;
    self.downButton.layer.masksToBounds = YES;
    self.downButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.downButton.titleLabel.minimumScaleFactor = 0.3;
    self.bgView.layer.cornerRadius = 8;
    self.bgView.layer.masksToBounds = YES;
    
    // Initialization code
}
-(void)setModel:(LiveTaskModel *)model
{
    _model = model;
    if (_model.title && [_model.title isKindOfClass:[NSString class]] ) {
        self.titleLabel.text = _model.title;
    }
    if (_model.process && [_model.process isKindOfClass:[NSString class]] ) {
        self.subTitleLabel.text = _model.process;
    }
    
    if ([_model.can_get intValue] < 1) {
        self.downButton.backgroundColor = RGB(231, 160, 110);
        [self.downButton setTitle:YZMsg(@"taskgofinish") forState:UIControlStateNormal];
        self.downButton.userInteractionEnabled = YES;
    }else{
        if (model.completed) {
            self.downButton.backgroundColor = [UIColor lightGrayColor];
            [self.downButton setTitle:YZMsg(@"taskfinished") forState:UIControlStateNormal];
            self.downButton.userInteractionEnabled = NO;
        }else{
            self.downButton.backgroundColor = RGB(133, 187, 171);
            [self.downButton setTitle:YZMsg(@"tasktoget") forState:UIControlStateNormal];
            self.downButton.userInteractionEnabled = YES;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonAction:(id)sender {
    if ([_model.can_get intValue] < 1) {
        if (self.taskCallback) {
            self.taskCallback(noFinishTaskType);
        }
    }else{
        [self requestReward];
    }
}
-(void)requestReward
{
    NSString *userBaseUrl = [NSString stringWithFormat:@"User.getLiveTaskReward&uid=%@&token=%@",[Config getOwnID],[Config getOwnToken]];
    NSDictionary *paramDic = @{@"id":@(_model.ID),@"type":_model.task_type};
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.bgView animated:YES];
    WeakSelf
    [[YBNetworking sharedManager] postNetworkWithUrl:userBaseUrl withBaseDomian:YES andParameter:paramDic data:nil success:^(int code, id  _Nonnull info, NSString * _Nonnull msg) {
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        [hud hideAnimated:YES];
        if(code == 0)
        {
            strongSelf.model.completed = 1;
            [strongSelf setModel:strongSelf.model];
        }else{
            [MBProgressHUD showError:msg];
        }
    } fail:^(NSError * _Nonnull error) {
        
        [hud hideAnimated:YES];
    }];
}
@end
