//
//  LiveActivityView.h
//  yunbaolive
//
//  Created by Mac on 2020/7/22.
//  Copyright © 2020 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@class LiveActivityButton;
typedef void(^ActivityClickBlock)(NSString *tag,LiveActivityButton *sender);
@interface LiveActivityButton : UIView
@property (nonatomic, strong) NSString *linkString;
@property (nonatomic, strong) NSString *tagString;
- (void)setButtonImageWithUrl:(NSString *)imageUrl forState:(UIControlState)state;
- (void)setButtonImageWithUrl:(NSString *)imageUrl placeholderImage:(UIImage *)placeholderImage forState:(UIControlState)state;
- (void)setButtonImage:(UIImage *)image forState:(UIControlState)state fromNetwork:(BOOL)isFromNetwork;
- (void)setButtonImage:(UIImage *)image forState:(UIControlState)state;
- (void)setTitle:(NSString *)title forState:(UIControlState)state;
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state;
- (void)setTargetClick:(ActivityClickBlock)activityActionBlock;
- (void)selected:(BOOL)selected;
- (BOOL)isSelected;
- (NSString*)getTitle;
- (UIImage*)getSelectImage;
- (CGRect)getIconFrame;
@end

NS_ASSUME_NONNULL_END
