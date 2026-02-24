//
//  guardShowView.h
//  yunbaolive
//
//  Created by Boom on 2018/11/12.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LivePlayNOScrollView.h"
@protocol guardShowDelegate <NSObject>
- (void)buyOrRenewGuard;
- (void)removeShouhuView;
@end
NS_ASSUME_NONNULL_BEGIN

@interface guardShowView : LivePlayNOScrollView<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,assign)id<guardShowDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame andUserGuardMsg:(nullable NSDictionary * )dic andLiveUid:(NSString *)uid;
- (void)show;
@end

NS_ASSUME_NONNULL_END
