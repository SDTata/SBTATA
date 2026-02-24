//
//  RandomRule.h
//  phonelive
//
//  Created by 400 on 2020/12/14.
//  Copyright © 2020 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RandomRule : NSObject
///横向行和纵向列
+(NSString*)randomWithColumn:(NSInteger)columnNumber Line:(NSInteger)lineNumber seeds:(NSInteger)seedsNumber others:(NSDictionary*)others;


@end


