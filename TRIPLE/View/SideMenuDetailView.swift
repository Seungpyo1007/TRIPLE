import Foundation
import UIKit


@IBDesignable
class SideMenuDetailView: UIView {
    @IBOutlet weak var profileEditLabel: UILabel!
    
    private var contentView: UIView?
    private let scrollView = UIScrollView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .systemBackground
        scrollView.backgroundColor = .systemBackground

        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.keyboardDismissMode = .interactive
        scrollView.contentInsetAdjustmentBehavior = .never

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        let nib = UINib(nibName: "SideMenuDetailView", bundle: Bundle(for: type(of: self)))
        guard let loaded = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            assertionFailure("실패")
            return
        }

        let actualContent: UIView
        if let nested = loaded as? SideMenuDetailView, let first = nested.subviews.first {
            actualContent = first
        } else {
            actualContent = loaded
        }

        contentView = actualContent
        actualContent.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(actualContent)

        NSLayoutConstraint.activate([
            actualContent.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0),
            actualContent.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: 0),
            actualContent.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: 0),
            actualContent.heightAnchor.constraint(equalToConstant: 852)
        ])
        
        actualContent.setContentHuggingPriority(.required, for: .vertical)
        actualContent.setContentCompressionResistancePriority(.required, for: .vertical)

        scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        
        // Enable tap on profileEditLabel to navigate to Profile Edit
        profileEditLabel?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileEditTap))
        profileEditLabel?.addGestureRecognizer(tap)
    }
    
    @objc private func handleProfileEditTap() {
        if let vc = self.parentViewController() {
            let profileVC = ProfileEditViewController()
            if let nav = vc.navigationController {
                nav.pushViewController(profileVC, animated: true)
            } else {
                vc.present(profileVC, animated: true)
            }
        }
    }
}

extension UIView {
    func parentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let current = responder {
            if let vc = current as? UIViewController { return vc }
            responder = current.next
        }
        return nil
    }
    
}

