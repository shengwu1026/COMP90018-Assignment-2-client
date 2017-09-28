
import Foundation
import UIKit

// Some global helper functions to make creating constraints a little bit easier.
// Let's us write constraints like:
// let constraints = [NSLayoutConstraint]()
// constraints += constraintsToContainView(...)
// constraints += equalityConstraintForView(...)
// view.addConstraints(constraints)

func constraintToAttachLeftView(_ leftView: UIView, toRightView rightView: UIView, withConstant constant: CGFloat = 0) -> [NSLayoutConstraint] {
    
    let attachmentConstraint = NSLayoutConstraint(
        item: leftView,
        attribute: NSLayoutAttribute.right,
        relatedBy: NSLayoutRelation.equal,
        toItem: rightView,
        attribute: NSLayoutAttribute.left,
        multiplier: 1,
        constant: -constant)
    
    return [attachmentConstraint]
}

func constraintsToContainViewVertically(_ view: UIView, inContainingView containingView: UIView, withConstant constant: CGFloat = 0) -> [NSLayoutConstraint] {
    
    let topConstraint = NSLayoutConstraint(
        item: containingView,
        attribute: NSLayoutAttribute.top,
        relatedBy: NSLayoutRelation.equal,
        toItem: view,
        attribute: NSLayoutAttribute.top,
        multiplier: 1,
        constant: -constant)
    
    let bottomConstraint = NSLayoutConstraint(
        item: containingView,
        attribute: NSLayoutAttribute.bottom,
        relatedBy: NSLayoutRelation.equal,
        toItem: view,
        attribute: NSLayoutAttribute.bottom,
        multiplier: 1,
        constant: constant)
    
    return [topConstraint, bottomConstraint]
}

func constraintsToContainViewVertically(_ view: UIView, inContainingView containingView: UIView, withTopInset topInset: CGFloat, andBottomInset bottomInset: CGFloat) -> [NSLayoutConstraint] {
    
    let topConstraint = NSLayoutConstraint(
        item: containingView,
        attribute: NSLayoutAttribute.top,
        relatedBy: NSLayoutRelation.equal,
        toItem: view,
        attribute: NSLayoutAttribute.top,
        multiplier: 1,
        constant: -topInset)
    
    let bottomConstraint = NSLayoutConstraint(
        item: containingView,
        attribute: NSLayoutAttribute.bottom,
        relatedBy: NSLayoutRelation.equal,
        toItem: view,
        attribute: NSLayoutAttribute.bottom,
        multiplier: 1,
        constant: bottomInset)
    
    return [topConstraint, bottomConstraint]
}

func constraintsToContainViewHorizontally(_ view: UIView, inContainingView containingView: UIView, withConstant constant: CGFloat = 0) -> [NSLayoutConstraint] {
    
    let topConstraint = NSLayoutConstraint(
        item: containingView,
        attribute: NSLayoutAttribute.left,
        relatedBy: NSLayoutRelation.equal,
        toItem: view,
        attribute: NSLayoutAttribute.left,
        multiplier: 1,
        constant: -constant)
    
    let bottomConstraint = NSLayoutConstraint(
        item: containingView,
        attribute: NSLayoutAttribute.right,
        relatedBy: NSLayoutRelation.equal,
        toItem: view,
        attribute: NSLayoutAttribute.right,
        multiplier: 1,
        constant: constant)
    
    return [topConstraint, bottomConstraint]
}

func constraintsToContainViewHorizontally(_ view: UIView, inContainingView containingView: UIView, withLeftInset leftInset: CGFloat, andRightInset rightInset: CGFloat) -> [NSLayoutConstraint] {
    
    let topConstraint = NSLayoutConstraint(
        item: containingView,
        attribute: NSLayoutAttribute.left,
        relatedBy: NSLayoutRelation.equal,
        toItem: view,
        attribute: NSLayoutAttribute.left,
        multiplier: 1,
        constant: -leftInset)
    
    let bottomConstraint = NSLayoutConstraint(
        item: containingView,
        attribute: NSLayoutAttribute.right,
        relatedBy: NSLayoutRelation.equal,
        toItem: view,
        attribute: NSLayoutAttribute.right,
        multiplier: 1,
        constant: rightInset)
    
    return [topConstraint, bottomConstraint]
}

func constraintsToContainView(_ view: UIView,
                              inContainingView containingView: UIView,
                              withTopInset topInset: CGFloat = 0,
                              withRightInset rightInset: CGFloat = 0,
                              withBottomInset bottomInset: CGFloat = 0,
                              withLeftInset leftInset: CGFloat = 0) -> [NSLayoutConstraint] {
    
    var constraints = [NSLayoutConstraint]()
    constraints += constraintsToContainViewVertically(view, inContainingView: containingView, withTopInset: topInset, andBottomInset: bottomInset)
    constraints += constraintsToContainViewHorizontally(view, inContainingView: containingView, withLeftInset: leftInset, andRightInset: rightInset)
    
    return constraints
}

func constraintsToContainViewStack(_ stack: [UIView], inView containingView: UIView, withConstant constant: CGFloat = 0) -> [NSLayoutConstraint] {
    
    // Only continue if we have at least one view to contain in the containingView.
    guard let topView = stack.first, let bottomView = stack.last else {
        return []
    }
    
    let topConstraint = NSLayoutConstraint(
        item: containingView,
        attribute: NSLayoutAttribute.top,
        relatedBy: NSLayoutRelation.equal,
        toItem: topView,
        attribute: NSLayoutAttribute.top,
        multiplier: 1,
        constant: -constant)
    
    let bottomConstraint = NSLayoutConstraint(
        item: containingView,
        attribute: NSLayoutAttribute.bottom,
        relatedBy: NSLayoutRelation.equal,
        toItem: bottomView,
        attribute: NSLayoutAttribute.bottom,
        multiplier: 1,
        constant: constant)
    
    return [topConstraint, bottomConstraint]
}

func constraintToChainBottomView(_ bottomView: UIView, toTopView topView: UIView, withConstant constant: CGFloat = 0) -> [NSLayoutConstraint] {
    let chainConstraint = NSLayoutConstraint(
        item: bottomView,
        attribute: NSLayoutAttribute.top,
        relatedBy: NSLayoutRelation.equal,
        toItem: topView,
        attribute: NSLayoutAttribute.bottom,
        multiplier: 1,
        constant: constant)
    
    return [chainConstraint]
}

func constraintsToCreateChainOfViews(_ views: [UIView], inContainingView containingView: UIView, withInbetweenSpacing spacing: CGFloat) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()
    
    constraints += equalityConstraintForView(views[0], andAttribute: .top, withView: containingView, withConstant: spacing)
    
    // replaces: for (var i = views.count - 1; i > 0; --i) { }
    for i in (1..<views.count).reversed() {
        constraints += constraintToChainBottomView(views[i], toTopView: views[i-1], withConstant: spacing)
    }
    
    for view in views {
        constraints += constraintsToContainViewHorizontally(view, inContainingView: containingView)
    }
    
    return constraints
}

func constraintsToCreateChainOfViews(_ views: [UIView], withInbetweenSpacing spacing: CGFloat) -> [NSLayoutConstraint] {
    var constraints = [NSLayoutConstraint]()
    
    for i in (1..<views.count).reversed() {
        constraints += constraintToChainBottomView(views[i], toTopView: views[i-1], withConstant: spacing)
    }
    
    return constraints
}

func equalityConstraintForView(_ view: UIView, andAttribute attribute: NSLayoutAttribute, withView otherView: UIView?, withConstant constant: CGFloat = 0, withMultiplier multiplier: CGFloat = 1) -> [NSLayoutConstraint] {
    
    var secondAttribute = NSLayoutAttribute.notAnAttribute
    
    if otherView != nil {
        secondAttribute = attribute
    }
    
    let equalityConstraint = NSLayoutConstraint(
        item: view,
        attribute: attribute,
        relatedBy: NSLayoutRelation.equal,
        toItem: otherView,
        attribute: secondAttribute,
        multiplier: multiplier,
        constant: constant)
    
    return [equalityConstraint]
}
