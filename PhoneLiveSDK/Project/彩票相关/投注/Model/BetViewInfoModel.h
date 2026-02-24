//
//Created by ESJsonFormatForMac on 20/05/31.
//

#import <Foundation/Foundation.h>

@class Lastresult;//,Ways,Options;
@interface BetViewInfoModel : NSObject

@property (nonatomic, copy) NSString *sealingTim;

@property (nonatomic, assign) NSInteger stopOrSell;

@property (nonatomic, copy) NSString *issue;

@property (nonatomic, copy) NSString *lobbyServer;

@property (nonatomic, copy) NSString *lobby_flag;

@property (nonatomic, copy) NSString *left_coin;

@property (nonatomic, copy) NSString *min_bet;

@property (nonatomic, assign) NSInteger time;

@property (nonatomic, copy) NSString *stopMsg;

@property (nonatomic, copy) NSString *logo;

@property (nonatomic, assign) NSInteger serTime;

@property (nonatomic, strong) NSArray *ways;

@property (nonatomic, copy) NSString *lotteryType;

@property (nonatomic, strong) Lastresult *lastResult;

@property (nonatomic, copy) NSString *name;

@end
@interface Lastresult : NSObject

@property (nonatomic, copy) NSString *open_time;

@property (nonatomic, strong) NSArray *spare_2;

@property (nonatomic, copy) NSString *issue;

@property (nonatomic, copy) NSString *open_result;

@end

//@interface Ways : NSObject
//
//@property (nonatomic, copy) NSString *name;
//
//@property (nonatomic, strong) NSArray *options;
//
//@end

//@interface Options : NSObject
//
//@property (nonatomic, copy) NSString *value;
//
//@property (nonatomic, copy) NSString *title;
//
//@property (nonatomic, copy) NSString *sort;
//
//@property (nonatomic, copy) NSString *color;
//
//@end

