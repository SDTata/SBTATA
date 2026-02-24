//
//  LiveContactView.h
//  phonelive2
//
//  Created by test on 2021/5/27.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hotModel.h"
NS_ASSUME_NONNULL_BEGIN
@class LiveContactView;
@protocol LiveContactView <NSObject>
- (void)contactViewSendDoLiwuMessage:(LiveContactView *)view;
@end
@interface LiveContactView : UIView
@property(nonatomic,weak)id<LiveContactView>delegate;
+ (LiveContactView *)showContactWithAnimationAddto:(UIView *)superView liver:(hotModel *)liver setDelegate:(id<LiveContactView>)delegate;
@end

NS_ASSUME_NONNULL_END
