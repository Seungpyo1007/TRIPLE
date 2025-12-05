//
//  MainView.swift
//  TRIPLE
//
//  Created by 홍승표 on 11/28/25.
//

import UIKit

protocol MainViewScrollDelegate: AnyObject {
    func mainViewDidScroll(to offsetY: CGFloat)
}

@IBDesignable
class MainView: UIView, UIScrollViewDelegate {
    
    // MARK: - 변수 & 상수
    weak var scrollDelegate: MainViewScrollDelegate?

    private var contentView: UIView?
    private let scrollView = UIScrollView()

    // MARK: - 생명주기
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - UIView 초기 설정
    private func commonInit() {

        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never // scrollView 자동으로 Safe Area 방지

        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false // AutoLayout과의 충돌 방지용
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
        actualContent.translatesAutoresizingMaskIntoConstraints = false // AutoLayout과의 충돌 방지용
        scrollView.addSubview(actualContent)

        NSLayoutConstraint.activate([
            actualContent.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0),
            actualContent.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: 0),
            actualContent.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: 0),
            actualContent.heightAnchor.constraint(equalToConstant: 7000)
        ])
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.mainViewDidScroll(to: scrollView.contentOffset.y)
    }
}
