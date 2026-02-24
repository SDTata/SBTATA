//
//  VKActionModel.h
//
//  Created by vick on 2023/5/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VKActionModel : NSObject

@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *iconSelected;
@property (nonatomic, assign) CGSize iconSize;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *titleSelected;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *titleColorSelected;
@property (nonatomic, strong) UIFont *titleFont;

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *messageSelected;
@property (nonatomic, strong) UIColor *messageColor;
@property (nonatomic, strong) UIColor *messageColorSelected;
@property (nonatomic, strong) UIFont *messageFont;

@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *valueSelected;
@property (nonatomic, strong) UIColor *valueColor;
@property (nonatomic, strong) UIColor *valueColorSelected;
@property (nonatomic, strong) UIFont *valueFont;

@property (nonatomic, strong) UIColor *backgroudColor;
@property (nonatomic, assign) UIEdgeInsets backInsets;
@property (nonatomic, assign) CGFloat backCorner;

@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) BOOL showArrow;
@property (nonatomic, assign) BOOL isHorizontal;
@property (nonatomic, assign) BOOL selected;

@property (nonatomic, strong) id extra;

@end
