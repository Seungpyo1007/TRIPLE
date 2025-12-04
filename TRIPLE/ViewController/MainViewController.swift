//
//  MainViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 11/24/25.
//

import UIKit

protocol MainViewScrollDelegate: AnyObject {
    // Called with vertical content offset (positive when scrolling up)
    func mainViewDidScroll(to offsetY: CGFloat)
}

class MainViewController: UIViewController, MainViewScrollDelegate {
    private var sideMenuViewController: SideMenuViewController!
    private var sideMenuShadowView: UIView!
    //사이드바 가로 넓이 + 회전시 폭
    private var sideMenuRevealWidth: CGFloat = 320
    private let paddingForRotation: CGFloat = 320
    private var isExpanded: Bool = false
    // 사이드메뉴 열기/닫기 설정용 TC
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    
    // Sticky header configuration
    private let stickyRange: CGFloat = 120 // how much header can collapse/expand
    private var initialMainTopConstant: CGFloat = 0
    
    @IBOutlet weak var goneViewTopConstraint: NSLayoutConstraint!
    // mainView를 위로 올리기 위한 상단 제약
    @IBOutlet weak var mainViewTopConstraint: NSLayoutConstraint!
   
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Save initial top constraint for sticky behavior
        self.initialMainTopConstant = self.mainViewTopConstraint?.constant ?? 0
        // 사이드바 추가
        self.setBasicSideMenu()
        embedMainView()
        embedGoneView()
    }

    
    //MARK: - @IBOutlets
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var goneView: UIView!
    @IBOutlet weak var mainView: UIView!
    
    private func embedMainView() {
        let detailView = MainView()
        detailView.scrollDelegate = self
        detailView.translatesAutoresizingMaskIntoConstraints = false
        let targetContainer = mainView ?? view
        targetContainer?.addSubview(detailView)

        if let target = targetContainer {
            NSLayoutConstraint.activate([
                detailView.topAnchor.constraint(equalTo: target.topAnchor),
                detailView.bottomAnchor.constraint(equalTo: target.bottomAnchor),
                detailView.leadingAnchor.constraint(equalTo: target.leadingAnchor),
                detailView.trailingAnchor.constraint(equalTo: target.trailingAnchor)
            ])
        }
    }
    
    private func embedGoneView() {
        let detailView = GoneView()
        detailView.translatesAutoresizingMaskIntoConstraints = false
        let targetContainer = goneView ?? view
        targetContainer?.addSubview(detailView)

        if let target = targetContainer {
            NSLayoutConstraint.activate([
                detailView.topAnchor.constraint(equalTo: target.topAnchor),
                detailView.bottomAnchor.constraint(equalTo: target.bottomAnchor),
                detailView.leadingAnchor.constraint(equalTo: target.leadingAnchor),
                detailView.trailingAnchor.constraint(equalTo: target.trailingAnchor)
            ])
        }
    }
    
    // 누르면 push 방식으로 SearchViewController로 이동
    @IBAction func openSearchMenu(_ sender: Any) {
        let vc: UIViewController
        if Bundle.main.path(forResource: "SearchViewController", ofType: "nib") != nil ||
            Bundle.main.path(forResource: "SearchViewController", ofType: "xib") != nil {
            vc = SearchViewController(nibName: "SearchViewController", bundle: .main)
        } else {
            vc = SearchViewController()
        }
        vc.modalPresentationStyle = .fullScreen
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            self.present(vc, animated: true, completion: nil)
        }
    }
    

    // 수동으로 버튼 누르면 만든 뷰 열기
    @IBAction func openSlideMenu(_ sender: Any) {
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
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.6 }
        }
        else {
            self.animateSideMenu(targetPosition: (self.sideMenuRevealWidth + self.paddingForRotation)) { _ in
                self.isExpanded = false
            }
            UIView.animate(withDuration: 0.5) { self.sideMenuShadowView.alpha = 0.0 }
        }
    }
    
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            self.sideMenuTrailingConstraint.constant = targetPosition
            self.view.layoutIfNeeded()
        }, completion: completion)
    }
    
    // MARK: - MainViewScrollDelegate
    func mainViewDidScroll(to offsetY: CGFloat) {
        let collapse = max(0, min(stickyRange, offsetY))
        let newTop = initialMainTopConstant - collapse
        self.mainViewTopConstraint?.constant = newTop
        
        if offsetY < 0 {
            let expandAmount = min(stickyRange, abs(offsetY))
            let adjustedTop = min(initialMainTopConstant, (self.mainViewTopConstraint?.constant ?? initialMainTopConstant) + expandAmount)
            self.mainViewTopConstraint?.constant = adjustedTop
        }
        self.view.layoutIfNeeded()
    }
}

