//
//  TaskMenuCell.m
//  phonelive
//
//  Created by 400 on 2020/9/21.
//  Copyright © 2020 toby. All rights reserved.
//

#import "TaskMenuCell.h"
@interface TaskMenuCell()
@property (weak, nonatomic) IBOutlet UIView *bottom_line;

@end
@implementation TaskMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectButton.layer.masksToBounds = YES;
    self.selectButton.layer.cornerRadius = 15;
    // Initialization code
    [self.bottom_line setHidden:YES];
}

- (void)setStatus:(BOOL)status{
    
    self.bottom_line.hidden = !status;
}
@end
