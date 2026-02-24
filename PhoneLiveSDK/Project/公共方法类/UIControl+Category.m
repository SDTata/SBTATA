//
//  UIControl+Category.m
//  phonelive2
//
//  Created by user on 2024/3/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "UIControl+Category.h"
#import "objc/runtime.h"

static const void * OrderTagsBy = &OrderTagsBy;

@implementation UIControl (Category)
@dynamic OrderTags;


-(void)setOrderTags:(NSString *)OrderTags {
    objc_setAssociatedObject(self, OrderTagsBy, OrderTags, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)OrderTags {
  return objc_getAssociatedObject(self, OrderTagsBy);
}

@end
