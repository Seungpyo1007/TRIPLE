//
//  SettingsView.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/3/25.
//

import UIKit

// MARK: - Delegate 정의
protocol SettingsViewDelegate: AnyObject {
    func didTapLogout()
}

class SettingsView: UIView {
    
    @IBOutlet weak var logoutView: UIView!
    
    // MARK: - 속성
    weak var delegate: SettingsViewDelegate?
    private var contentView: UIView?
    private let scrollView = UIScrollView()

    // MARK: - 초기화
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - 초기 설정
    private func commonInit() {
        setupScrollView()
        loadNib()
        setupLogoutGesture()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func loadNib() {
        // XIB 파일 로드
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "SettingsView", bundle: bundle)
        guard let loaded = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }

        // 뷰 중첩 방지 및 스크롤뷰 주입
        contentView = loaded
        loaded.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(loaded)

        NSLayoutConstraint.activate([
            loaded.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            loaded.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            loaded.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            loaded.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            loaded.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            loaded.heightAnchor.constraint(equalToConstant: 1860) // 기존 높이 유지
        ])
    }
    
    private func setupLogoutGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLogoutTap))
        logoutView?.isUserInteractionEnabled = true
        logoutView?.addGestureRecognizer(tap)
    }
    
    @objc private func handleLogoutTap() {
        delegate?.didTapLogout()
    }
}
