//
//  DramaPreloadManager.m
//  phonelive2
//
//  Created by s5346 on 2024/6/13.
//  Copyright © 2024 toby. All rights reserved.
//

#import "DramaPreloadManager.h"
#import "DramaPreload.h"

@interface DramaPreloadManager ()

@property (nonatomic, strong) NSMutableArray<DramaPreload*> *preloads;
@property (nonatomic, strong) dispatch_queue_t preloadQueue;

@end

@implementation DramaPreloadManager

- (instancetype)init {
    if (self = [super init]) {
        self.preloadQueue = dispatch_queue_create("com.ht.abcdef.dramaPreload", DISPATCH_QUEUE_CONCURRENT);
        self.preloads = [NSMutableArray array];
    }
    return self;
}

- (void)addPreload:(DramaVideoInfoModel*)model {
    WeakSelf
    dispatch_async(self.preloadQueue, ^{
        STRONGSELF
        if (strongSelf == nil) {
            return;
        }
        DramaPreload *preload = [[DramaPreload alloc] init];
        [preload addModel:model];
        [strongSelf.preloads addObject:preload];
    });
}

- (void)reset {
    [self.preloads removeAllObjects];
}

@end
