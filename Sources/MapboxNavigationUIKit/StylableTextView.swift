import UIKit

// :nodoc:
@objc(MBStylableTextView)
open class StylableTextView: UITextView {
    // Workaround the fact that UITextView properties are not marked with UI_APPEARANCE_SELECTOR.
    @objc open dynamic var normalTextColor: UIColor = .black {
        didSet {
            textColor = normalTextColor
        }
    }
}
