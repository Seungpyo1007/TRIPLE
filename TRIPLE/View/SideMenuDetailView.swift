import Foundation
import UIKit

@IBDesignable
class SideMenuDetailView: UIView {
    @IBOutlet weak var profileEditLabel: UILabel!
    
    @IBAction func profileEditTapped(_ sender: Any) {
        let vc = ProfileEditViewController(nibName: "ProfileEditViewController", bundle: Bundle.main)
        parentViewController()?.present(vc, animated: true, completion: nil)
    }
    
    private func setupProfileEditTap() {
        // UILabel doesn't receive touches by default
        profileEditLabel.isUserInteractionEnabled = true
        // Remove existing recognizers if any to avoid duplicates
        profileEditLabel.gestureRecognizers?.forEach { profileEditLabel.removeGestureRecognizer($0) }
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileEditLabelTap))
        profileEditLabel.addGestureRecognizer(tap)
    }

    @objc private func handleProfileEditLabelTap() {
        profileEditTapped(self)
    }
    
    
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
        
        // Enable tapping on the profile edit label to present the edit screen
        setupProfileEditTap()
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
