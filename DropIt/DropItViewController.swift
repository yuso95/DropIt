//
//  DropItViewController.swift
//  DropIt
//
//  Created by Younoussa Ousmane Abdou on 2/12/17.
//  Copyright © 2017 Younoussa Ousmane Abdou. All rights reserved.
//

import UIKit

class DropItViewController: UIViewController {

    @IBOutlet private weak var gameView: DropItView! {
        didSet {
            
            gameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.addDrop(_:))))
            gameView.addGestureRecognizer(UIPanGestureRecognizer(target: gameView, action: #selector(DropItView.grabDrop(_:))))
            gameView.realGravity = true
        }
    }
    
    func addDrop(_ recognizer: UITapGestureRecognizer) {
        
        if recognizer.state == .ended {
            
            gameView.addDrop()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        gameView.animating = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        gameView.animating = false
    }
    
}
