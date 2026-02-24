//
//  SystemMsgModel.h
//  phonelive2
//
//  Created by 400 on 2021/5/30.
//  Copyright © 2021 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemMsgModel : NSObject
@property(nonatomic,strong)NSString *addtime;
@property(nonatomic,strong)NSString *content;
@property(nonatomic,assign)BOOL isRead;
@end
