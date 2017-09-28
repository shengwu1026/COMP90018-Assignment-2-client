
import Foundation
import UIKit

class TitleBarView : UIView {
    
    var title: String
    
    var delegate: TitleBarDelegate?
    
    var titleLabel: UILabel = UILabel()
    var leftButton: UIButton = UIButton()
    var rightButton: UIButton = UIButton()
    
    fileprivate var titleBarHeight: CGFloat = 50
    
    var leftImage: UIImage? {
        get {
            return leftButton.imageView?.image
        }
        set {
            leftButton.setImage(newValue, for: UIControlState())
        }
    }
    
    var rightImage: UIImage? {
        get {
            return rightButton.imageView?.image
        }
        set {
            rightButton.setImage(newValue, for: UIControlState())
        }
    }
    
    init(title: String, leftButtonImage: UIImage?, rightButtonImage: UIImage?) {
        self.title = title
        super.init(frame: CGRect.zero)
        
        configureGestureRecognizers()
        configureTitleLabel()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func configureTitleLabel() {
        self.titleLabel.text = self.title
    }
    
    fileprivate func configureConstraints() {
        
        var constraints = [NSLayoutConstraint]()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Attach the left button to the left
        constraints += equalityConstraintForView(leftButton, andAttribute: .left, withView: self, withConstant: 0)
        constraints += equalityConstraintForView(leftButton, andAttribute: .width, withView: nil, withConstant: 50)
        constraints += constraintsToContainViewVertically(leftButton, inContainingView: self)
        
        // Attach the right button to the right
        constraints += equalityConstraintForView(rightButton, andAttribute: .right, withView: self, withConstant: 0)
        constraints += equalityConstraintForView(rightButton, andAttribute: .width, withView: nil, withConstant: 50)
        constraints += constraintsToContainViewVertically(rightButton, inContainingView: self, withConstant: 0)
        
        // Attach the label to the middle
        constraints += equalityConstraintForView(titleLabel, andAttribute: .centerY, withView: self)
        constraints += equalityConstraintForView(titleLabel, andAttribute: .centerX, withView: self)
        
        // Set the height for the entire bar.
        constraints += equalityConstraintForView(self, andAttribute: .height, withView: nil, withConstant: titleBarHeight)
        
        self.addSubview(titleLabel)
        self.addSubview(leftButton)
        self.addSubview(rightButton)
        
        self.addConstraints(constraints)
    }
    
    fileprivate func configureGestureRecognizers() {
        
        let leftTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapLeftButton(_:)))
        let rightTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapRightButton(_:)))
        
        leftButton.addGestureRecognizer(leftTapGestureRecognizer)
        rightButton.addGestureRecognizer(rightTapGestureRecognizer)
    }
    
    func didTapLeftButton(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.didTapLeftButton()
    }
    
    func didTapRightButton(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.didTapRightButton()
    }
}

protocol TitleBarDelegate {
    func didTapLeftButton()
    func didTapRightButton()
}


