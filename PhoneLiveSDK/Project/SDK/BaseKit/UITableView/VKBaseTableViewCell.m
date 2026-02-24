//
//  VKBaseTableViewCell.m
//
//  Created by vick on 2020/11/2.
//

#import "VKBaseTableViewCell.h"

@implementation VKBaseTableViewCell

+ (CGFloat)autoHeightForItem:(id)itemModel {
    return [self itemHeight];
}

+ (CGFloat)itemHeight {
    return 44;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;
    [self updateView];
}

- (void)updateView {
    
}

- (void)updateData {
    
}

- (void)reload {
    [self.baseTableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (VKBaseTableView *)baseTableView {
    UIView *tableView = self.superview;
    while (![tableView isKindOfClass:[VKBaseTableView class]] && tableView) {
        tableView = tableView.superview;
    }
    return (VKBaseTableView *)tableView;
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
