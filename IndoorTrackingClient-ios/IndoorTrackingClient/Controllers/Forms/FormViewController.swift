import Foundation
import UIKit

class FormViewController : UIViewController {
    
    // Public API
    var sections: [Section] {
        didSet {
            createTableViewCells()
            self.tableView.reloadData()
        }
    }
    
    var onLeftTap: (() -> Void)?
    var onRightTap: (() -> Void)?
    
    weak var delegate: FormDelegate?
    fileprivate(set) var formTitle: String
    
    fileprivate var titleBar: TitleBarView
    var tableView: UITableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.grouped)
    
    fileprivate var backgroundView: UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    
    fileprivate var statusBarHeight: CGFloat = 20
    
    var cells = [[FormInputCell]]()
    fileprivate(set) var mostRecentActiveCell: FormInputCell?
    
    // Need to keep track of this so we can update the size of the table view when the keyboard shows.
    fileprivate var tableViewBottomConstraint = NSLayoutConstraint()
    
    init(formTitle: String, sections: [Section]) {
        self.sections = sections
        self.formTitle = formTitle
        self.titleBar = TitleBarView(title: self.formTitle, leftButtonImage: nil, rightButtonImage: nil)
        
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .coverVertical
        
        createTableViewCells()
        configureTitleBar()
        configureTableView()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.setNeedsStatusBarAppearanceUpdate()
        
        let statusBarBackgroundColor = Theme.currentTheme.colorForKey("global.input.statusBarBackgroundColor") ?? UIColor.white
        
        setStatusBarBackgroundColor(statusBarBackgroundColor.withAlphaComponent(0.5))
        
        // TODO: FIXME: TEMP: Rotates the "add" image 45 degrees so it looks like a "close" image.
        self.titleBar.leftButton.imageView?.clipsToBounds = false
        self.titleBar.leftButton.imageView?.contentMode = UIViewContentMode.center
        self.titleBar.leftButton.imageView?.transform = CGAffineTransform(rotationAngle: 3.141592 / 4)
        
        // Set the observers for the keyboard.
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setStatusBarBackgroundColor(UIColor.clear)
    }
    
    fileprivate func configureTitleBar() {
        
        let titleBarBackgroundColor = Theme.currentTheme.colorForKey("global.input.titleBarBackgroundColor") ?? UIColor.white
        let titleLabelTextColor = Theme.currentTheme.colorForKey("global.input.titleLabelTextColor") ?? UIColor.white
        
        self.titleBar.delegate = self
        
        self.titleBar.backgroundColor = titleBarBackgroundColor.withAlphaComponent(0.3)
        self.titleBar.titleLabel.text = formTitle
        self.titleBar.titleLabel.textColor = titleLabelTextColor
        self.titleBar.titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        self.titleBar.leftImage = UIImage(named: "add")
        self.titleBar.rightImage = UIImage(named: "save")
    }
    
    fileprivate func configureTableView() {
        let tableViewBackgroundColor = Theme.currentTheme.colorForKey("global.input.tableViewBackgroundColor") ?? UIColor.clear
        let tableViewSeparatorColor = Theme.currentTheme.colorForKey("global.input.tableViewSeparatorColor") ?? UIColor.black
        
        self.tableView.backgroundColor = tableViewBackgroundColor.withAlphaComponent(0)
        self.tableView.separatorColor = tableViewSeparatorColor.withAlphaComponent(0.5)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // Want to create a set amount of cells and reuse these cells so that we can get the information entered into them by the user.
    func createTableViewCells() {
        
        let cellBackgroundColor = Theme.currentTheme.colorForKey("global.input.cellBackgroundColor") ?? UIColor.white
        
        cells = [[FormInputCell]]()
        
        // For every section
        for section in sections {
            var sectionCells = [FormInputCell]()
            
            // Add an input field for every field in that section
            for field in section.fields {
                let cell = FormInputCell()
                cell.delegate = self
                cell.backgroundColor = cellBackgroundColor.withAlphaComponent(0.25)
                
                cell.id = field.id
                
                if let name = field.title {
                    cell.name = name
                }
                
                if field.isRequired {
                    cell.placeholder = "Required"
                }
                
                cell.selectionStyle = .none
                
                sectionCells.append(cell)
            }
            
            cells.append(sectionCells)
        }
    }
    
    fileprivate func configureConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        // Attach the blurry background view to cover everything.
        constraints += constraintsToContainView(backgroundView, inContainingView: self.view)
        
        // Attach the titlebar to the top and to the left and right side of the containing view
        constraints += constraintsToContainViewHorizontally(titleBar, inContainingView: self.view)
        constraints += equalityConstraintForView(titleBar, andAttribute: .top, withView: self.view, withConstant: statusBarHeight)
        
        // Attach the table view to the sides, bottom and the bottom of the titlebar
        constraints += constraintsToContainViewHorizontally(tableView, inContainingView: self.view)
        constraints += constraintToChainBottomView(tableView, toTopView: titleBar)
        
        tableViewBottomConstraint = equalityConstraintForView(tableView, andAttribute: .bottom, withView: self.view).first!
        constraints += [tableViewBottomConstraint]
        
        self.view.addSubview(backgroundView)
        self.view.addSubview(tableView)
        self.view.addSubview(titleBar)
        
        self.view.addConstraints(constraints)
    }
    
    fileprivate func collectFormData() -> [String : String] {
        var data = [String : String]()
        
        for section in cells {
            for input in section {
                
                if let value = input.currentValue {
                    data[input.id] = value
                }
            }
        }
        
        return data
    }
    
    fileprivate func requiredFieldsHaveBeenCompleted(_ data: [String : String]) -> Bool {
        var complete = true
        var listOfRequiredFieldIDs = [String]()
        
        // Get the list of required IDs
        for section in sections {
            for inputField in section.fields {
                if (inputField.isRequired) {
                    listOfRequiredFieldIDs.append(inputField.id)
                }
            }
        }
        
        // Check they have been completed, if we find a required id that doesn't have a value, we are not complete.
        for id in listOfRequiredFieldIDs {
            if(data[id] == nil) {
                complete = false
            }
        }
        
        return complete
    }
    
    fileprivate func generateListOfIncompleteRequiredFields(_ data: [String : String]) -> [String]? {
        
        var listOfRequiredFieldIDs = [String]()
        var listOfIncompleteRequiredIDs = [String]()
        
        // Get the list of required IDs
        for section in sections {
            for inputField in section.fields {
                if (inputField.isRequired) {
                    listOfRequiredFieldIDs.append(inputField.id)
                }
            }
        }
        
        // Check they have been completed, if we find a required id that doesn't have a value, we are not complete.
        for id in listOfRequiredFieldIDs {
            if(data[id] == nil) {
                listOfIncompleteRequiredIDs.append(id)
            }
        }
        
        return listOfIncompleteRequiredIDs.count > 0 ? listOfIncompleteRequiredIDs : nil
    }
    
    
    // Public
    func cellForFieldId(_ id: String) -> FormInputCell? {
        for section in cells {
            for cell in section {
                if (cell.id == id) {
                    return cell
                }
            }
        }
        
        return nil
    }
    
    func clearFormData() {
        for section in cells {
            for input in section {
                input.clear()
            }
        }
    }
    
    func submit() {
        let formData = collectFormData()
        let areRequiredFieldsComplete = requiredFieldsHaveBeenCompleted(formData)
        let incompleteFieldIds = generateListOfIncompleteRequiredFields(formData)
        
        if let delegate = delegate {
            let okayToSubmit = delegate.formShouldSubmitWithData(formData, complete: areRequiredFieldsComplete, incompleteFieldIds: incompleteFieldIds)
            
            if(okayToSubmit) {
                delegate.formDidSubmitWithData(formData)
            }
        }
    }
    
    // Keyboard - Moving the cells around so they are never cut off by the keyboard.
    func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let activeCell = mostRecentActiveCell {
                
                // Get the size of the keyboard. Keyboard frame is in the window co-ordinate space.
                let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let convertedFrame = self.view.convert(keyboardFrame, from: self.view.window)
                
                // Make the tableview smaller so the cells can't go behind the keyboard.
                self.view.removeConstraint(tableViewBottomConstraint)
                tableViewBottomConstraint.constant = -convertedFrame.height
                self.view.addConstraint(tableViewBottomConstraint)
                
                self.view.layoutSubviews()
                
                // If the cell we clicked on below the keyboard, move the tableview up so it isn't
                //  covering any cells.
                let visibleBottom = self.view.frame.height - convertedFrame.height
                let cellBottom = activeCell.convert(CGPoint.zero, to: self.view).y + activeCell.frame.height
                
                let difference = cellBottom - visibleBottom
                
                if difference > 0 {
                    
                    var offset = self.tableView.contentOffset
                    offset.y += difference
                    
                    self.tableView.setContentOffset(offset, animated: true)
                }
            }
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        // Make the tableview the size of the entire visible space again.
        self.view.removeConstraint(tableViewBottomConstraint)
        tableViewBottomConstraint.constant = 0
        self.view.addConstraint(tableViewBottomConstraint)
        
        self.view.layoutSubviews()
    }
    
    func keyboardDidShow(_ notification: Notification) {
        
    }
    
    func keyboardDidHide(_ notification: Notification) {
        
    }
    
    // Status bar configuration
    fileprivate func setStatusBarBackgroundColor(_ color: UIColor) {
        
        guard  let statusBar = (UIApplication.shared.value(forKey: "statusBarWindow") as AnyObject).value(forKey: "statusBar") as? UIView else {
            return
        }
        
        statusBar.backgroundColor = color
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
}

// TableViewDelegate
extension FormViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.white
        }
    }
}

// TableViewDataSource
extension FormViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].fields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cells[indexPath.section][indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].name
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? FormInputCell {
            cell.takeFocus()
        }
    }
}

// TitleBarDelegate
extension FormViewController : TitleBarDelegate {
    
    func didTapLeftButton() {
        onLeftTap?()
    }
    
    func didTapRightButton() {
        onRightTap?()
    }
}

extension FormViewController : FormInputCellDelegate {
    
    func didBecomeActiveForCell(_ cell: FormInputCell) {
        mostRecentActiveCell = cell
    }
    
    func enterKeyWasPressed() {
        self.submit()
    }
}

class Section {
    
    fileprivate(set) var name: String
    fileprivate(set) var fields: [InputField]
    
    init(name: String) {
        self.name = name
        self.fields = [InputField]()
    }
    
    func addField(_ field: InputField) {
        self.fields.append(field)
        field.section = self
    }
}

class InputField {
    
    fileprivate(set) var id: String
    fileprivate(set) var title: String?
    weak fileprivate(set) var section: Section?
    
    fileprivate(set) var isActive: Bool
    fileprivate(set) var isRequired: Bool
    
    init(id: String, title: String? = nil, isRequired required: Bool = false) {
        self.id = id
        self.title = title
        self.isActive = false
        self.isRequired = required
    }
    
    func setSection(_ section: Section) {
        self.section = section
    }
}

protocol FormDelegate: class {
    func willMoveToNextInput(_ next: InputField)
    func formShouldSubmitWithData(_ data: [String : String], complete: Bool, incompleteFieldIds: [String]?) -> Bool
    func formDidSubmitWithData(_ data: [String : String])
}
