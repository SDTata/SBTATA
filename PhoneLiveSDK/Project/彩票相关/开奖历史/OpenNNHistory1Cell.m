//
//  OpenNNHistoryCell.m
//  phonelive
//
//  Created by 400 on 2020/8/7.
//  Copyright © 2020 toby. All rights reserved.
//

#import "OpenNNHistory1Cell.h"
@interface OpenNNHistory1Cell()
@property (weak, nonatomic) IBOutlet UILabel *openTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftWinImgView;
@property (weak, nonatomic) IBOutlet UIImageView *rightWinImgView;
@property (weak, nonatomic) IBOutlet UILabel *leftNLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightNNLabel;
@property (weak, nonatomic) IBOutlet UIStackView *leftStackView;
@property (weak, nonatomic) IBOutlet UIStackView *rightStackView;
@property (weak, nonatomic) IBOutlet UILabel *nnLeftBlueLabel;
@property (weak, nonatomic) IBOutlet UILabel *nnrightRedLabel;

@end
@implementation OpenNNHistory1Cell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self = [[XBundle currentXibBundleWithResourceName:@"OpenNNHistory1Cell"]loadNibNamed:@"OpenNNHistory1Cell" owner:self options:nil].lastObject;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nnLeftBlueLabel.text = YZMsg(@"OpenAward_NiuNiu_Blue");
    self.nnrightRedLabel.text = YZMsg(@"OpenAward_NiuNiu_Red");
    // Initialization code
    self.rightWinImgView.image = [ImageBundle imagewithBundleName:YZMsg(@"OpenAwardVC_RightWin")];
    self.leftWinImgView.image =  [ImageBundle imagewithBundleName:YZMsg(@"OpenAwardVC_LeftWin")];
}

-(void)setModel:(lastResultModel *)model
{
    _model = model;
    _openTimeLabel.text = [NSString stringWithFormat:YZMsg(@"OpenHistory_DateNow"), model.issue];
    _leftWinImgView.hidden = model.who_win == 1;
    _rightWinImgView.hidden   = model.who_win == 0;
    _leftNLabel.text = model.vs.blue.niu;
    _rightNNLabel.text = model.vs.red.niu;
    
    for (int i = 0; i<_leftStackView.arrangedSubviews.count; i++) {
        if ([_leftStackView.arrangedSubviews[i] isKindOfClass:[UIImageView class]]) {
            UIImageView *imgV = _leftStackView.arrangedSubviews[i];
            NSString *imgName = [PublicObj getPokerNameBy:model.vs.blue.pai[i]];
            [imgV setImage:[ImageBundle imagewithBundleName:imgName]];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
    for (int i = 0; i<_rightStackView.arrangedSubviews.count; i++) {
        if ([_rightStackView.arrangedSubviews[i] isKindOfClass:[UIImageView class]]) {
            UIImageView *imgV = _rightStackView.arrangedSubviews[i];
            NSString *imgName = [PublicObj getPokerNameBy:model.vs.red.pai[i]];
            [imgV setImage:[ImageBundle imagewithBundleName:imgName]];
            imgV.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
    
}
@end
