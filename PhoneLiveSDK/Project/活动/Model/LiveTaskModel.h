//
//  LiveTaskModel.h
//  phonelive2
//
//  Created by lucas on 2021/11/5.
//  Copyright © 2021 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveTaskModel : NSObject
@property(nonatomic,assign)NSInteger ID;
@property(nonatomic,strong)NSString *task_type;
@property(nonatomic,strong)NSString *reward;
@property(nonatomic,strong)NSString *can_get;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *group;
@property(nonatomic,strong)NSString *process;
@property(nonatomic,assign)NSInteger completed;


@end

NS_ASSUME_NONNULL_END
