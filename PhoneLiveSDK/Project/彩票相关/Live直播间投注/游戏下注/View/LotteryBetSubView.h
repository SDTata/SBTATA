//
//  LotteryBetSubView.h
//  phonelive2
//
//  Created by 400 on 2022/6/18.
//  Copyright © 2022 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^LotteryBetBlock)(BOOL sure);

@interface LotteryBetSubView : UIView
@property(nonatomic,strong)NSMutableArray *betInfos;
@property(nonatomic,assign)BOOL isHiddenTopView;

//初始化
+ (instancetype)instanceLotteryBetSubViewwWithFrame:(CGRect)frame contentEdge:(float)bottom withBlock:(LotteryBetBlock)block;

//下注
-(void)addBetNum:(NSString*)number ways:(NSString*)ways;

//更新显示
-(void)updateMineNumb:(double)mine;

//网络请求成功
-(void)sureBetView;

//取消选择
-(void)clearBetView;
@end

NS_ASSUME_NONNULL_END
