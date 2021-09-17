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
    }
}
