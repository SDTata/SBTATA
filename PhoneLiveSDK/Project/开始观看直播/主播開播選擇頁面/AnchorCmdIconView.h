//
//  AnchorCmdIconView.h
//  phonelive2
//
//  Created by vick on 2025/7/31.
//  Copyright © 2025 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnchorCmdIconView : UIView

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;

- (void)setName:(NSString *)name icon:(NSString *)icon;

@end
