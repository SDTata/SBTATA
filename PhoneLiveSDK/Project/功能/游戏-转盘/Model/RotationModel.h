//
//  RotationModel.h
//  phonelive2
//
//  Created by 400 on 2021/5/29.
//  Copyright © 2021 toby. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface RotationSubModel : NSObject

@property(nonatomic,strong)NSString *ID;

@property(nonatomic,strong)NSString *item_type;

@property(nonatomic,strong)NSString *item_name;

@property(nonatomic,strong)NSString *item_icon;

@property(nonatomic,strong)NSString *item_num;

@end

@interface RotationModel : NSObject
@property(nonatomic,strong)NSString *rule;
@property(nonatomic,strong)NSString *pool;
@property(nonatomic,strong)NSString *process_tip;

@property(nonatomic,assign)int left_times;
@property(nonatomic,strong)NSArray<RotationSubModel*> *reward;
@property(nonatomic,strong)NSArray *process_list;
@property(nonatomic,strong)NSString *reset_time;

@end


