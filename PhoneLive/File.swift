//
//  File.swift
//  phonelive2
//
//  Created by lucas on 2022/1/20.
//  Copyright © 2022 toby. All rights reserved.
//

import Foundation
import SwiftUI

@objc class DummySwiftUILoader: NSObject {
    @objc func preload() {
        let _ = Text("Hello").font(.body)
    }
}
