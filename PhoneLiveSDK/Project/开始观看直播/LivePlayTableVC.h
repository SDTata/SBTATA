//
//  LivePlayTableVC.h
//  phonelive
//
//  Created by 400 on 2020/9/3.
//  Copyright © 2020 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hotModel.h"

#define LivePlayTableVCUpdateNotifcation @"LivePlayTableVCUpdateNotifcation"

#define LivePlayTableVCRequestDataNotifcation @"LivePlayTableVCRequestDataNotifcation"

#define LivePlayTableVCReleaseDatasNotifcation @"LivePlayTableVCReleaseDatasNotifcation"

#define LivePlayTableVCUpdateModelsNotifcation @"LivePlayTableVCUpdateModelsNotifcation"

#define LivePlayTableVCRemoveRoomIdNotifcation @"LivePlayTableVCRemoveRoomIdNotifcation"
#define LivePlayTableVCUpdateRemoveModelNotifcation @"LivePlayTableVCUpdateRemoveModelNotifcation"

@interface LivePlayTableVC : UITableViewController
//判断是否正在滚动
@property (nonatomic, assign) BOOL shouldTriggerDecelerating;

@property(nonatomic,strong)NSMutableArray<hotModel*> *datas;
@property(nonatomic,assign)NSInteger index;
@property(nonatomic,assign)BOOL testRemoveAlready;
@property(nonatomic,assign)NSString *removeRoomId;


@property (nonatomic ,assign) int isPreviewSecond;        //预览的秒数
@property (nonatomic ,assign) BOOL isFinishCoast;        //判断是否为7s预览
@end

