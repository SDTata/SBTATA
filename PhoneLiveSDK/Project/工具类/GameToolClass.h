//
//  GameToolClass.h
//  yunbaolive
//
//  Created by Boom on 2018/9/19.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^successBlock)(int code,id info,NSString *msg);
typedef void (^failBlock)(void);
@interface GameToolClass : NSObject
/**
 单例类方法
 
 @return 返回一个共享对象
 */
+ (instancetype)sharedInstance;

/**
 成功的回调
 */
@property(nonatomic,copy)successBlock successB;
/**
 失败的回调
 */
@property(nonatomic,copy)failBlock failB;

/**
 请求进入游戏
 */
+ (void) enterGame:(NSString *)plat menueName:(NSString*)nameLottery kindID:(NSString *)kindID iconUrlName:(NSString*)urlName parentViewController:(nullable UIViewController *)view autoExchange:(BOOL)autoExchange success:(successBlock)successBlock fail:(failBlock)failBlock;

+ (void)enterVideoH5Game:(NSString *)plat menueName:(NSString*)nameLottery kindID:(NSString *)kindID iconUrlName:(NSString*)urlName parentViewController:(nullable UIViewController *)view autoExchange:(BOOL)autoExchange success:(successBlock)successBlock fail:(failBlock)failBlock;
+ (void)enterHomeH5Game:(NSString *)plat menueName:(NSString *)nameLottery kindID:(NSString *)kindID iconUrlName:(NSString *)urlName autoExchange:(BOOL)autoExchange success:(successBlock)successBlock fail:(failBlock)failBlock finishBlock:(void(^)(NSString *url, BOOL bKYorLC))finishBlock;
+ (void) showTip:(NSString *)title tipString:(NSString *)tipString;
+ (void) goH5:(NSString *)url bKYorLC:(BOOL) bKYorLC viewController:(UIViewController*)parentVC;
+ (void) backAllCoin:(successBlock)successBlock fail:(failBlock)failBlock;
+ (void) setCurOpenedLotteryType:(NSInteger)lotteryType;
+ (NSInteger) getCurOpenedLotteryType;
+ (void)setCurGameCenterDefaultType:(NSString *)defaultType;
+ (NSString *)getCurGameCenterDefaultType;

+ (BOOL) isLHC:(NSInteger)lotteryType;
+ (BOOL) isKS:(NSInteger)lotteryType;
+ (BOOL) isSSC:(NSInteger)lotteryType;
+ (BOOL) isSC:(NSInteger)lotteryType;
@end

NS_ASSUME_NONNULL_END
