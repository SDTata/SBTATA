//
//  LiveBetListYFKSCell.h
//  phonelive2
//
//  Created by lucas on 10/7/23.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BetListModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveBetListYFKSCell : VKBaseCollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *issueLab;
@property (weak, nonatomic) IBOutlet UILabel *winLab;
@property (weak, nonatomic) IBOutlet UILabel *loseLab;
@property (weak, nonatomic) IBOutlet UIButton *betBtn;

@property (strong, nonatomic) BetListDataModel *model;

@property (copy, nonatomic) void (^clickBetBlock)(BetListDataModel *model);

@end

NS_ASSUME_NONNULL_END
