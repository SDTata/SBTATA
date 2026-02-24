//
//  HHTools.h
//  HSShareSDK
//
//  Created by aa on 2020/10/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^XMCompletioBlock)(NSDictionary *dic, NSURLResponse *response, NSError *error);
typedef void (^XMSuccessBlock)(NSDictionary *data);
typedef void (^XMFailureBlock)(NSError *error);
typedef void (^SuccessBlock)(NSString *urlString);


@interface HHTools : NSObject

+ (HHTools *)shareInstance;

@property (nonatomic,strong)NSString *hostUrl;

/**
 *  get请求
 */
+ (void)getWithUrlString:(NSString *)url parameters:(id)parameters success:(XMSuccessBlock)successBlock failure:(XMFailureBlock)failureBlock;

/**
 * post请求
 */
+ (void)postWithUrlString:(NSString *)url parameters:(id)parameters success:(XMSuccessBlock)successBlock failure:(XMFailureBlock)failureBlock;

//+(void)getAlidynAddress:(SuccessBlock)successBlock;

-(NSString*)getPasteboardString:(SuccessBlock)successBlock;

@end


