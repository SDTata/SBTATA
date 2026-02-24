//
//  BillTableViewCell.h
//  phonelive2
//
//  Created by 400 on 2021/6/26.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BillTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title1;
@property (weak, nonatomic) IBOutlet UILabel *subtitle1;
@property (weak, nonatomic) IBOutlet UILabel *title2;
@property (weak, nonatomic) IBOutlet UILabel *subtitle2;
@property (weak, nonatomic) IBOutlet UILabel *title3;
@property (weak, nonatomic) IBOutlet UILabel *subtitle3;

@property(nonatomic,strong)NSDictionary *dicContent;
@end

NS_ASSUME_NONNULL_END
