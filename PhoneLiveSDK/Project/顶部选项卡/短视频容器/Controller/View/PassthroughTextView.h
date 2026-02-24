//
//  PassthroughTextView.h
//  phonelive2
//
//  Created by s5346 on 2024/9/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PassthroughTextView : UITextView

@property(nonatomic, weak) UIView *underlyingView;

- (BOOL)isLinkAtPoint:(CGPoint)point;
- (NSUInteger)characterIndexAtPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
