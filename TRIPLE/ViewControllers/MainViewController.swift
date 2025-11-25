//
//  MainViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 11/24/25.
//

import UIKit

class MainViewController: UIViewController {
    // 사이드바 컨트롤러
    private var sideMenuViewController: SideMenuViewController!
    //사이드바 그림자 영역
    private var sideMenuShadowView: UIView!
    //사이드바 가로 넓이 + 회전시 폭
    private var sideMenuRevealWidth: CGFloat = 320
    private let paddingForRotation: CGFloat = 150
    //열려있는가
    private var isExpanded: Bool = false
    // 사이드메뉴 열기/닫기 설정용 TC
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
   
    override public func viewDidLoad() {
        super.viewDidLoad()
        // 사이드바 추가
        self.setBasicSideMenu()
    }

    // 수동으로 버튼 누르면 만든 뷰 열기
    @IBAction func openSlideMenuPro(_ sender: Any) {
        self.sideMenuState(expanded: self.isExpanded ? false : true)
    }
    
    
    //MARK: - 수동제작 사이드 메뉴 관련 코드들
    func setBasicSideMenu(){
        // Shadow Background View
        self.sideMenuShadowView = UIView(frame: self.view.bounds)
        self.sideMenuShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.sideMenuShadowView.backgroundColor = .black
        self.sideMenuShadowView.alpha = 0.0
        // 그림자 영역 클릭시 창 닫기
        let closeShadowClick = UITapGestureRecognizer(target: self, action: #selector(sideMenuState(tapRecog:)))
        self.sideMenuShadowView.addGestureRecognizer(closeShadowClick)
        // 그림자 영역 추가
        view.addSubview(self.sideMenuShadowView)

        // Side Menu
        if Bundle.main.path(forResource: "SideMenuViewController", ofType: "nib") != nil ||
            Bundle.main.path(forResource: "SideMenuViewController", ofType: "xib") != nil {
            self.sideMenuViewController = SideMenuViewController(nibName: "SideMenuViewController", bundle: .main)
        } else {
            self.sideMenuViewController = SideMenuViewController()
        }
   
        // 사이드바 영역 추가
        view.addSubview(self.sideMenuViewController!.view)
        addChild(self.sideMenuViewController!) // 뷰가 추가될 영역 설정
        self.sideMenuViewController!.didMove(toParent: self)

        // 사이드 메뉴 레이아웃 잡기
        self.sideMenuViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.sideMenuTrailingConstraint = self.sideMenuViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: self.sideMenuRevealWidth + self.paddingForRotation)
        self.sideMenuTrailingConstraint.isActive = true
    
        NSLayoutConstraint.activate([
            self.sideMenuViewController.view.widthAnchor.constraint(equalToConstant: self.sideMenuRevealWidth),
            self.sideMenuViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.sideMenuViewController.view.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
    // 그림자 부분 클릭시 닫기 연결용
    @objc func sideMenuState(tapRecog: UITapGestureRecognizer){
        // 열려있으면 닫기
        self.sideMenuState(expanded: self.isExpanded ? false : true)
    }
    // 액션 설정 부분
    func sideMenuState(expanded: Bool) {
        if expanded {
            self.animateSideMenu(targetPosition:  0 ) { _ in
                self.isExpanded = true
            }
            // Animate Shadow (Fade In)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.6 }
        }
        else {
            self.animateSideMenu(targetPosition: (self.sideMenuRevealWidth + self.paddingForRotation)) { _ in
                self.isExpanded = false
            }
            // Animate Shadow (Fade Out)
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.0 }
        }
    }
    
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            self.sideMenuTrailingConstraint.constant = targetPosition
            self.view.layoutIfNeeded()
        }, completion: completion)
    }
}

