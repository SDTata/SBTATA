//
//  FLLayout.h
//  FLTag
//
//  Created by Felix on 2017/5/11.
//  Copyright © 2017年 FREEDOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kWidth [UIScreen mainScreen].bounds.size.width
@protocol FLLayoutDatasource;


@interface FLLayout : UICollectionViewLayout
@property (nonatomic, assign) UIEdgeInsets insets;

- (void) resetDict;
@property (nonatomic, weak) id<FLLayoutDatasource> dataSource;

@end


@protocol FLLayoutDatasource<NSObject>
@required
- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath*)indexPath;

@end
