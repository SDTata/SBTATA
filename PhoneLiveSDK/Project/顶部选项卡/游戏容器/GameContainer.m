//
//  GameContainer.m
//  phonelive2
//
//  Created by user on 2024/10/2.
//  Copyright © 2024 toby. All rights reserved.
//

#import "GameContainer.h"

@interface GameContainer ()

@end

@implementation GameContainer

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pageViewDidSelectedItemAtIndex:(NSInteger)index {
    [self convertCoinOut:nil];
    [self needShowTicket:index];
}

@end
