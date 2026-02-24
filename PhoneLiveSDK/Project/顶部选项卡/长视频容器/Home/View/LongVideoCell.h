//
//  LongVideoCell.h
//  phonelive2
//
//  Created by vick on 2024/6/25.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoBaseCell.h"

@interface LongVideoCell : VideoBaseCell
+(CGFloat)ratio;
+(CGFloat)minimumLineSpacing;
@end


@interface LongVideoTwoCell : LongVideoCell

@end


@interface LongVideoSearchResultCell : LongVideoCell

@end
