//
//  NSObject+VKUtil.h
//
//  Created by vick on 2022/12/2.
//

#import <Foundation/Foundation.h>

@interface NSObject (VKUtil)

@property (nonatomic, strong) id extraData;

- (void)runSelector:(SEL)selector;

- (void)runSelector:(SEL)selector object:(id)object;

@end
