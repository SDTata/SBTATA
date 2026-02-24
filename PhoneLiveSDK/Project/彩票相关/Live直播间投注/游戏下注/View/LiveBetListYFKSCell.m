//
//  LiveBetListYFKSCell.m
//  phonelive2
//
//  Created by lucas on 10/7/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import "LiveBetListYFKSCell.h"

@implementation LiveBetListYFKSCell

+ (NSInteger)itemCount {
    return 1;
}

+ (CGFloat)itemHeight {
    return 36;
}

- (void)updateData {
    self.model = self.itemModel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.betBtn vk_addTapAction:self selector:@selector(clickBetAction)];
    [self.betBtn setTitle:YZMsg(@"game_continue_bet") forState:UIControlStateNormal];
    self.betBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.betBtn.titleLabel.minimumScaleFactor = 0.1;
}

- (void)setModel:(BetListDataModel *)model{
    _model = model;
    if (model.issue != nil && model.issue.length>0) {
        self.issueLab.text = [NSString stringWithFormat:@"%@",model.issue];
    }else{
        self.issueLab.text = @"";
    }
    if([model.state integerValue] == 0 && (model.total_profit==nil || [model.total_profit integerValue] == 0 )){
        self.winLab.text = [NSString stringWithFormat:@"- %@", [YBToolClass getRateCurrency:model.total_money showUnit:YES]];
        self.loseLab.text = YZMsg(@"history_statewillaward");
    }else{
        self.winLab.text = [NSString stringWithFormat:@"- %@", [YBToolClass getRateCurrency:model.total_money showUnit:YES]];
        self.loseLab.text =  [NSString stringWithFormat:@"+ %@", [YBToolClass getRateCurrency:model.total_profit showUnit:YES]];
    }
}

- (void)clickBetAction {
    if (self.clickBetBlock) {
        self.clickBetBlock(self.model);
    }
    if (self.clickCellActionBlock) {
        self.clickCellActionBlock(self.indexPath, self.model, 0);
    }
}

@end
