//
//  LanguageCell.h
//  phonelive2
//
//  Created by 400 on 2021/8/16.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LanguageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedButton;

@end

NS_ASSUME_NONNULL_END
