//
//  TextView.swift
//  TrackYourGoals
//
//  Created by Ibrahim Jirdeh on 6/10/20.
//  Copyright © 2020 Anurag Pradhan. All rights reserved.
//

import Foundation
import SwiftUI

struct TextView : UIViewRepresentable {
    
    func makeCoordinator() -> TextView.Coordinator {
        return TextView.Coordinator(parent1: self)
    }
    
    @Binding var txt : String
    @State var editable: Bool
    
    func makeUIView(context: UIViewRepresentableContext<TextView>) -> UITextView{
        let view = UITextView()
        
        if self.txt != ""{
            view.text = self.txt
            view.textColor = .white
        }
        else{
            view.text = "Task Details"
            view.textColor = .gray
        }
        
        view.font = .systemFont(ofSize: 18)
        view.isEditable = editable
        view.backgroundColor = .clear
        view.delegate = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<TextView>) {
        
    }
    
    
    class Coordinator : NSObject,UITextViewDelegate{
        var parent : TextView
        
        init(parent1 : TextView) {
            parent = parent1
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if self.parent.txt == ""{
                textView.text = ""
                textView.textColor = .white
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.txt = textView.text
        }
    }
}
