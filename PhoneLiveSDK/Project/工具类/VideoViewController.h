//
//  VideoViewController.h
//  phonelive
//
//  Created by 400 on 2020/8/4.
//  Copyright © 2020 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
//视频播放时的窗口属性enum
enum ScalingMode {
  resize,
  resizeAspect,
  resizeAspectFill  //默认推荐这个属性
};

@interface VideoViewController : UIViewController

@property (nonatomic,strong) NSURL * contentURL ; //视频文件地址
@property (nonatomic,assign) CGRect videoFrame ; //播放器的frame
@property (nonatomic,assign) CGFloat startTime ; //视频开始时间
@property (nonatomic,assign) CGFloat duration ; //循环时间 不写的话就默认是视频总长度
@property (nonatomic,strong) UIColor * backgroundColor ; //播放器背景颜色
@property (nonatomic,assign) BOOL sound ; //是否开启声音
@property (nonatomic,assign) CGFloat alpha ; //透明度
@property (nonatomic,assign) BOOL alwaysRepeat ; //是否一致循环
@property (nonatomic,assign) enum ScalingMode fillMode ; //视频播放时的窗口属性

@end
