//
//  AnchorCardEditAlertView.h
//  phonelive2
//
//  Created by vick on 2025/7/23.
//  Copyright © 2025 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnchorCardEditAlertCell : VKBaseTableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *tickButton;
@end


@interface AnchorCardEditAlertView : UIView

@property (nonatomic, copy) void (^selectPriceBlock)(NSInteger index, NSString *title);

@end
