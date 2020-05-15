import UIKit
import SnapKit

// название UIView говорит о том, что здесь объявлена UIView? тогда UIView+Extensions
extension UIView {
  // объявлены safeArea_Some_Anchor, которые нигде не используются
    // Top Anchor
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor // self можно опустить. и так понятно, о чем речь
        } else {
            return self.topAnchor
        }
    }
    
    // Bottom Anchor
    var safeAreaBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
    
    // Left Anchor
    var safeAreaLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leftAnchor
        } else {
            return self.leftAnchor
        }
    }
    
    // Right Anchor
    var safeAreaRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.rightAnchor
        } else {
            return self.rightAnchor
        }
    }
    
    var safeArea: ConstraintLayoutGuideDSL {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.snp
        }
        
        return self.layoutMarginsGuide.snp
    }
}


extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach({
            addSubview($0)
        })
    }
    
    func setRounded(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func setRounded(radius: CGFloat = 8) {
        layer.cornerRadius = radius
    }
}
