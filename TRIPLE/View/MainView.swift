//
//  MainView.swift
//  TRIPLE
//
//  Created by 홍승표 on 11/28/25.
//

import Foundation
import UIKit

@IBDesignable
class MainView: UIView, UIScrollViewDelegate {
    weak var scrollDelegate: MainViewScrollDelegate?

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

        scrollView.delegate = self

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        let nib = UINib(nibName: "MainView", bundle: Bundle(for: type(of: self)))
        guard let loaded = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            assertionFailure("실패")
            return
        }

        let actualContent: UIView
        if let nested = loaded as? MainView, let first = nested.subviews.first {
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
            actualContent.heightAnchor.constraint(equalToConstant: 7000)
        ])
        
        actualContent.setContentHuggingPriority(.required, for: .vertical)
        actualContent.setContentCompressionResistancePriority(.required, for: .vertical)

        scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.mainViewDidScroll(to: scrollView.contentOffset.y)
    }
}
