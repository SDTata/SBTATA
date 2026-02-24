//
//  LotteryChipSubView.h
//  phonelive2
//
//  Created by vick on 2023/12/9.
//  Copyright © 2023 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LotteryChipSubView : UIImageView

@property (nonatomic, copy) NSString *money;

@property (nonatomic, assign) BOOL selected;

// 是否为自定义筹码
@property(nonatomic,assign)BOOL isEdit;
@end
