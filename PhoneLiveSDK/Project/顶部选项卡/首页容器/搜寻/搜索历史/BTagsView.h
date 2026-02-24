//
//  BTagsView.h
//  phonelive2
//
//  Created by user on 2024/7/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TagViewDelegate <NSObject>
- (void)didSelecedTag:(NSString *)text;
@end
@interface BTagsView : UIView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *datas;
@property(nonatomic,assign) id<TagViewDelegate> delelgate;

@end
