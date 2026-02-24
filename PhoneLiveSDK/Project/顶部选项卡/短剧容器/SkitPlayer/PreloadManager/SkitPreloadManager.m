//
//  SkitPreloadManager.m
//  phonelive2
//
//  Created by s5346 on 2024/7/10.
//  Copyright © 2024 toby. All rights reserved.
//

#import "SkitPreloadManager.h"
#import "SkitPreload.h"

@interface SkitPreloadManager ()

@property (nonatomic, strong) NSMutableArray<SkitPreload*> *preloads;
@property (nonatomic, strong) dispatch_queue_t preloadQueue;

@end

@implementation SkitPreloadManager

- (instancetype)init {
    if (self = [super init]) {
        self.preloadQueue = dispatch_queue_create("com.ht.abcdef.skitPreload", DISPATCH_QUEUE_CONCURRENT);
        self.preloads = [NSMutableArray array];
    }
    return self;
}

- (void)addPreload:(SkitVideoInfoModel*)model {
    if (![model isKindOfClass:[SkitVideoInfoModel class]]) {
        return;
    }
    WeakSelf
    dispatch_async(dispatch_get_main_queue(), ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        SkitPreload *preload = [[SkitPreload alloc] init];
        [preload addModel:model];
        [strongSelf.preloads addObject:preload];
    });
}

- (void)reset {
    for (SkitPreload *preload in self.preloads) {
        [preload clear];
    }
    [self.preloads removeAllObjects];
}

@end
