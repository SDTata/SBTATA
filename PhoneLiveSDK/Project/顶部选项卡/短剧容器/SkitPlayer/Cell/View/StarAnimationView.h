//
//  StarAnimationView.h
//  phonelive2
//
//  Created by s5346 on 2024/7/12.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StarAnimationView : UIView
@property (nonatomic, copy) void (^tapStarblock)(BOOL);

- (BOOL)isStar;
- (void)star:(BOOL)isStar;
@end

NS_ASSUME_NONNULL_END
