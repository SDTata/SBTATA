//
//  AttentionHeader.h
//  phonelive2
//
//  Created by test on 4/9/21.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AttentionHeader : UIView
- (instancetype)initWithSourceType:(NSInteger)sourceType noNetHandler:(void(^)(void))noNetHandler;
- (void)reloadDatas:(NSArray *)data;
@end

NS_ASSUME_NONNULL_END
