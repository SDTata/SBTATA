
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface chatModel : NSObject

@property(nonatomic,strong)NSString *titleColor;

@property(nonatomic,strong)NSString *type;

@property(nonatomic,strong)NSString *city;

@property(nonatomic,strong)NSString *userName;

@property(nonatomic,strong)NSString *contentChat;

@property(nonatomic,strong)NSString *signature;

@property(nonatomic,strong)NSString *ID;

@property(nonatomic,strong)NSString *sex;

@property(nonatomic,strong)NSString *vip_type;

@property(nonatomic,strong)NSString *king_icon;

@property(nonatomic,strong)NSString *liangname;

@property(nonatomic,strong)NSString *isAnchor;

@property(nonatomic,strong)NSString *isadmin;

@property(nonatomic,strong)NSString *guardType;

@property(nonatomic,strong)NSNumber *bRichtext;


@property(nonatomic,assign)CGRect vipR;

@property(nonatomic,assign)CGRect kingR;

@property(nonatomic,assign)CGRect liangR;

@property(nonatomic,strong)NSString *levelI;

@property(nonatomic,strong)NSString *userID;

@property(nonatomic,strong)NSString *icon;

@property(nonatomic,assign)CGFloat rowHH;

@property(nonatomic,assign)CGRect nameR;

@property(nonatomic,assign)CGRect NAMER;


@property(nonatomic,assign)CGRect cotentchatR;

@property(nonatomic,assign)CGRect levelR;


@property(nonatomic,assign)CGRect contentR;

@property(nonatomic,strong)NSString* gamePlat;
@property(nonatomic,strong)NSString* gameKindID;

@property(nonatomic,strong)NSString* lotteryType;
@property(nonatomic,strong)NSString* way;
@property(nonatomic,strong)NSString* ways;
@property(nonatomic,strong)NSString* money;
@property(nonatomic,strong)NSString* issue;
@property(nonatomic,strong)NSString* optionName1;
@property(nonatomic,strong)NSString* optionNameSt;

@property(nonatomic,strong)NSString* textString;
@property(nonatomic,strong)NSString* lang;
@property(nonatomic,assign)BOOL isTranslate;
@property(nonatomic,strong)NSString* isUserMsg;
@property(nonatomic,strong)NSString* isSeverMsg;
@property(nonatomic,strong)NSString* giftType;


@property(nonatomic,strong)NSAttributedString *textAttribute;

-(instancetype)initWithDic:(NSDictionary *)dic;

+(instancetype)modelWithDic:(NSDictionary *)dic;

-(void)setChatFrame;


@end
