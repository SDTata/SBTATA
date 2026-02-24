//
//  AddTagsViewController.h
//  phonelive2
//
//  Created by Co co on 2024/7/17.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AddTagsAction <NSObject>

-(void)addOtherTags:(NSArray*)tags;

@end

@interface AddTagsViewController : UIViewController

@property(nonatomic,assign)id<AddTagsAction> delelgate;

@property(nonatomic,strong)NSMutableArray *datas;

@end

NS_ASSUME_NONNULL_END
