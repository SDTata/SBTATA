//
//  YBUserInfoContentView.h
//  phonelive2
//
//  Created by user on 2024/7/26.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@protocol YBUserInfoContentViewDelegate <NSObject>
- (void)didSelected:(NSDictionary *)data;
@end

@interface YBUserInfoContentView : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *datas;
@property(nonatomic,assign) id<YBUserInfoContentViewDelegate> delegate;
@end
NS_ASSUME_NONNULL_END
