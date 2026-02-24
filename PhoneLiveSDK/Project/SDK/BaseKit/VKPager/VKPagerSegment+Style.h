//
//  VKPagerSegment+Style.h
//
//  Created by vick on 2021/5/11.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "VKPagerSegment.h"

typedef NS_ENUM(NSInteger, SegmentStyle) {
    SegmentStyleNone,/// 普通样式
    SegmentStyleLine,/// 下划线样式
    SegmentStyleRound,/// 圆角样式
    SegmentStyleSegment,/// 分段样式
    SegmentStyleLineWithWhite,/// 下划线样式 白字
    SegmentStylePoint,/// 圆点样式
};

@interface VKPagerSegment (Style)

@property (nonatomic, assign) SegmentStyle segmentStyle;

@end
