//
//  HudView.swift
//  MyLocations
//
//  Created by Josue Mendoza on 9/17/21.
//

import UIKit

class HudView: UIView {
    var text = ""
    //This method is for the design of the hud
    class func hud(inview view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        hudView.show(animated: animated)

        return hudView
    }
    //This method is for the square icon on the hud
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)
        
        let  roundedRect = UIBezierPath(
            roundedRect: boxRect,
            cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        //This local constant uses the Checkmark Icon in the Assett folder and places it inside the hud
        if let image = UIImage(named: "Checkmark")
        {
            let imagePoint = CGPoint(x: center.x - round(image.size.width / 2),
                                     y: center.y - round(image.size.height / 2)
                                        - boxHeight / 8)
            image.draw(at: imagePoint)
        }
        
        //This local constant places the text inside the hud under the Checkmark Icon
        let attribs = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor:UIColor.white]
        
        let textSize = text.size(withAttributes: attribs)
        
        let textPoint = CGPoint(x: center.x - round(textSize.width / 2),
                                y: center.y - round(textSize.height / 2)
                                   + boxHeight / 4)
        
        text.draw(at: textPoint, withAttributes: attribs)
    }
    
    //MARK: - HELPER METHODS
    //This method gives a bounce/appear animation to the hud, instead of just appearing
    func show(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.5,
                options: [],
                animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    
    func hide() {
        superview?.isUserInteractionEnabled = true
        removeFromSuperview()
    }
}
