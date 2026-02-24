//
//  ExchangeRateModel.h
//  phonelive2
//
//  Created by lucas on 2021/9/24.
//  Copyright © 2021 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExchangeRateModel : NSObject
/** ID */
@property (nonatomic, copy) NSString *ID;
/** 地区 */
@property (nonatomic, copy) NSString *region;
/** 币简称 */
@property (nonatomic, copy) NSString *region_curreny;
/** 符号 */
@property (nonatomic, copy) NSString *region_curreny_char;
/** 图标 */
@property (nonatomic, copy) NSString *region_curreny_icon;
/** 汇率 */
@property (nonatomic, copy) NSString *exchange_rate;

@property (nonatomic, copy) NSString *region_icon;

@property (nonatomic, copy) NSString *region_name;

/** 拼音 */
@property (nonatomic, copy) NSString *pinyin;
/** 拼音首字母 */
@property (nonatomic, copy) NSString *firstLetter;

@end

NS_ASSUME_NONNULL_END
