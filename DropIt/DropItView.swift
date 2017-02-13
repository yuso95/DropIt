//
//  DropItView.swift
//  DropIt
//
//  Created by Younoussa Ousmane Abdou on 2/12/17.
//  Copyright © 2017 Younoussa Ousmane Abdou. All rights reserved.
//

import UIKit
import CoreMotion

class DropItView: NamedBezierPathsView, UIDynamicAnimatorDelegate {
    
    private struct PathNames {
        
        static let MiddleBarrier = "CircleBarrier"
        static let Attachment = "Attachment"
    }
    
    private lazy var animator: UIDynamicAnimator = {
        
        let animator = UIDynamicAnimator(referenceView: self)
        animator.delegate = self
        return animator
    }()
    
    private let dropBehavior = FallingObjectBehavior()
    
    var animating: Bool = false {
        didSet {
            if animating {
                
                animator.addBehavior(dropBehavior)
                updateRealGravity()
            } else {
                
                animator.removeAllBehaviors()
            }
        }
    }
    
    private var attachment: UIAttachmentBehavior? {
        willSet {
            
            if attachment != nil {
                
                animator.removeBehavior(attachment!)
                bezierPaths[PathNames.Attachment] = nil
            }
        }
        didSet {
            if attachment != nil {
                
                animator.addBehavior(attachment!)
                attachment?.action = { [unowned self ] in
                    if let attachedDrop = self.attachment?.items.first as? UIView {
                        self.bezierPaths[PathNames.Attachment] = UIBezierPath.lineFrom(from: self.attachment!.anchorPoint, to: attachedDrop.center)
                        
                    }
                }
            }
        }
    }
    
    private var lastDrop: UIView?
    
    var realGravity: Bool = false {
        didSet {
            
            updateRealGravity()
        }
    }
    
    private let motionManager = CMMotionManager()
    
    private func updateRealGravity() {
        if realGravity {
            if motionManager.isAccelerometerAvailable && !motionManager.isAccelerometerActive {
                motionManager.accelerometerUpdateInterval = 0.25
                motionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: { [unowned self] (data, error) in
                    if self.dropBehavior.dynamicAnimator != nil {
                        
                        if var dx = data?.acceleration.x, var dy = data?.acceleration.y {
                            switch UIDevice.current.orientation {
                            case .portrait: dy = -dy
                            case .portraitUpsideDown: break
                            case .landscapeRight: swap(&dx, &dy)
                            case .landscapeLeft: swap(&dx, &dy); dy = -dy
                            default: dx = 0; dy = 0
                                
                                self.dropBehavior.gravity.gravityDirection = CGVector(dx: dx, dy: dy)
                            }
                        } else {
                            
                            self.motionManager.stopAccelerometerUpdates()
                        }}
                })
            }
            
        } else {
            
            motionManager.stopAccelerometerUpdates()
        }
        
    }
    
    private let dropPerRow = 10
    
    private var dropSize: CGSize {
        
        let size = bounds.size.width / CGFloat(dropPerRow)
        return CGSize(width: size, height: size)
    }
    
    private func removeCompletedRow() {
        
        var dropsToRemove = [UIView]()
        var hitTestRect = CGRect(origin: bounds.lowerLeft, size: dropSize)
        
        repeat {
            hitTestRect.origin.x = bounds.minX
            hitTestRect.origin.y -= dropSize.height
            var dropsTested = 0
            var dropsFounds = [UIView]()
            while dropsTested < dropPerRow {
                if let hitView = hitTest(p: hitTestRect.mid), hitView.superview == self {
                    dropsFounds.append(hitView)
                } else {
                    break
                }
                
                hitTestRect.origin.x += dropSize.width
                dropsTested += 1
            }
            
            if dropsTested == dropPerRow {
                
                dropsToRemove += dropsFounds
            }
            
        } while dropsToRemove.count == 0 && hitTestRect.origin.y > bounds.minY
        
        for drop in dropsToRemove {
            dropBehavior.removeItem(item: drop)
            drop.removeFromSuperview()
        }
    }
    
    func addDrop() {
        
        var frame = CGRect(origin: CGPoint.zero, size: dropSize)
        frame.origin.x = CGFloat.random(max: dropPerRow) * dropSize.width
        
        let drop = UIView(frame: frame)
        drop.backgroundColor = UIColor.random
        
        addSubview(drop)
        dropBehavior.addItem(item: drop)
        lastDrop = drop
    }
    
    // MARK: - UIDynamicAnimatorDelegate
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        
        removeCompletedRow()
    }
    
    // MARK: - View
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath(ovalIn: CGRect(center: bounds.mid, size: dropSize))
        dropBehavior.addBarrier(path: path, named: PathNames.MiddleBarrier)
        
        // Not Working
        // bezierPaths[PathNames.MiddleBarrier] = path
    }
    
    // Mark: - GestureRecognizer
    
    func grabDrop(_ recognizer: UIPanGestureRecognizer) {
        
        let gesturePoint = recognizer.location(in: self)
        
        switch recognizer.state {
        case .began:
            // Create the attachment
            
            if let dropToAttachTo = lastDrop, dropToAttachTo.superview != nil {
                
                attachment = UIAttachmentBehavior(item: dropToAttachTo, attachedToAnchor: gesturePoint)
            }
            
            lastDrop = nil
        case .ended:
            // Change the attachment's anchor point
            
            attachment?.anchorPoint = gesturePoint
        default: attachment = nil
        }
    }
}
