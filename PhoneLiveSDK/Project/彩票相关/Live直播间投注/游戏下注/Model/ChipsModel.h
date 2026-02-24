//
//  ChipsModel.h
//  phonelive2
//
//  Created by 400 on 2022/4/5.
//  Copyright © 2022 toby. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ChipsModel : NSObject

@property(nonatomic,assign)double chipNumber;
@property(nonatomic,assign)BOOL isEdit;
@property(nonatomic,strong)NSString *chipStr;
@property(nonatomic,strong)NSString *chipIcon;
@property(nonatomic,assign)NSInteger customChipNumber;
@property(nonatomic,assign)BOOL selected;

@end

@interface ChipsListModel : NSObject

+ (instancetype)sharedInstance;
-(NSMutableArray<ChipsModel*>*)chipListArrays;

@end


