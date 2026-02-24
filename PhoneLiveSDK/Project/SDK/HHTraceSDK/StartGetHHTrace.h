//
//  StartGetHHTrace.h
//  HHTraceSDK
//
//  Created by 400 on 2021/6/26.
//

#import <Foundation/Foundation.h>
#import "HHTraceData.h"
NS_ASSUME_NONNULL_BEGIN

@interface StartGetHHTrace : NSObject
@property(nonatomic,strong)NSString *tidCopy;
+ (StartGetHHTrace *)shareInstance;

@property(nonatomic,strong)NSString *deviceID;

+ (StartGetHHTrace *)shareInstance;

//保存tid
-(NSString*)getTraceIDStr;
-(void)setTraceIDStr:(NSString*)traceIDStr;

//看是否首次安装
-(BOOL)getisAppInstalled;
-(void)setisAppInstalled:(BOOL)isInstalled;



//获取渠道
+ (void)getInstallTrace:(void (^ _Nullable)(HHTraceData * _Nullable traceData))success :(void (^ _Nullable)(NSString * _Nonnull failString))fail;




@end

NS_ASSUME_NONNULL_END
