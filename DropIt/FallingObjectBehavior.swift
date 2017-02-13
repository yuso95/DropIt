//
//  FallingObjectBehavior.swift
//  DropIt
//
//  Created by Younoussa Ousmane Abdou on 2/12/17.
//  Copyright © 2017 Younoussa Ousmane Abdou. All rights reserved.
//

import UIKit

class FallingObjectBehavior: UIDynamicBehavior {
    
    
    let gravity = UIGravityBehavior()
    
    private let collider: UICollisionBehavior = {
        
        let collider = UICollisionBehavior()
        collider.translatesReferenceBoundsIntoBoundary = true
        return collider
    }()
    
    private let itemBehavior: UIDynamicItemBehavior = {
        
       let dib = UIDynamicItemBehavior()
        dib.allowsRotation = false
        dib.elasticity = 0.75
        return dib
    }()
    
    override init() {
        super.init()
        
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(itemBehavior)
    }
    
    func addItem(item: UIDynamicItem) {
        
        gravity.addItem(item)
        collider.addItem(item)
        itemBehavior.addItem(item)
    }
    
    func removeItem(item: UIDynamicItem) {
        
        gravity.removeItem(item)
        collider.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    func addBarrier(path: UIBezierPath, named: String) {
        collider.removeAllBoundaries()
        collider.addBoundary(withIdentifier: named as NSCopying, for: path)
    }
}
