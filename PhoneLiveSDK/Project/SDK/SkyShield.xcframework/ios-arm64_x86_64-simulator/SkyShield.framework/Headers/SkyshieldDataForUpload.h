//
//  DataForUpload.h
//  SkyShieldDemo
//
//  Created by Co co on 2025/7/1.
//

#import <Foundation/Foundation.h>


@interface SkyshieldDataForUpload : NSObject

@property(nonatomic,strong)NSData *datas;

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *filename;
@property(nonatomic,strong)NSString *mimeType;

@end
