import Foundation
import UIKit

@IBDesignable
class SideMenuDetailView: UIView {
    private var contentView: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        let nib = UINib(nibName: "SideMenuDetailView", bundle: .main)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            assertionFailure("Failed to load SideMenuDetailView.xib")
            return
        }
        contentView = view
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
