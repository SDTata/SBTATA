//
//  ContactEditInfoCell.m
//  phonelive2
//
//  Created by test on 2021/12/14.
//  Copyright © 2021 toby. All rights reserved.
//

#import "ContactEditInfoCell.h"
#import "UIImageView+WebCache.h"
@interface ContactEditInfoCell()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iv_logo;
@property (weak, nonatomic) IBOutlet UILabel *lb_name;
@property (weak, nonatomic) IBOutlet UITextField *tf_input;

@end

@implementation ContactEditInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.tf_input.placeholder = YZMsg(@"EditContactInfo_Empty");
    [self.tf_input addTarget:self action:@selector(didChangeText:) forControlEvents:UIControlEventEditingChanged];
}
- (void)setApp:(LiveAppItem *)app{
    _app = app;
    if (![PublicObj checkNull:app.app_logo]) {
        NSURL *urlImg = [NSURL URLWithString:app.app_logo];
        if (urlImg!= nil) {
            [self.iv_logo sd_setImageWithURL:urlImg];
        }else{
            self.iv_logo.image = nil;
        }
    }else{
        self.iv_logo.image = nil;
    }
    
    self.lb_name.text = app.app_name;
    self.tf_input.text = app.info;
}
- (void)didChangeText:(UITextField *)sender
{
    _app.info = self.tf_input.text;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
