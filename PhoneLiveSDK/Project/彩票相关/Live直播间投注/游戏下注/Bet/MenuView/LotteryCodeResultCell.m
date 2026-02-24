//
//  LotteryCodeResultCell.m
//  phonelive2
//
//  Created by vick on 2023/12/7.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LotteryCodeResultCell.h"
#import "LotteryCodeResultView_LH.h"
#import "LotteryCodeResultView_ZJH.h"
#import "LotteryCodeResultView_BJL.h"

@implementation LotteryCodeResultCell

- (LotteryCodeView_Base *)codeView {
    if (!_codeView) {
        switch (BetType(self.resultModel.lotteryType)) {
            case LotteryBetTypeLH:
                _codeView = [LotteryCodeResultView_LH new];
                break;
            case LotteryBetTypeZJH:
                _codeView = [LotteryCodeResultView_ZJH new];
                break;
            case LotteryBetTypeBJL:
                _codeView = [LotteryCodeResultView_BJL new];
                break;
            default:
                _codeView = [LotteryCodeView_Base createWithType:self.resultModel.lotteryType];
                break;
        }
        [self.contentView addSubview:_codeView];
        [_codeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(-0);
            make.right.mas_equalTo(-10);
        }];
    }
    return _codeView;
}

- (void)updateView {
    UILabel *numberLabel = [UIView vk_label:nil font:vkFontBold(11) color:UIColor.whiteColor];
    [self.contentView addSubview:numberLabel];
    self.numberLabel = numberLabel;
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(0);
    }];
}

- (void)updateData {
    self.resultModel = self.itemModel;
    self.numberLabel.text = [NSString stringWithFormat:YZMsg(@"OpenHistory_DateNow%@"), self.resultModel.issue];
    self.codeView.resultModel = self.resultModel;
}

@end
