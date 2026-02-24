//
//  LotteryCenterMsgView.h
//  phonelive2
//
//  Created by lucas on 2022/6/25.
//  Copyright © 2022 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "chatCenterMsgCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface LotteryCenterMsgView : UIView

-(void)addMsgList:(chatCenterModel *)msg;

@end

NS_ASSUME_NONNULL_END
