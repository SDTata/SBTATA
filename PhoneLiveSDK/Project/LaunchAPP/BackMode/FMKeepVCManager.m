//
//  FMKeepVCManager.m
//  BackModeDemo
//
//  Created by LIUSONG on 2019/4/5.
//  Copyright © 2019 Rayor. All rights reserved.
//

#import "FMKeepVCManager.h"

@implementation FMKeepVCManager

+ (instancetype)shared {
	static FMKeepVCManager * manager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[FMKeepVCManager alloc] init];
	});
	return manager;
}

- (UIViewController *)liveVCFromManager:(Class)class {
	for (UIViewController *vc in self.keepVCs) {
		if ([vc isKindOfClass:class]) {
			return vc;
		}
	}
	return nil;
}

- (NSMutableArray *)keepVCs {
	if (!_keepVCs) {
		_keepVCs = [[NSMutableArray alloc] init];
	}
	return _keepVCs;
}

@end
