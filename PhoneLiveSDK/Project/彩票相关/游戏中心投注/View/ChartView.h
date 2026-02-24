//
//  ChartView.h
//  phonelive2
//
//  Created by 400 on 2022/6/27.
//  Copyright © 2022 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface ChartModel : NSObject

//0 不显示 1红色 2 蓝色 3绿色
@property(nonatomic,assign)int displayType;
//豹1 豹6 0斜杠显示 空不显示
@property(nonatomic,strong)NSString *displayTitle;

@property(nonatomic,strong)NSString *showTitle;

@property(nonatomic,assign)int xIndex;

@property(nonatomic,assign)int yIndex;

@property(nonatomic,assign)int rootIndex;

@end

@interface ChartView : UIView
+ (instancetype)instanceChatViewWithType:(NSInteger)type;
-(void)updateMenueStr1:(NSString*)str1 Str2:(NSString*)str2;

-(void)updateChartData:(NSString*)result;

-(void)scrollToRight;
@end

NS_ASSUME_NONNULL_END
