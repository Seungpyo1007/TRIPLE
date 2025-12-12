//
//  SideMenuDetailView.swift
//  TRIPLE
//
//  Created by 홍승표 on 11/25/25.
//

import UIKit

protocol SideMenuDetailViewDelegate: AnyObject {
    func sideMenuDetailViewDidTapProfileEditLabel(_ view: SideMenuDetailView)
}

class SideMenuDetailView: UIView {
    
    // MARK: - 변수 & 상수
    weak var delegate: SideMenuDetailViewDelegate?
    
    private var contentView: UIView?
    private let scrollView = UIScrollView()
    
    // MARK: - @IBOutlet
    @IBOutlet weak var profileEditLabel: UILabel!

    // MARK: - 생명주기 (초기화)
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

        scrollView.translatesAutoresizingMaskIntoConstraints = false // Auto Layout을 사용하기 위해 기본 설정을 비활성화
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

        // 로드된 뷰에서 실제 콘텐츠 뷰(actualContent)를 추출하여 contentView 변수에 저장합니다. (뷰 중첩 방지 코드)
        let actualContent: UIView
        if let nested = loaded as? SideMenuDetailView, let first = nested.subviews.first {
            actualContent = first
        } else {
            actualContent = loaded
        }

        contentView = actualContent
        actualContent.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(actualContent) // 스크롤뷰에 actualContent뷰 추가

        NSLayoutConstraint.activate([
            actualContent.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0),
            actualContent.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: 0),
            actualContent.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: 0),
            actualContent.heightAnchor.constraint(equalToConstant: 852)
        ])
        
        profileEditLabel?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(profileEditTap))
        profileEditLabel?.addGestureRecognizer(tap)
    }
    
    // MARK: - SideMenuDetailViewDelegate
    @objc private func profileEditTap() {
        delegate?.sideMenuDetailViewDidTapProfileEditLabel(self)
    }
}
