//
//  VKPagerSegment+Style.m
//
//  Created by vick on 2021/5/11.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "VKPagerSegment+Style.h"
#import "VKCodeKit.h"

@implementation VKPagerSegment (Style)
@dynamic segmentStyle;

- (void)setSegmentStyle:(SegmentStyle)segmentStyle {
    switch (segmentStyle) {
        case SegmentStyleNone:
        {
            self.averageCellSpacingEnabled = NO;
            self.contentEdgeInsetLeft = 0;
            self.contentEdgeInsetRight = 0;
            
//            self.titleColor = VKTheme.h3Color;
//            self.titleSelectedColor = VKTheme.themeColor;
            self.titleFont = vkFont(16);
            self.titleSelectedFont = vkFont(16);
        }
            break;
        case SegmentStyleLine:
        {
            self.averageCellSpacingEnabled = NO;
            
            self.titleColor = UIColor.blackColor;
            self.titleSelectedColor = UIColor.blackColor;
            self.titleFont = vkFontMedium(16);
            self.titleSelectedFont = vkFontMedium(16);
            
            self.indicatorsView = [[JXCategoryIndicatorLineView alloc] init];
            self.indicatorsView.indicatorHeight = 3;
            self.indicatorsView.indicatorWidth = 18;
            self.indicatorsView.indicatorColor = vkColorHex(0x9F57DF);
            self.indicators = @[self.indicatorsView];
        }
            break;
        case SegmentStyleRound:
        {
            self.averageCellSpacingEnabled = NO;
            
            self.titleColor = UIColor.blackColor;
            self.titleSelectedColor = UIColor.whiteColor;
            self.titleFont = vkFont(14);
            self.titleSelectedFont = vkFont(14);
            
            self.cellBackgroundColorGradientEnabled = YES;
            self.cellBackgroundUnselectedColor = UIColor.clearColor;
            self.cellBackgroundSelectedColor = vkColorHex(0xbb67ff);
            self.cellBorderCornerRadius = 12;
            
            self.cellSpacing = 10;
            self.cellWidthIncrement = 20;
        }
            break;
        case SegmentStyleSegment:
        {
//            self.titleColor = VKTheme.h1Color;
//            self.titleSelectedColor = VKTheme.h1Color;
            self.titleFont = vkFont(12);
            self.titleSelectedFont = vkFont(12);
            
            self.cellBackgroundColorGradientEnabled = YES;
//            self.cellBackgroundUnselectedColor = VKTheme.backGroundColor;
//            self.cellBackgroundSelectedColor = VKTheme.themeColor;
            
            self.contentEdgeInsetLeft = 0;
            self.contentEdgeInsetRight = 0;
            self.cellSpacing = 0;
            self.equalWidth = YES;
        }
            break;
        case SegmentStyleLineWithWhite:
        {
            self.averageCellSpacingEnabled = NO;

            self.titleColor = UIColor.whiteColor;
            self.titleSelectedColor = UIColor.whiteColor;
            self.titleFont = vkFontMedium(16);
            self.titleSelectedFont = vkFontMedium(16);

            self.indicatorsView = [[JXCategoryIndicatorLineView alloc] init];
            self.indicatorsView.indicatorHeight = 3;
            self.indicatorsView.indicatorWidth = 18;
            self.indicatorsView.indicatorColor = vkColorHex(0x9F57DF);
            self.indicators = @[self.indicatorsView];
        }
            break;
        case SegmentStylePoint:
        {
            self.averageCellSpacingEnabled = YES;

            self.cellBackgroundColorGradientEnabled = YES;
            self.cellBackgroundUnselectedColor = UIColor.lightGrayColor;
            self.cellBackgroundSelectedColor = UIColor.blackColor;
            self.cellBorderCornerRadius = 4;
            
            self.cellSpacing = 5;
            self.cellWidth = 8;
        }
            break;
        default:
            break;
    }
}

@end
