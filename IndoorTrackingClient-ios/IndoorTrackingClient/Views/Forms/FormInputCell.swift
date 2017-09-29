
import Foundation
import UIKit

class PaddedLabel : UILabel {
    
    var leftPadding: CGFloat = 4
    var rightPadding: CGFloat = 4
    
    var topPadding: CGFloat = 3
    var bottomPadding: CGFloat = 3
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override var intrinsicContentSize : CGSize {
        var size = super.intrinsicContentSize
        size.width  += self.leftPadding + self.rightPadding
        size.height += self.topPadding + self.bottomPadding
        return size
    }
}

class FormInputCell : UITableViewCell {
    var id: String = "UNKN"
    
    var name: String = "UNKN" {
        didSet {
            inputNameLabel.text = name
        }
    }
    
    var placeholder: String? = "" {
        didSet {
            setPlaceholderText(placeholder!)
        }
    }
    
    var currentValue: String? {
        get {
            return (inputTextField.text == "") ? nil : inputTextField.text
        }
    }
    
    fileprivate var inputNameLabel: UILabel = PaddedLabel()
    fileprivate var inputTextField: UITextField = UITextField()
    
    var delegate: FormInputCellDelegate!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.preservesSuperviewLayoutMargins = false
        self.separatorInset = UIEdgeInsets.zero
        self.layoutMargins = UIEdgeInsets.zero
        
        //setup constraints
        configureNameLabel()
        configureTextField()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDefaultValue(text: String) {
        self.inputTextField.text = text
    }
    
    func takeFocus() {
        inputTextField.becomeFirstResponder()
    }
    
    func dropFocus() {
        inputTextField.resignFirstResponder()
    }
    
    func clear() {
        self.inputTextField.text = String()
    }
    
    fileprivate func configureNameLabel() {
        inputNameLabel.text = name
        
        inputNameLabel.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        inputNameLabel.layer.cornerRadius = 5
        inputNameLabel.layer.masksToBounds = true
        inputNameLabel.setContentHuggingPriority(1000, for: UILayoutConstraintAxis.horizontal)
        
        inputNameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        inputNameLabel.textColor = UIColor.white
    }
    
    fileprivate func configureTextField() {
        inputTextField.textAlignment = .right
        inputTextField.font = UIFont.systemFont(ofSize: 16, weight: 0)
        inputTextField.textColor = UIColor.white
        
        inputTextField.autocorrectionType = .no
        inputTextField.autocapitalizationType = .none
        
        inputTextField.delegate = self
        
        inputTextField.returnKeyType = .done
        
        setPlaceholderText(placeholder!)
    }
    
    fileprivate func setPlaceholderText(_ text: String) {
        inputTextField.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName : UIColor.lightGray])
    }
    
    fileprivate func configureConstraints() {
        
        inputNameLabel.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        
        // Attach the input name label to the left hand side.
        constraints += constraintsToContainViewVertically(inputNameLabel, inContainingView: self.contentView, withConstant: 7.5)
        constraints += equalityConstraintForView(inputNameLabel, andAttribute: .left, withView: self.contentView, withConstant: 10)
        
        // Attach the input text field to the right of the cell and to the left of the label.
        constraints += constraintsToContainViewVertically(inputTextField, inContainingView: self.contentView)
        constraints += constraintToAttachLeftView(inputNameLabel, toRightView: inputTextField)
        constraints += equalityConstraintForView(inputTextField, andAttribute: .right, withView: self.contentView, withConstant: -10)
        
        self.contentView.addSubview(inputNameLabel)
        self.contentView.addSubview(inputTextField)
        
        self.contentView.addConstraints(constraints)
    }
}

extension FormInputCell : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate.didBecomeActiveForCell(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate.enterKeyWasPressed()
        return false
    }
}

protocol FormInputCellDelegate {
    func didBecomeActiveForCell(_ cell: FormInputCell)
    func enterKeyWasPressed()
}


