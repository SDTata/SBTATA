//
//  YBUserInfoListTableViewCell.h
//  TCLVBIMDemo
//
//  Created by admin on 16/11/11.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  个人中心列表cell
 */
@interface YBUserInfoListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UIView *line;
@property (weak, nonatomic) IBOutlet UIImageView *rightImg;
@property (weak, nonatomic) IBOutlet UILabel *rightLab;

//+ (instancetype)cellWithTabelView:(UITableView *)tableView;

@end
