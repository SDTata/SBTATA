//
//  chatMsgCell.m
//  yunbaolive
//
//  Created by Boom on 2018/10/8.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "chatCenterMsgCell.h"
#import "SDWebImageManager.h"
@implementation chatCenterMsgCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.chatLabel.textContainer.lineFragmentPadding = 0;
    self.chatLabel.textContainerInset = UIEdgeInsetsZero;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCenterModel:(chatCenterModel *)centerModel{
    _centerModel = centerModel;
    self.chatLabel.delegate = self;
    self.chatLabel.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
    self.chatLabel.scrollEnabled = NO;
    [self.chatLabel setAttributedText:_centerModel.textAttribute];
    self.chatLabel.userInteractionEnabled = false;
    self.chatLabel.selectable = NO;

}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"fanyi"]) {
        if (self.translateBlock) {
            self.translateBlock(self.model,NO);
        }
        return NO;
    }else{
        if (self.translateBlock) {
            self.translateBlock(self.model,YES);
        }
        return NO;
    }
    return YES;
}

@end
