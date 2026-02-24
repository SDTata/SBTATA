//
//  BetBubbleView.h
//  phonelive2
//
//  Created by test on 2022/4/28.
//  Copyright © 2022 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BetBubbleView : UIView
@property(nonatomic,strong)NSString *betNum;
- (void)setBetCount:(NSString *)betCount;
@end

NS_ASSUME_NONNULL_END
