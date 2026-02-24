//
//  chatMsgCell.h
//  yunbaolive
//
//  Created by Boom on 2018/10/8.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "chatModel.h"
#import "chatCenterModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface chatCenterMsgCell : UITableViewCell<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *chatLabel;
@property(nonatomic,strong)chatModel *model;
@property (weak, nonatomic) IBOutlet UIView *chatView;
@property (nonatomic,copy) void(^translateBlock)(chatModel *chatModel,BOOL isPersonInfo);
@property(nonatomic,strong)chatCenterModel *centerModel;
@end

NS_ASSUME_NONNULL_END
