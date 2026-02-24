//
//  AddUSDTInfoCell.h
//  phonelive2
//
//  Created by test on 2022/1/17.
//  Copyright © 2022 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AddUSDTInfoCell;
@protocol AddUSDTInfoCell <NSObject>
- (void)doPasteCall:(AddUSDTInfoCell *)cell;
@end
@interface AddUSDTInfoCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeHolder;
@property (nonatomic, strong) UIButton *btn_paste;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, assign) BOOL canEdit;
@property (nonatomic, weak) id<AddUSDTInfoCell>delegate;
@end

