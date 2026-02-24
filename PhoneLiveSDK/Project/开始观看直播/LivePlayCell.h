//
//  LivePlayCell.h
//  phonelive
//
//  Created by 400 on 2020/9/3.
//  Copyright © 2020 toby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LivePlay.h"

@class hotModel;
@interface LivePlayCell : UITableViewCell
@property(nonatomic,strong)UIImageView *imgView;
@property(nonatomic,weak)moviePlay *moviePlayView;
-(void)loadImageView:(hotModel*)model;

@end

