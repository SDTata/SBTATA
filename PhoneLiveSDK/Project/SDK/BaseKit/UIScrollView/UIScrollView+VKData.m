//
//  UIScrollView+VKData.m
//
//  Created by vick on 2021/4/17.
//

#import "UIScrollView+VKData.h"
#import "UIScrollView+VKPage.h"
#import "VKBaseCollectionView.h"
#import "VKBaseTableView.h"

@implementation UIScrollView (VKData)

- (void)setKeys:(NSMutableArray *)keys {
    VK_PROPERTY_OBJECT(keys);
}

- (NSMutableArray *)keys {
    NSMutableArray *keys = VK_PROPERTY_GET(keys);
    if (!keys) {
        keys = [NSMutableArray array];
        self.keys = keys;
    }
    return keys;
}

- (void)vk_refreshFinish:(NSArray *)array {
    
    if ([self isKindOfClass:[VKBaseCollectionView class]]) {
        
        if (self.isHeaderRefreshing && array) {
            [[(VKBaseCollectionView *)self dataItems] removeAllObjects];
        }
        [[(VKBaseCollectionView *)self dataItems] addObjectsFromArray:array];
        [(VKBaseCollectionView *)self reloadData];
        [self vk_endRefreshing:array];
        
    } else if ([self isKindOfClass:[VKBaseTableView class]]) {
        
        if (self.isHeaderRefreshing && array) {
            [[(VKBaseTableView *)self dataItems] removeAllObjects];
        }
        [[(VKBaseTableView *)self dataItems] addObjectsFromArray:array];
        [(VKBaseTableView *)self reloadData];
        [self vk_endRefreshing:array];
        
    } else {
        
        [self vk_endRefreshing:array];
    }
}

- (void)vk_refreshFinish:(NSArray *)array withKey:(NSString *)key {
    
    if ([self isKindOfClass:[VKBaseCollectionView class]]) {
        
        if (self.isHeaderRefreshing && array) {
            [[(VKBaseCollectionView *)self dataItems] removeAllObjects];
            [self.keys removeAllObjects];
        }
        
        NSArray *results = [self handleDatasUnique:array key:key];
        [[(VKBaseCollectionView *)self dataItems] addObjectsFromArray:results];
        [(VKBaseCollectionView *)self reloadData];
        [self vk_endRefreshing:array];
        
    } else if ([self isKindOfClass:[VKBaseTableView class]]) {
        
        if (self.isHeaderRefreshing && array) {
            [[(VKBaseTableView *)self dataItems] removeAllObjects];
            [self.keys removeAllObjects];
        }
        
        NSArray *results = [self handleDatasUnique:array key:key];
        [[(VKBaseTableView *)self dataItems] addObjectsFromArray:results];
        [(VKBaseTableView *)self reloadData];
        [self vk_endRefreshing:array];
        
    } else {
        
        [self vk_endRefreshing:array];
    }
}

- (NSArray *)handleDatasUnique:(NSArray *)array key:(NSString *)key {
    NSMutableArray *results = [NSMutableArray array];
    if ([array.firstObject respondsToSelector:NSSelectorFromString(key)]) {
        for (id item in array) {
            NSString *value = [item valueForKey:key];
            if (value && ![self.keys containsObject:value]) {
                [results addObject:item];
            }
            [self.keys addObject:value];
        }
    }
    return results;
}

@end
