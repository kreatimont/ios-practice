
import UIKit

extension UIColor{
    class func getCustomBlueColor() -> UIColor{
        return UIColor(red:0.86, green:0.73, blue:1.00, alpha:1.0)
    }
    
    class func getCustomGreenColor() -> UIColor{
        return UIColor(red: 0.80, green:0.95, blue:0.90 ,alpha:1.0)
    }
}

@IBDesignable class RatingControl: UIView {
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var bgColor: UIColor = UIColor.clear {
        didSet {
            layer.backgroundColor = bgColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
}
