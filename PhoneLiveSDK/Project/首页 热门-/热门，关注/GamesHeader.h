//
//  GamesHeader.h
//  phonelive2
//
//  Created by test on 4/13/21.
//  Copyright © 2021 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterAnchorCounrtyView.h"
NS_ASSUME_NONNULL_BEGIN
@protocol GameHeaderDelegate <NSObject>

-(void)jumpToGameType:(NSDictionary*)gameDic;
-(void)filterVC;


@end

@interface GamesHeader : UIView

@property(nonatomic,strong)FilterAnchorCounrtyView *anchorfiltrCountryView;
@property(nonatomic,assign)id<GameHeaderDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
