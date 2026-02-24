//
//  YBNoWordView.h
//  yunbaolive
//
//  Created by Boom on 2018/10/31.
//  Copyright © 2018年 cat. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^refrashBtnBlock)(id _Nullable msg);

@interface YBNoWordView : UIView
- (instancetype _Nullable )initWithImageName:(NSString *_Nullable)imageName andTitle:(NSString *_Nullable)title withBlock:(refrashBtnBlock _Nullable )bbbbb AddTo:(UIView *_Nullable)superView;
@property (nonatomic,copy) refrashBtnBlock _Nullable block;
@end
