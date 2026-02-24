//
//  GameHomeModel.h
//  phonelive2
//
//  Created by vick on 2024/10/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameListModel : NSObject

@property (nonatomic, copy) NSString *kindID;
@property (nonatomic, assign) NSInteger maintain;
@property (nonatomic, copy) NSString *meunName;
@property (nonatomic, copy) NSString *plat;
@property (nonatomic, assign) NSInteger show_name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *urlName;
@property (nonatomic, assign) CGFloat imageScale;
@property (nonatomic, assign) NSInteger gridCount;

@end


@interface GameTypeModel : NSObject

@property (nonatomic, assign) NSInteger gridCount;
@property (nonatomic, assign) NSInteger itemType;
@property (nonatomic, copy) NSString *meunName;
@property (nonatomic, assign) NSInteger show_name;
@property (nonatomic, strong) NSArray <GameListModel *> *sub;
@property (nonatomic, assign) NSInteger section;

@end


@interface GameHomeModel : NSObject

@property (nonatomic, copy) NSString *meunIcon;
@property (nonatomic, copy) NSString *meunIconSelected;
@property (nonatomic, copy) NSString *meunName;
@property (nonatomic, assign) NSInteger show_name;
@property (nonatomic, strong) NSArray <GameTypeModel *> *sub;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) NSInteger section;

@end
