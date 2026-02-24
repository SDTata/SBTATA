//
//  TaskMenuCell.h
//  phonelive
//
//  Created by 400 on 2020/9/21.
//  Copyright © 2020 toby. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TaskMenuCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
- (void)setStatus:(BOOL)status;
@end

NS_ASSUME_NONNULL_END
