//
//  Constant.swift
//  CLEANER
//
//  Created by admin on 22/09/2019.
//  Copyright © 2019 SangNX. All rights reserved.
//

import Foundation
import UIKit

struct Constant {
    
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SAFE_TOP: CGFloat = SCREEN_HEIGHT >= 792 ? 44.0 : 20
    static let SAFE_BOTTOM: CGFloat = SCREEN_HEIGHT >= 792 ? 34.0 : 0
}
