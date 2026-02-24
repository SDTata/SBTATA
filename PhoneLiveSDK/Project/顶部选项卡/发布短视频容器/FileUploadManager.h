//
//  FileUploadManager.h
//  phonelive2
//
//  Created by user on 2024/9/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileUploadManager : NSObject
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *server;
@property (nonatomic) NSInteger chunkSize;

- (instancetype)initWithFileURL:(NSURL *)fileURL token:(NSString *)token server:(NSString *)server;
- (void)uploadFile;

@end

NS_ASSUME_NONNULL_END
