//
//  VKBaseCollectionViewCell.m
//
//  Created by vick on 2020/11/2.
//

#import "VKBaseCollectionViewCell.h"

@implementation VKBaseCollectionViewCell

+ (CGFloat)autoHeightForItem:(id)itemModel {
    return [self itemHeight];
}

+ (CGFloat)itemHeight {
    return 44;
}

+ (CGFloat)itemWidth {
    return -1;
}

+ (NSInteger)itemCount {
    return 4;
}

+ (CGFloat)itemSpacing {
    return 0;
}

+ (CGFloat)itemLineSpacing {
    return 0;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self updateView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self updateView];
}

- (void)updateView {
    
}

- (void)updateData {
    
}

- (void)reload {
    if (self.baseTableView && self.indexPath) {
            NSLog(@"重新加载单元格，indexPath: %@", self.indexPath);
            [self.baseTableView reloadItemsAtIndexPaths:@[self.indexPath]];
        } else {
            NSLog(@"无效的 baseTableView 或 indexPath");
        }
//    [self.baseTableView reloadItemsAtIndexPaths:@[self.indexPath]];
}

- (VKBaseCollectionView *)baseTableView {
    UIView *tableView = self.superview;
    while (![tableView isKindOfClass:[VKBaseCollectionView class]] && tableView) {
        tableView = tableView.superview;
    }
    return (VKBaseCollectionView *)tableView;
}

- (void)deleteItem {
    [self.baseTableView.dataItems removeObjectAtIndex:self.indexPath.row];
    [self.baseTableView reloadData];
}

- (BOOL)isLastCell {
    NSArray *array = [self.baseTableView rowItemsForSectionIndex:self.indexPath.section];
    return self.indexPath.row == array.count-1;
}

@end
