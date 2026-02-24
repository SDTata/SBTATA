//
//  ExpandCommentVideoView.h
//  phonelive2
//
//  Created by s5346 on 2025/2/17.
//  Copyright © 2025 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExpandCommentVideoView : UIView

@property (nonatomic, strong) UIImageView *coverImageView;

- (void)showBlueIfNeed:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
