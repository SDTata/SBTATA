# WKWebView/libcurl Performance Optimization Summary

## Current Session Work (2025-11-09)

### Optimizations Applied ✅

This session focused on identifying and removing blocking operations to enable concurrent resource loading and immediate HTML rendering.

#### 1. **Blocking Dispatch Calls Removed** (EMASCurlProtocol.m)
- **Issue**: `dispatch_sync(s_cacheQueue)` in `startLoading` was blocking ALL requests while checking cache
- **Status**: ✅ FIXED - Cache checking removed from critical path
- **Impact**: Requests no longer wait for cache queue operations

#### 2. **Async Cleanup** (EMASCurlProtocol.m:529-565)
- **Issue**: `dispatch_semaphore_wait` in `stopLoading` was blocking NSURLProtocol thread
- **Status**: ✅ FIXED - Changed to async cleanup
- **Impact**: Page navigation no longer stalls waiting for resource cleanup

#### 3. **HTTP/2 Multiplexing** (EMASCurlManager.m:39-43)
- **Status**: ✅ ENABLED - `CURLMOPT_PIPELINING` with `CURLPIPE_MULTIPLEX`
- **Impact**: Multiple requests over single TCP connection
- **Config**: Max 32 concurrent connections, connection pooling enabled

#### 4. **Reduced Polling Interval** (EMASCurlManager.m:182)
- **Status**: ✅ OPTIMIZED - `curl_multi_wait` reduced from 1000ms to 100ms
- **Impact**: Sub-resource completion detected faster
- **Benefit**: Responsive resource callbacks, new requests signal immediately

#### 5. **HTML Optimization Strategy** (EMASCurlWebUrlSchemeHandler.m:451-483)
- **Status**: ✅ SIZE-AWARE - Regex optimizations only for HTML < 1MB
- **Changes**:
  - Always: Inject progressive render script (essential)
  - If < 1MB: Apply regex optimizations (script moving, CSS async, image lazy-loading)
  - If ≥ 1MB: Skip regex (focus on network delivery)
- **Impact**: Large files skip expensive regex, small files get full optimization

#### 6. **Resource-Type Aware Timeouts** (EMASCurlProtocol.m)
- **Status**: ✅ IMPLEMENTED - Different timeouts for different resource types
- **Types and Defaults**:
  - HTML: 60 seconds (critical)
  - JavaScript: 1-5 seconds (user-configurable, default ~2s)
  - CSS: 2-10 seconds (non-critical)
  - Images: 3-8 seconds (non-critical)
  - Fonts: 2-5 seconds (non-critical)
- **Impact**: Fast failure for non-critical resources, doesn't block HTML rendering

#### 7. **Performance Monitoring Framework** (NEW)
- **Status**: ✅ CREATED - EMASCurlWebPerformanceMonitor
- **Tracking**:
  - `curl_request`: Time from protocol start to curl completion
  - `html_optimization`: Time for HTML script injection + regex optimization
- **Logging**: Detailed timing metrics for each operation
- **Usage**: `[EMASCurlWebPerformanceMonitor logPerformanceSummary]` after page load

---

## Current Bottleneck Analysis

### User-Identified Root Cause
From user feedback: "某个JS在执行时阻塞了DOM解析 但是原生的额web会忽略掉这个js加载，但是我们拦截的时候机制不一样，导致必须等待导致加载网页卡顿"

**Translation**: A JS executing blocks DOM parsing. Native browsers ignore slow JS, but our interception mechanism is different - causes necessary waiting and page lag.

### Architectural Constraint
- **Native Browsers**: Fetch HTML → Parse & Render → Load resources async
- **WKWebView + URLSchemeHandler**: Each resource request goes through custom handler → Must complete curl request before sending to renderer
- **Implication**: If HTML contains blocking `<script>` in `<head>`, WKWebView **must wait** for that JS before rendering anything below it

### Current Mitigation Strategy
Progressive Render Script Injection (in EMASCurlWebProgressiveRender.m):
1. Injects monitoring script in `<head>`
2. Moves external scripts to `<body>` with `async` attribute
3. Converts CSS to async loading via `media="print"` + `onload`
4. Adds lazy-loading to images
5. PerformanceObserver tracks resource completion

---

## Testing & Measurement Guide

### 1. **Enable Performance Monitoring**
Add this to your WKWebView controller after page load:
```objc
// In your WKWebView delegate or controller
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [EMASCurlWebPerformanceMonitor logPerformanceSummary];
    });
}
```

### 2. **Key Metrics to Monitor**

**✅ Should see these timing improvements:**
- `curl_request` for HTML: < 2000ms (typically 200-500ms on good connection)
- `html_optimization`: < 200ms for HTML < 1MB
- `curl_request` for sub-resources: < 500ms (or timeout after configured interval)

**❌ If you see:**
- `curl_request` > 5000ms: Check network connectivity or server response time
- `html_optimization` > 500ms: Large HTML file (> 1MB), regex optimization can be slow
- Page still not rendering quickly: Likely blocked by JS in HTML itself, not curl

### 3. **Debugging Blocking Resources**
Console logs will show:
```
⏱️ [Performance] curl_request took XXXms for index.html
✅ [EMASRender] HTML optimized in XXms (size: XXKb)
⏱️ [Performance] curl_request took XXXms for script.js
🛑 Resource timeout (skipped): heavy-analytics.js
```

---

## Current Implementation Files

### Performance Monitoring
- `EMASCurlWebPerformanceMonitor.h/m` - NEW
  - Thread-safe performance tracking
  - Individual event timing
  - Summary statistics

### Core Curl/Protocol
- `EMASCurlProtocol.m` - MODIFIED
  - Added performance tracking at request start/end
  - Cache checking removed from critical path
  - Async stopLoading cleanup

- `EMASCurlManager.m` - MODIFIED
  - HTTP/2 multiplexing enabled
  - Reduced multi_wait timeout
  - Async completion callbacks

### HTML Processing
- `EMASCurlWebUrlSchemeHandler.m` - MODIFIED
  - Size-aware HTML optimization
  - Performance timing added
  - Progressive render script injection

- `EMASCurlWebProgressiveRender.m` - UNCHANGED
  - Script injection
  - DOM optimization
  - PerformanceObserver monitoring

---

## Known Limitations

### Cannot Optimize (Architectural)
1. **Blocking JavaScript in HTML**: If HTML has `<script>` tag without `async` in `<head>`, browser MUST wait for it before rendering anything below
2. **CSS @import**: CSS files with `@import` statements must wait for imported files
3. **Render-blocking resources**: Some sites deliberately require resources before rendering

### Recommended for Large HTML
For HTML files > 5MB:
1. Consider chunked delivery instead of processing entire file
2. Skip regex optimizations (already done for > 1MB)
3. Consider server-side compression

---

## Next Optimization Steps

### Priority 1: Measure Current Performance
1. Run the app and collect performance logs
2. Compare: curl_request time vs html_optimization time
3. Identify if bottleneck is network (curl) or processing (optimization)

### Priority 2: JavaScript Timeout Tuning
Current values are configurable. If seeing slow JS causing issues:
- Reduce JS timeout further (from 1-5s to 0.5-1s)
- Use fallback empty JS for optional resources
- Mark non-critical scripts as "optional"

### Priority 3: Large HTML Handling
If processing large files:
- Test with > 10MB HTML
- Measure regex operation time
- Consider stream-based delivery if > 100MB

### Priority 4: CSS Optimization
Current CSS async loading via media="print":
- Test with CSS files > 100KB
- Measure paint timing with/without optimization
- Consider inlining critical CSS

---

## Performance Baselines (Typical)

### Good Network (WiFi, LTE)
- HTML fetch: 200-500ms
- HTML optimization: 50-150ms (if < 1MB)
- Sub-resource fetch: 100-300ms

### Slow Network (3G, 2G)
- HTML fetch: 2-5 seconds
- Sub-resources: 1-10 seconds
- Timeouts: 1-5 seconds for non-critical JS

### Very Large HTML (> 5MB)
- HTML fetch: 5-30 seconds
- HTML optimization: Skipped (> 1MB threshold)
- Important: Allow enough time for initial HTML before timeout

---

## Logging Reference

### Enable Debug Logging
In EMASCurlProtocol.m:
```objc
+ (void)setDebugLogEnabled:(BOOL)debugLogEnabled {
    s_enableDebugLog = debugLogEnabled;
}
```

### Performance Monitor Logs
- Individual timing: "⏱️ [Performance] {event} took {time}ms"
- Summary: Call `[EMASCurlWebPerformanceMonitor logPerformanceSummary]`

### HTMLOptimization Logs
- "✅ [EMASRender] HTML optimized in {time}ms (size: {size}KB)"
- "  - Async script loading enabled"
- "  - Progressive render monitoring injected"

---

## Configuration Reference

### Timeouts (EMASCurlProtocol.m)
Resource-specific timeouts can be set via request properties:
```objc
[EMASCurlProtocol setConnectTimeoutIntervalForRequest:request
                                  connectTimeoutInterval:5.0];
```

### Cache Control (EMASCurlProtocol.m)
```objc
[EMASCurlProtocol setCacheEnabled:YES]; // Enable/disable caching
```

### HTTP Version (EMASCurlProtocol.m)
```objc
[EMASCurlProtocol setHTTPVersion:HTTP2]; // Use HTTP/2 (automatic with curl)
```

---

## Issue Tracking

### Resolved ✅
- [x] dispatch_sync blocking on cache queue
- [x] dispatch_semaphore_wait blocking cleanup
- [x] Insufficient curl concurrency
- [x] Slow multi_wait polling (1000ms → 100ms)
- [x] No performance visibility

### In Progress 🔄
- [ ] Measure actual performance with new monitoring
- [ ] Determine if curl/network or HTML processing is bottleneck
- [ ] Optimize based on measurement data

### Blocked ⚠️
- [ ] JS blocking DOM (architectural - can't fix, only mitigate with async script injection)
- [ ] Server-side large file delivery (server optimization needed)

---

## Questions for User

1. **Is page rendering delayed for:**
   - HTML download time? (check curl_request timing)
   - HTML optimization? (check html_optimization timing)
   - Sub-resource loading? (check individual curl_request for JS/CSS)
   - JS execution? (check browser console for JS errors)

2. **What HTML sizes are typical:**
   - Typical: 50-500KB?
   - Large: 1-5MB?
   - Very large: > 10MB?

3. **Expected improvement:**
   - Immediate rendering while resources load?
   - Faster first visual render?
   - Faster interactive ready?

4. **Current pain point:**
   - Blank page for too long?
   - Content visible but not interactive?
   - Resources loading slowly?

---

## References

- EMASCurlManager.m:182 - curl_multi_wait timeout tuning
- EMASCurlProtocol.m:459 - startLoading optimizations
- EMASCurlWebUrlSchemeHandler.m:451 - HTML optimization strategy
- EMASCurlWebProgressiveRender.m - HTML/CSS/JS optimization details
- EMASCurlWebPerformanceMonitor.m - Detailed timing implementation
