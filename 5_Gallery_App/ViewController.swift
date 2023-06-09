//
//  ViewController.swift
//  5_Gallery_App
//
//  Created by apple on 17.04.2023.
//

import UIKit

class ViewController: UIViewController {
    
    var gallery = [#imageLiteral(resourceName: "alejandro.jpg"),#imageLiteral(resourceName: "demi.jpg"), #imageLiteral(resourceName: "francesco.jpg"), #imageLiteral(resourceName: "frida.jpg"), #imageLiteral(resourceName: "gary.jpg"), #imageLiteral(resourceName: "gwen.jpg"), #imageLiteral(resourceName: "kar.jpg"), #imageLiteral(resourceName: "marc.jpg"), #imageLiteral(resourceName: "kevin.jpg"), #imageLiteral(resourceName: "ricky.jpg")]

    @IBOutlet weak var trashImageView: UIImageView!
    
    var nextIndex = 0
    var currentPicture: UIImageView?
    var originSize: CGFloat = 300
    var isActive = false
    var activeSze: CGFloat {
        return originSize + 10
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNextPicture()
    }
    
    func showNextPicture() {
        if let newPicture = createPicture() {
            currentPicture = newPicture
            showPicture(newPicture)
            
            //tap gesture
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            newPicture.addGestureRecognizer(tap)
            
            //swipe gesture
            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
            swipe.direction = .up
            newPicture.addGestureRecognizer(swipe)
            
            //pan gesture
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            pan.delegate = self
            newPicture.addGestureRecognizer(pan)
        } else {
            nextIndex = 0
            showNextPicture()
        }
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let view = currentPicture, isActive else { return }
        
        switch sender.state {
        case .began, .changed:
            processPictureMovement(sender: sender, view: view)
        case .ended:
            if view.frame.intersects(trashImageView.frame){
                deletePicture(imageView: view)
            }
        default: break
        }
    }
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        guard !isActive else { return }
        hidePicture(currentPicture!)
        showNextPicture()
    }
    
    @objc func handleTap() {
        isActive = !isActive
        
        if isActive {
            activateCurrentPicture()
        } else {
            deactivateCurrentPicture()
        }
    }
    
    func processPictureMovement(sender: UIPanGestureRecognizer, view: UIImageView) {
        let translation = sender.translation(in: view)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        sender.setTranslation(.zero, in: view)
        
        if view.frame.intersects(trashImageView.frame) {
            view.layer.borderColor = UIColor.red.cgColor
        } else {
            view.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    func deletePicture(imageView: UIImageView) {
        self.gallery.remove(at: nextIndex - 1)
        isActive = false
        
        UIView.animate(withDuration: 0.4) {
            imageView.alpha = 0
        } completion: { (_) in
            imageView.removeFromSuperview()
        }
        showNextPicture()
    }
    
    //Tap Ivent
    func activateCurrentPicture() {
        UIView.animate(withDuration: 0.3) {
            self.currentPicture?.frame.size = CGSize(width: self.activeSze, height: self.activeSze)
            self.currentPicture?.layer.shadowOpacity = 0.5
            self.currentPicture?.layer.borderColor = UIColor.green.cgColor
        }
    }
    
    func deactivateCurrentPicture() {
        UIView.animate(withDuration: 0.3) {
            self.currentPicture?.frame.size = CGSize(width: self.originSize, height: self.originSize)
            self.currentPicture?.layer.shadowOpacity = 0
            self.currentPicture?.layer.borderColor = UIColor.darkGray.cgColor
        }
        
    }
    
    func createPicture() ->UIImageView? {
        guard nextIndex < gallery.count else {return nil}
        let imageView = UIImageView(image: gallery[nextIndex])
        imageView.frame = CGRect(x: self.view.frame.width, y: self.view.center.y - (originSize / 2), width: originSize, height: originSize)
        imageView.isUserInteractionEnabled = true
        
        //Shadow
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0
        imageView.layer.shadowOffset = .zero
        imageView.layer.shadowRadius = 10
        
        //Frame
        imageView.layer.borderWidth = 2
        imageView.layer.backgroundColor = UIColor.darkGray.cgColor
        
        
        nextIndex += 1
        return imageView
    }
    
    func showPicture(_ imageView: UIImageView) {
        self.view.addSubview(imageView)
        
        UIView.animate(withDuration: 0.4) {
            imageView.center = self.view.center
        }
    }
    
    func hidePicture(_ imageView: UIImageView) {
       
        UIView.animate(withDuration: 0.4) {
            self.currentPicture?.frame.origin.y = -self.originSize
        } completion: { (_) in
            imageView.removeFromSuperview()
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

