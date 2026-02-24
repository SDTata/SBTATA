//
//  FileUploadManager.m
//  phonelive2
//
//  Created by user on 2024/9/5.
//  Copyright © 2024 toby. All rights reserved.
//

#import "FileUploadManager.h"
#define UploadVideoProgress @"UploadVideoProgress"
#define UploadVideoFinished @"UploadVideoFinished"
#define UploadVideoCancel @"UploadVideoCancel"

@interface FileUploadManager()
@property (nonatomic, assign) NSInteger totalChunks;
@property (nonatomic, assign) NSInteger chunkNumber;
@property (nonatomic, assign) BOOL hasError;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *retryCounts;
@end

@implementation FileUploadManager

- (instancetype)initWithFileURL:(NSURL *)fileURL token:(NSString *)token server:(NSString *)server {
    self = [super init];
    if (self) {
        self.fileURL = fileURL;
        self.token = token;
        self.server = server;
        self.chunkSize = 1024 * 1024;  // 1MB
        self.chunkNumber = 0;
        self.retryCounts = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"FileUploadManager - dealloc");
}

- (void)uploadFile {
    NSInteger totalChunks = [self calculateTotalChunks];
    self.totalChunks = totalChunks;
    
    NSString *statusURLString = [NSString stringWithFormat:@"%@_status?token=%@",self.server, self.token];
    NSURL *statusURL = [NSURL URLWithString:statusURLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:statusURL];
    [request setHTTPMethod:@"GET"];
    NSURLSessionDataTask *statusTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSDictionary *statusResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *uploadedChunks = statusResponse[@"uploaded_chunks"];
            
            for (NSInteger chunkNumber = 0; chunkNumber < totalChunks; chunkNumber++) {
                if ([uploadedChunks containsObject:@(chunkNumber)]) {
                    NSLog(@"Skipping chunk %ld", (long)chunkNumber);
                    continue;
                }
                [self uploadChunk:chunkNumber totalChunks:totalChunks];
            }
        } else {
            NSLog(@"uploaded_chunks error %@", error);
        }
    }];
    [statusTask resume];
}

- (NSInteger)calculateTotalChunks {
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.fileURL path] error:nil];
    NSInteger fileSize = [fileAttributes[NSFileSize] integerValue];
    return (NSInteger)ceil((double)fileSize / self.chunkSize);
}

- (void)uploadChunk:(NSInteger)chunkNumber totalChunks:(NSInteger)totalChunks {
    
    NSURL *uploadURL = [NSURL URLWithString:self.server];
    NSData *fileData = [self dataForChunk:chunkNumber];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uploadURL];
    [request setHTTPMethod:@"POST"];

    NSString *boundary = @"Boundary-XYZ";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

    NSMutableData *body = [NSMutableData data];

    // 添加文件数据
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", [self.fileURL lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:fileData];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    // 添加 chunk_number 字段
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"chunk_number\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%ld\r\n", (long)chunkNumber] dataUsingEncoding:NSUTF8StringEncoding]];

    // 添加 total_chunks 字段
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"total_chunks\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%ld\r\n", (long)totalChunks] dataUsingEncoding:NSUTF8StringEncoding]];

    // 添加 token 字段
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"token\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", self.token] dataUsingEncoding:NSUTF8StringEncoding]];

    // 结束标志
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    [request setHTTPBody:body];
    WeakSelf
    NSURLSessionUploadTask *uploadTask = [[NSURLSession sharedSession] uploadTaskWithRequest:request fromData:body completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        STRONGSELF
        if (!strongSelf) return;
        
        if (strongSelf.hasError) {
            return;
        }
        if (error == nil) {
            strongSelf.chunkNumber += 1;
            float percent = (float)strongSelf.chunkNumber / (float)strongSelf.totalChunks;
            NSLog(@"Chunk %ld uploaded successfully percent: %.2f", (long)chunkNumber, percent);
            
            if (percent == 1) {
                if (data) {
                    NSDictionary *statusResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSString *job_id = [statusResponse objectForKey:@"job_id"];
                    if (![PublicObj checkNull:job_id] && job_id.length > 1) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:UploadVideoFinished object:@{@"info":@"S3", @"isOK": @"YES"}];
                    } else {
                        //上传失败UI显示或者提示弹框上传失败重新上传，这里总之需要交互失败的处理。
                        WeakSelf
                        dispatch_async(dispatch_get_main_queue(), ^{
                            STRONGSELF
                            if (!strongSelf) return;
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:YZMsg(@"myInfoEdit_Upload_Error")
                                                                                           message:@""
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:UploadVideoCancel object:nil];
                            }];
                            
                            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:YZMsg(@"post_video_retry") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                                [strongSelf retryFullUpload];
                            }];
                            
                            [alert addAction:dismissAction];
                            [alert addAction:cancelAction];
                            
                            
                            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                            [rootViewController presentViewController:alert animated:YES completion:nil];
                        });
                    }
                    NSLog(@"上傳返回数据過程: %@", (NSDictionary *)statusResponse);
                }
               
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:UploadVideoProgress object:@{@"percent":min2float(percent)}];
            }
        } else {
            [strongSelf handleChunkUploadError:chunkNumber totalChunks:totalChunks];
            NSLog(@"Error uploading chunk %ld: %@", (long)chunkNumber, error.localizedDescription);
        }
    }];
    
    [uploadTask resume];
}

- (void)handleChunkUploadError:(NSInteger)chunkNumber totalChunks:(NSInteger)totalChunks {
    NSNumber *currentRetryCount = self.retryCounts[@(chunkNumber)] ?: @0;
    
    if ([currentRetryCount integerValue] < 3) {
        self.retryCounts[@(chunkNumber)] = @([currentRetryCount integerValue] + 1);
        [self uploadChunk:chunkNumber totalChunks:totalChunks];
    } else {
        WeakSelf
        dispatch_async(dispatch_get_main_queue(), ^{
            STRONGSELF
            if (!strongSelf) return;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:YZMsg(@"post_video_upload_interrupted")
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *continueAction = [UIAlertAction actionWithTitle:YZMsg(@"ppublic_continue") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                strongSelf.retryCounts[@(chunkNumber)] = @0;
                strongSelf.hasError = NO;
                [strongSelf uploadChunk:chunkNumber totalChunks:totalChunks];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:YZMsg(@"post_video_retry") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [strongSelf retryFullUpload];
            }];
            
            UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:YZMsg(@"public_cancel") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [[NSNotificationCenter defaultCenter] postNotificationName:UploadVideoCancel object:nil];
            }];
            
            [alert addAction:continueAction];
            [alert addAction:cancelAction];
            [alert addAction:dismissAction];
            
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            [rootViewController presentViewController:alert animated:YES completion:nil];
        });
    }
}

- (void)retryFullUpload {
    self.chunkNumber = 0;
    self.retryCounts = [NSMutableDictionary dictionary];
    [[NSNotificationCenter defaultCenter] postNotificationName:UploadVideoFinished object:@{@"info":@"S3", @"isOK": @"NO", @"resetUpload": @"YES"}];
}

- (NSData *)dataForChunk:(NSInteger)chunkNumber {
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[self.fileURL path]];
    [fileHandle seekToFileOffset:chunkNumber * self.chunkSize];
    NSData *chunkData = [fileHandle readDataOfLength:self.chunkSize];
    [fileHandle closeFile];
    return chunkData;
}

@end
