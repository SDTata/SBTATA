//
//  profitTypeVC.h
//  yunbaolive
//
//  Created by Boom on 2018/10/11.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^profitTypeSelect)(NSDictionary *dic);
@interface WithDrawTypeModel : NSObject
@property(nonatomic,strong)NSString *id;
@property(nonatomic,strong)NSString *num;
@property(nonatomic,strong)NSString *status;
@property(nonatomic,strong)NSString *title;
@end


@interface profitTypeVC : UIViewController
@property (nonatomic,strong)NSString *selectID;
@property (nonatomic,copy) profitTypeSelect block;
@property (nonatomic, strong) NSArray <WithDrawTypeModel *> *types;
@property (nonatomic, assign) NSInteger typeNum;

- (void)setnOnlyCard;
@end

NS_ASSUME_NONNULL_END
