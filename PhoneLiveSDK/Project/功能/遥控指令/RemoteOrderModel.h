//
//  RemoteOrderModel.h
//  phonelive2
//
//  Created by s5346 on 2023/12/14.
//  Copyright © 2023 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RemoteOrderModel : NSObject

@property(nonatomic,copy)NSString *imagePath;
@property(nonatomic,copy)NSString *giftname;
@property(nonatomic,copy)NSString *ID;
@property(nonatomic,copy)NSString *mark;//0: 不显示 1:热门 2:守护
@property(nonatomic,copy)NSString *price;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,copy)NSString *shocktime;
@property(nonatomic,copy)NSString *shocktype;
@property(nonatomic,copy)NSString *cmdType;//0:系统指令，1:自定义指令
@property(nonatomic,assign)BOOL selected;
@property(nonatomic,assign)BOOL isAdd;

+(instancetype)modelWithDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
