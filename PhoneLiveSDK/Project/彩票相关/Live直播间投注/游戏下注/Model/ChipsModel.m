//
//  ChipsModel.m
//  phonelive2
//
//  Created by 400 on 2022/4/5.
//  Copyright © 2022 toby. All rights reserved.
//

#import "ChipsModel.h"

@implementation ChipsModel

@end

@implementation ChipsListModel

static ChipsListModel* manager = nil;
/** 单例类方法 */
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[super allocWithZone:NULL] init];
        }
        
    });
    return manager;
}
-(NSMutableArray<ChipsModel*>*)chipListArrays{
    NSMutableArray *chipModelL = [NSMutableArray array];
    NSMutableArray *allChipNumArray = [NSMutableArray arrayWithArray:@[
        @2,
        @10,
        @100,
        @200,
        @500,
        @1000
    ]];
    NSString *rateCurrencyStr;
    if ([common getCustomChipStr] != nil) {
        NSString *region = [[common getCustomChipStr] componentsSeparatedByString:@"+"].firstObject;
        if ([region isEqualToString:[Config getRegionCurreny]]) {
            rateCurrencyStr = [YBToolClass currencyCoverToK: [[common getCustomChipStr] componentsSeparatedByString:@"+"].lastObject];
        } else {
            rateCurrencyStr = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%f",[common getCustomChipNum]]showUnit: NO];
        }
    } else {
        rateCurrencyStr = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%f",[common getCustomChipNum]]showUnit: NO];
    }
    NSString *customChipString = [NSString stringWithFormat:@"?%@",[common getCustomChipNum]>0?[@"\n" stringByAppendingString:rateCurrencyStr]:@""];
    ChipsModel *modelCust = [[ChipsModel alloc]init];
    modelCust.chipNumber = [common getCustomChipNum];
    modelCust.isEdit = true;
    modelCust.chipStr = customChipString;
    modelCust.chipIcon = [NSString stringWithFormat:@"ic_chip_7"];
    modelCust.customChipNumber = [common getCustomChipNum];
    
    ChipsModel *chipLast = [common getLastChipModel];
    if (chipLast.isEdit) {
        [chipModelL addObject:modelCust];
    }
    int lastNum = 0;
    ChipsModel *isNeedResort = nil;
    for (int i = 0; i<allChipNumArray.count;i++) {
        NSInteger number = [((NSNumber*)allChipNumArray[i]) integerValue];
        ChipsModel *model = [[ChipsModel alloc]init];
        model.chipNumber = number;
        model.isEdit = false;
        model.chipStr = [YBToolClass getRateCurrency:[NSString stringWithFormat:@"%ld",(long)number] showUnit:NO];
        model.chipIcon = [NSString stringWithFormat:@"ic_chip_%d",i+1];
        if (number == chipLast.chipNumber && !chipLast.isEdit) {
            lastNum = i;
            isNeedResort = model;
        }
        [chipModelL addObject:model];
    }
    if (chipModelL.count==allChipNumArray.count) {
        [chipModelL addObject:modelCust];
    }
    if (isNeedResort && lastNum>0) {
        [chipModelL removeObject:isNeedResort];
        [chipModelL insertObject:isNeedResort atIndex:0];
    }
    return chipModelL;
}

@end
