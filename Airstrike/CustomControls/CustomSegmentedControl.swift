//
//  EverySegmentedControl.swift
//  Every
//
//  Created by lewisjkl on 8/3/16.
//  Copyright © 2016 Technophob. All rights reserved.
//

import UIKit

class CustomSegmentedControl: UISegmentedControl {
    
    var selectedBackgroundView: UIView?
    var leadingc: NSLayoutConstraint?
    var verticalc: NSLayoutConstraint?
    var widthc: NSLayoutConstraint?
    var heightc: NSLayoutConstraint?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        self.backgroundColor = .clear
        self.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        self.setBackgroundImage(UIImage(), for: .selected, barMetrics: .default)
        self.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        initializeSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func valueChanged(_ sender: UISegmentedControl) {
        let n = CGFloat(self.numberOfSegments)
        let s = CGFloat(self.selectedSegmentIndex) * (self.frame.width / n)
        UIView.animate(withDuration: 0.3) {
            guard let _ = self.selectedBackgroundView else { return }
            self.leadingc?.constant = s
            self.layoutIfNeeded()
        }
    }
    
    func initializeSubviews() {
        setColor(self.tintColor)
        
        let n = CGFloat(self.numberOfSegments)
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = self.tintColor
        selectedBackgroundView?.translatesAutoresizingMaskIntoConstraints = false
        if let s = selectedBackgroundView {
            self.addSubview(s)
            leadingc = NSLayoutConstraint(item: s, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leadingMargin, multiplier: 1.0, constant: 0.0)
            verticalc = s.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 2.0)
            widthc = NSLayoutConstraint(item: s, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 1 / n, constant: -16.0)
            heightc = NSLayoutConstraint(item: s, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 2.0)
            guard let lc = leadingc, let wc = widthc, let vc = verticalc, let hc = heightc else { return }
            NSLayoutConstraint.activate([lc, wc, hc, vc])
        }
    }
    
    func setColor(_ color: UIColor) {
        self.tintColor = color
        selectedBackgroundView?.backgroundColor = color
        let unselectedColor = UIColor(colorLiteralRed: Float(color.components.red), green: Float(color.components.green), blue: Float(color.components.blue), alpha: 0.70)
        self.setTitleTextAttributes([NSForegroundColorAttributeName:unselectedColor, NSFontAttributeName:UIFont.systemFont(ofSize: 13.0, weight: UIFontWeightRegular)], for: .normal)
        self.setTitleTextAttributes([NSForegroundColorAttributeName:color, NSFontAttributeName:UIFont.systemFont(ofSize: 13.0, weight: UIFontWeightRegular)], for: .selected)
    }
    
    
    func didRotateTo(size: CGSize) {
        let n = CGFloat(self.numberOfSegments)
        let s = CGFloat(self.selectedSegmentIndex) * (size.width / n)
        UIView.animate(withDuration: 0.3) {
            guard let _ = self.selectedBackgroundView else { return }
            self.leadingc?.constant = s
            self.layoutIfNeeded()
        }
        
    }
    
    func makeSegmentsImagesWithText(imagesWithText: (UIImage, String)...) {
        guard imagesWithText.count <= self.numberOfSegments else { return }
        var i = 0
        for imageWithText in imagesWithText {
            guard let imageWithText = CustomSegmentedControl.embedTextInImage(image: imageWithText.0, string: imageWithText.1, color: tintColor) else {
                i += 1
                continue
            }
            self.setImage(imageWithText, forSegmentAt: i)
            i += 1
        }
    }
    
    
    static func embedTextInImage(image: UIImage, string: String, color: UIColor, imageAlignment: Int = 0, segFont: UIFont? = nil) -> UIImage? {
        
        let font = segFont ?? UIFont.systemFont(ofSize: 16.0)
        
        let expectedTextSize: CGSize = (string as NSString).size(attributes: [NSFontAttributeName: font])
        
        let width: CGFloat = expectedTextSize.width + image.size.width + 5.0
        
        let height: CGFloat = max(expectedTextSize.height, image.size.width)
        
        let size: CGSize = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(color.cgColor)
        
        let fontTopPosition: CGFloat = (height - expectedTextSize.height) / 2.0
        
        let textOrigin: CGFloat = (imageAlignment == 0) ? image.size.width + 5 : 0
        let textPoint: CGPoint = CGPoint(x: textOrigin, y: fontTopPosition)
        
        
        string.draw(at: textPoint, withAttributes: [NSFontAttributeName: font])
        let flipVertical: CGAffineTransform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
        context.concatenate(flipVertical)
        
        let alignment: CGFloat =  (imageAlignment == 0) ? 0.0 : expectedTextSize.width + 5.0
        let newRect = CGRect(x: alignment, y: ((height - image.size.height) / 2.0), width: image.size.width, height: image.size.height)
        guard let cgi = image.cgImage else { return .none }
        context.draw(cgi, in: newRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let color = coreImageColor
        return (color.red, color.green, color.blue, color.alpha)
    }
}
