//
//  ShortVideosContainer.h
//  phonelive2
//
//  Created by user on 2024/6/21.
//  Copyright © 2024 toby. All rights reserved.
//

#import "VKPagerVC.h"
#import "ShortVideoModel.h"

@interface ShortVideosContainer : VKPagerVC

- (void)listWillDisappear;
- (void)selectIndex:(int)index;
- (void)insertModelToHotShortVideo:(ShortVideoModel*)model;
- (void)handleRefresh;
- (void)hideCommentView;
@end

