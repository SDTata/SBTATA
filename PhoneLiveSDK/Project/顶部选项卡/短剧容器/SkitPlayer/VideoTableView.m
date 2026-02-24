//
//  VideoTableView.m
//  phonelive2
//
//  Created by vick on 2024/9/6.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VideoTableView.h"
#import "ZFPlayer.h"
#import "SkitPlayerVideoCell.h"

@implementation VideoTableView

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    SkitPlayerVideoCell *shortCell = (SkitPlayerVideoCell*)cell;
    // 修正如果沒影片，滑出再滑入 controlView 會不見
    if (shortCell.controlView.superview == nil) {
        [shortCell.contentView addSubview:shortCell.controlView];
        shortCell.controlView.frame = cell.bounds;
    }
}

#pragma mark - ZFTableViewCellDelegate
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    [scrollView zf_scrollViewWillBeginDragging];
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    [scrollView zf_scrollViewDidEndDraggingWillDecelerate:decelerate];
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    [scrollView zf_scrollViewDidEndDecelerating];
//}
//
//- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
//    [scrollView zf_scrollViewDidScrollToTop];
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [scrollView zf_scrollViewDidScroll];
//}

@end
