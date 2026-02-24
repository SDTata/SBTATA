//
//  EMASCurlWebPerformanceMonitor.m
//  EMASCurlWeb
//

#import "EMASCurlWebPerformanceMonitor.h"

@interface EMASCurlWebPerformanceMonitor ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *eventStartTimes;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *eventDurations;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *eventCounts;
@end

@implementation EMASCurlWebPerformanceMonitor

static EMASCurlWebPerformanceMonitor *sharedMonitor = nil;
static dispatch_queue_t s_monitorQueue = nil;

+ (void)load {
    // ✅ 在类加载时初始化队列，确保它总是可用
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_monitorQueue = dispatch_queue_create("com.emasculrweb.performancemonitor", DISPATCH_QUEUE_SERIAL);
    });
}

+ (EMASCurlWebPerformanceMonitor *)sharedMonitor {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMonitor = [[EMASCurlWebPerformanceMonitor alloc] init];
        // ✅ 队列已经在 +load 中初始化，这里不需要再初始化
    });
    return sharedMonitor;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _eventStartTimes = [NSMutableDictionary dictionary];
        _eventDurations = [NSMutableDictionary dictionary];
        _eventCounts = [NSMutableDictionary dictionary];
        _pageLoadStartTime = 0;
    }
    return self;
}

+ (void)recordEventStart:(NSString *)eventName forURL:(NSString *)url {
    // ✅ 验证参数有效性
    if (!eventName || !s_monitorQueue) {
        NSLog(@"⚠️ [PerformanceMonitor] Invalid parameters or queue not initialized");
        return;
    }

    dispatch_async(s_monitorQueue, ^{
        EMASCurlWebPerformanceMonitor *monitor = [self sharedMonitor];
        if (!monitor || !monitor.eventStartTimes) {
            return;
        }
        NSString *key = [NSString stringWithFormat:@"%@_%@", eventName, url ?: @"unknown"];
        monitor.eventStartTimes[key] = @([[NSDate date] timeIntervalSince1970] * 1000);
    });
}

+ (void)recordEventEnd:(NSString *)eventName forURL:(NSString *)url {
    // ✅ 验证参数有效性
    if (!eventName || !s_monitorQueue) {
        return;
    }

    dispatch_async(s_monitorQueue, ^{
        EMASCurlWebPerformanceMonitor *monitor = [self sharedMonitor];
        if (!monitor || !monitor.eventStartTimes) {
            return;
        }

        NSString *key = [NSString stringWithFormat:@"%@_%@", eventName, url ?: @"unknown"];

        NSNumber *startTime = monitor.eventStartTimes[key];
        if (!startTime) {
            NSLog(@"⚠️ [PerformanceMonitor] No start time recorded for event: %@", eventName);
            return;
        }

        NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] * 1000 - [startTime doubleValue];

        // Record duration
        NSMutableArray *durations = [NSMutableArray arrayWithArray:(NSArray *)monitor.eventDurations[eventName] ?: @[]];
        [durations addObject:@(duration)];
        monitor.eventDurations[eventName] = durations;

        // Increment count
        NSNumber *count = monitor.eventCounts[eventName] ?: @0;
        monitor.eventCounts[eventName] = @([count integerValue] + 1);

        // Log individual event
        NSLog(@"⏱️ [Performance] %@ took %.1fms for %@", eventName, duration,
              [url lastPathComponent] ?: @"resource");

        [monitor.eventStartTimes removeObjectForKey:key];
    });
}

+ (NSTimeInterval)timingForEvent:(NSString *)eventName {
    // ✅ 验证队列初始化
    if (!s_monitorQueue || !eventName) {
        return 0;
    }

    __block NSTimeInterval totalDuration = 0;
    dispatch_sync(s_monitorQueue, ^{
        EMASCurlWebPerformanceMonitor *monitor = [self sharedMonitor];
        if (!monitor || !monitor.eventDurations) {
            return;
        }
        NSArray *durations = monitor.eventDurations[eventName];
        for (NSNumber *duration in durations) {
            totalDuration += [duration doubleValue];
        }
    });
    return totalDuration;
}

+ (void)logPerformanceSummary {
    // ✅ 验证队列初始化
    if (!s_monitorQueue) {
        NSLog(@"⚠️ [PerformanceMonitor] Queue not initialized");
        return;
    }

    dispatch_async(s_monitorQueue, ^{
        EMASCurlWebPerformanceMonitor *monitor = [self sharedMonitor];
        if (!monitor || !monitor.eventDurations) {
            return;
        }

        NSLog(@"\n===============================================");
        NSLog(@"📊 [Performance Summary]");
        NSLog(@"===============================================");

        for (NSString *eventName in monitor.eventDurations) {
            NSArray *durations = monitor.eventDurations[eventName];
            NSNumber *count = monitor.eventCounts[eventName];

            if ([durations count] == 0) continue;

            NSTimeInterval totalDuration = 0;
            NSTimeInterval minDuration = INFINITY;
            NSTimeInterval maxDuration = 0;

            for (NSNumber *duration in durations) {
                NSTimeInterval dur = [duration doubleValue];
                totalDuration += dur;
                minDuration = MIN(minDuration, dur);
                maxDuration = MAX(maxDuration, dur);
            }

            NSTimeInterval avgDuration = totalDuration / [durations count];

            NSLog(@"  %@:", eventName);
            NSLog(@"    Count: %@", count);
            NSLog(@"    Total: %.1fms", totalDuration);
            NSLog(@"    Avg: %.1fms", avgDuration);
            NSLog(@"    Min: %.1fms, Max: %.1fms", minDuration, maxDuration);
        }

        NSLog(@"===============================================\n");
    });
}

+ (void)reset {
    // ✅ 验证队列初始化
    if (!s_monitorQueue) {
        return;
    }

    dispatch_async(s_monitorQueue, ^{
        EMASCurlWebPerformanceMonitor *monitor = [self sharedMonitor];
        if (!monitor) {
            return;
        }
        [monitor.eventStartTimes removeAllObjects];
        [monitor.eventDurations removeAllObjects];
        [monitor.eventCounts removeAllObjects];
        monitor.pageLoadStartTime = 0;
    });
}

@end
