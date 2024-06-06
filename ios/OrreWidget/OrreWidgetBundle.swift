//
//  OrreWidgetBundle.swift
//  OrreWidget
//
//  Created by 정민호 on 5/9/24.
//

#if !os(macOS)
import WidgetKit
import SwiftUI

@main
struct OrreWidgetBundle: WidgetBundle {
    var body: some Widget {
        OrreWidget()
        OrreWidgetLiveActivity()
    }
}
#endif
