//
//  BonusRulesViewController.h
//  phonelive2
//
//  Created by user on 2024/8/24.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BonusRulesViewController : VKPagerVC
// isBounsRules 與 htmlCode 選擇一種，htmlCode 有值則優先
@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSString *htmlCode;
@end

NS_ASSUME_NONNULL_END
