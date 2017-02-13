//
//  NamedBezierPathsView.swift
//  DropIt
//
//  Created by Younoussa Ousmane Abdou on 2/12/17.
//  Copyright © 2017 Younoussa Ousmane Abdou. All rights reserved.
//

import UIKit

class NamedBezierPathsView: UIView {
    
    var bezierPaths = [String: UIBezierPath]() { didSet { setNeedsLayout() }}

    override func draw(_ rect: CGRect) {
        
        for (_, path) in bezierPaths {
            
            path.stroke()   
        }
    }

}
