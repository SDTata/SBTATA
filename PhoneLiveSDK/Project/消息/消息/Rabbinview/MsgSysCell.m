//
//  MsgSysCell.m
//  iphoneLive
//
//  Created by YunBao on 2018/8/3.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "MsgSysCell.h"

@implementation MsgSysCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

+(MsgSysCell*)cellWithTab:(UITableView *)tableView andIndexPath:(NSIndexPath*)indexPath {
    MsgSysCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MsgSysCell"];
    if (!cell) {
        cell = [[[XBundle currentXibBundleWithResourceName:@"MsgSysCell"]loadNibNamed:@"MsgSysCell" owner:nil options:nil]objectAtIndex:0];
    }
    return cell;
}

- (void)setModel:(SystemMsgModel *)model {
    _model = model;
    
    _iconIV.image = [PublicObj getAppIcon];
    _unreadView.hidden = model.isRead;
    
    self.contentView.backgroundColor = model.isRead ? vkColorHex(0xFFFFFF) : vkColorHex(0xF5F5F5);
    
//    [_iconIV sd_setImageWithURL:[NSURL URLWithString:_model.iconStr]];
    _titleL.text = YZMsg(@"MsgSysVC_systemMsg");
//    [_flagIV setImage:[ImageBundle imagewithBundleName:@"msg_gov"]];
//    if ([_model.uidStr isEqual:@"dsp_admin_1"]) {
//        _briefL.text = _model.briefStr;
//    }else{
        _briefL.text = _model.content;
//    }
    _timeL.text = _model.addtime;
    
}

@end
