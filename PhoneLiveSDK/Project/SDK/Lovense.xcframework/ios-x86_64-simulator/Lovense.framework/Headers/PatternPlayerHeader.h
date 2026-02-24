//
//  PatternPlayerHeader.h
//  Lovense
//
//  Created by 陈自豪 on 2023/5/29.
//  Copyright © 2023 lovense. All rights reserved.
//

#ifndef PatternPlayerHeader_h
#define PatternPlayerHeader_h

typedef NS_ENUM(NSUInteger, PatternPrepareState) {
    PatternPrepareStateDownloading, // 下载中
    PatternPrepareStateDownloadCompleted, // 下载完毕
    PatternPrepareStateDownloadFail // 下载失败
};

#endif /* PatternPlayerHeader_h */
