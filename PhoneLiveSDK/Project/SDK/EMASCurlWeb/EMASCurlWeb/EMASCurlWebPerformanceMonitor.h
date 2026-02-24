//
//  EMASCurlWebPerformanceMonitor.h
//  EMASCurlWeb
//
//  Performance monitoring and diagnostic logging for WKWebView/curl integration
//

#import <Foundation/Foundation.h>

/**
 * Performance monitoring for web view loading
 * Tracks timing at each stage of HTML/resource loading to identify bottlenecks
 */
@interface EMASCurlWebPerformanceMonitor : NSObject

/// Page loading start time (when startURLSchemeTask is first called)
@property (nonatomic, strong) NSString *pageURL;
@property (nonatomic, assign) NSTimeInterval pageLoadStartTime;

/// Track a specific event timing
+ (void)recordEventStart:(NSString *)eventName forURL:(NSString *)url;
+ (void)recordEventEnd:(NSString *)eventName forURL:(NSString *)url;

/// Log performance summary
+ (void)logPerformanceSummary;

/// Reset all metrics (call when page load completes)
+ (void)reset;

/// Get timing for specific event
+ (NSTimeInterval)timingForEvent:(NSString *)eventName;

@end
