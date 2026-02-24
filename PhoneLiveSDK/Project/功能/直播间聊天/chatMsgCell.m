//
//  chatMsgCell.m
//  yunbaolive
//
//  Created by Boom on 2018/10/8.
//  Copyright © 2018年 cat. All rights reserved.
//

#import "chatMsgCell.h"
#import "SDWebImageManager.h"
@implementation chatMsgCell

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
-(void)setModel:(chatModel *)model{
    _model = model;
//    _chatLabel.text = _model.textString;
//    _chatLabel.font = [UIFont systemFontOfSize:13];
    //入场消息 开播警告
//    if (![PublicObj checkNull:_model.titleColor] && [_model.titleColor isEqualToString:@"firstlogin"]) {
//        self.chatView.backgroundColor = RGB_COLOR(@"#000000", 0.3);
//        _chatLabel.textColor = normalColors;
//    }else if(![PublicObj checkNull:_model.titleColor] && ([_model.titleColor isEqualToString:@"kygame"]||[_model.titleColor isEqualToString:@"platgame"])){
//        self.chatView.backgroundColor = RGB_COLOR(@"#000000", 0.4);
//        
//    }else if(![PublicObj checkNull:_model.titleColor] && [_model.titleColor isEqualToString:@"lotteryBet"]){
//        self.chatView.backgroundColor = RGB_COLOR(@"#000000", 0.4);
//    }else if(![PublicObj checkNull:_model.titleColor] && [_model.titleColor isEqualToString:@"lotteryProfit"]){
//        self.chatView.backgroundColor = RGB_COLOR(@"#000000", 0.4);
//    }else if(![PublicObj checkNull:_model.titleColor] && [_model.titleColor isEqualToString:@"lotteryDividend"]){
//        self.chatView.backgroundColor = RGB_COLOR(@"#000000", 0.4);
//    }else if (![PublicObj checkNull:_model.titleColor] && [_model.titleColor isEqualToString:@"redbag"]){
//        _chatLabel.textColor = [UIColor whiteColor];
//        _chatLabel.font = [UIFont boldSystemFontOfSize:13];
//        self.chatView.backgroundColor = RGB_COLOR(@"#f7501d", 0.9);
//    }else{
//        self.chatView.backgroundColor = RGB_COLOR(@"#000000", 0.3);
//        if ([_model.titleColor isEqual:@"userLogin"]){
//            self.chatLabel.textColor = RGB_COLOR(@"#c7c9c7", 1);
//        }else{
//            self.chatLabel.textColor = [UIColor whiteColor];
//        }
//        
//        if (_model.titleColor && [_model.titleColor isEqualToString:@"2"])//礼物
//        {
//            self.chatLabel.textColor = RGB_COLOR(@"#f5cb2f", 1);
//            
//            
//        }
//        else if (_model.titleColor && [_model.titleColor isEqualToString:@"light0"])//青蛙
//        {
//            self.chatLabel.textColor = RGB_COLOR(@"#c7c9c7", 1);
//        }
//        else if (_model.titleColor && [_model.titleColor isEqualToString:@"light1"])//猴子
//        {
//            self.chatLabel.textColor = RGB_COLOR(@"#c7c9c7", 1);
//        }
//        else if (_model.titleColor && [_model.titleColor isEqualToString:@"light2"])//小红花
//        {
//            self.chatLabel.textColor = RGB_COLOR(@"#c7c9c7", 1);
//        }
//        else if (_model.titleColor && [_model.titleColor isEqualToString:@"light3"])//小黄花
//        {
//            self.chatLabel.textColor = RGB_COLOR(@"#c7c9c7", 1);
//        }
//        else if (_model.titleColor && [_model.titleColor isEqualToString:@"light4"])//心
//        {
//            self.chatLabel.textColor = RGB_COLOR(@"#c7c9c7", 1);
//        }
//    }
    self.chatLabel.delegate = self;
    self.chatLabel.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
    self.chatLabel.scrollEnabled = NO;
    [self.chatLabel setAttributedText:_model.textAttribute];
    if(_model.isTranslate){
        self.chatLabel.userInteractionEnabled = true;
        self.chatLabel.selectable = YES;
        self.chatLabel.linkTextAttributes  = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    }else{
        self.chatLabel.userInteractionEnabled = false;
        self.chatLabel.selectable = NO;
    }

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
