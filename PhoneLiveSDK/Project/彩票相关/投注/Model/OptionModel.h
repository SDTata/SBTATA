#import <Foundation/Foundation.h>

@interface OptionModel : NSObject

@property (nonatomic, assign) BOOL isSelected; //是否选中 默认为NO
@property (nonatomic, copy) NSString *type;     //num text
@property (nonatomic, copy) NSString *title;     //
@property (nonatomic, copy) NSString *st;   //
@property (nonatomic, copy) NSString *st_des;   //
@property (nonatomic, copy) NSString *value;   //
@property (nonatomic, copy) NSString *desc;   //
@property (nonatomic, copy) NSArray *rest;   //
@property (nonatomic, copy) NSIndexPath *indexpath;   //

@end
