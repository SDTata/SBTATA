// RyukieSwiftyCompat.swift
// 用于解决RyukieSwifty库的架构兼容性问题

import Foundation
import UIKit

// 这个扩展用于覆盖RyukieSwifty库中的架构检测方法
extension SwiftyDefine.Device {
    // 重新定义isSimulator属性，使用targetEnvironment而不是arch
    @objc public static var isSimulatorCompat: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}

// 添加一个运行时方法交换，用于替换原始的isSimulator实现
@objc class RyukieSwiftyCompat: NSObject {
    @objc static func setupCompat() {
        // 这里我们不进行实际的方法交换，因为Swift不支持直接的方法交换
        // 但我们可以在需要使用isSimulator的地方使用isSimulatorCompat
        print("RyukieSwifty架构兼容层已加载")
    }
}
