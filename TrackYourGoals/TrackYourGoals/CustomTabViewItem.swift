//
//  CustomTabViewItem.swift
//  TrackYourGoals
//
//  Created by Anurag Pradhan on 6/2/20.
//  Copyright © 2020 Anurag Pradhan. All rights reserved.
//

import Foundation
import SwiftUI

struct CustomTabViewItem: View {
    var tabName: String = ""
    var width: CGFloat
    var foregroundColor: Color
    var onTapGesture: () -> ()
    
    var body: some View {
        Text(tabName)
            .frame(width: width, height: 75)
            .foregroundColor(foregroundColor)
            .onTapGesture {
                self.onTapGesture()
        }
    }
}
