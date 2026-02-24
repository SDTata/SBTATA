//
//  popWebH5.h
//  yunbaolive
//
//  Created by zqm on 16/5/16.
//  Copyright © 2016年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^Callback)(void);
@interface popWebH5 : UIViewController

@property(nonatomic,copy)NSString *isjingpai;//判断是不是竞拍，是的话返回的时候刷新钻石s
@property(nonatomic,strong)NSString *urls;
@property(nonatomic,strong)NSString *titles;

@property(nonatomic,assign)CGFloat hightRate;

@property(nonatomic,strong)UIButton *returnBtn;
@property(nonatomic,assign)BOOL bHiddenReturnBtn;
@property(nonatomic,assign)BOOL bAllJump;
@property(nonatomic,assign)BOOL bLoadedOnce;
@property (nonatomic,copy) Callback closeCallback;

@property(nonatomic,assign) BOOL isBetExplain;
@property(nonatomic,assign) BOOL isPresent;

-(void)doCloseWeb;
@end
