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

class MainView: UIView, UIScrollViewDelegate {
    
    // MARK: - 변수 & 상수
    weak var scrollDelegate: MainViewScrollDelegate?
    
    // 외부에서 주입받는 ViewModel
    var viewModel: MainViewModel? {
        didSet {
            bindViewModel()
            storyCollectionView?.reloadData()
        }
    }

    private var contentView: UIView?
    private let scrollView = UIScrollView()
    
    // MARK: - @IBOutlets
    @IBOutlet weak var titleName: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    @IBOutlet weak var storyCollectionView: UICollectionView!
    
    @IBOutlet weak var cityRecCollectionView: UICollectionView!
    
    @IBOutlet weak var benefitCollectionView: UICollectionView!
    
    private let storyCellReuseID = "StoryCollectionViewCell"
    
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

        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false // Auto Layout을 사용하기 위해 기본 설정을 비활성화
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

        // 로드된 뷰에서 실제 콘텐츠 뷰(actualContent)를 추출하여 contentView 변수에 저장합니다. (뷰 중첩 방지 코드)
        let actualContent: UIView
        if let nested = loaded as? MainView, let first = nested.subviews.first {
            actualContent = first
        } else {
            actualContent = loaded
        }

        contentView = actualContent
        actualContent.translatesAutoresizingMaskIntoConstraints = false // Auto Layout을 사용하기 위해 기본 설정을 비활성화
        scrollView.addSubview(actualContent) // 스크롤뷰에 actualContent뷰 추가

        NSLayoutConstraint.activate([
            actualContent.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 0),
            actualContent.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: 0),
            actualContent.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: 0),
            actualContent.heightAnchor.constraint(equalToConstant: 7000)
        ])
        
        // CollectionView Cell 위치 맞추기
        if let storyCollectionView = self.storyCollectionView {
            let cellNib = UINib(nibName: "StoryCollectionViewCell", bundle: Bundle(for: type(of: self)))
            storyCollectionView.register(cellNib, forCellWithReuseIdentifier: storyCellReuseID)

            if let flow = storyCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flow.scrollDirection = .horizontal
                flow.minimumInteritemSpacing = 10
                flow.minimumLineSpacing = 10
                flow.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            }
            storyCollectionView.showsHorizontalScrollIndicator = false
        }
        
        if let cityRecCollectionView = self.cityRecCollectionView {
            let recCellNib = UINib(nibName: "CityRecCollectionViewCell", bundle: Bundle(for: type(of: self)))
            cityRecCollectionView.register(recCellNib, forCellWithReuseIdentifier: CityRecCollectionViewCell.reuseIdentifier)

            if let flow = cityRecCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flow.scrollDirection = .horizontal
                flow.minimumInteritemSpacing = 10
                flow.minimumLineSpacing = 10
                flow.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            }
            cityRecCollectionView.showsHorizontalScrollIndicator = false
        }

        if let benefitCollectionView = self.benefitCollectionView {
            let benefitNib = UINib(nibName: "BenefitCollectionViewCell", bundle: Bundle(for: type(of: self)))
            benefitCollectionView.register(benefitNib, forCellWithReuseIdentifier: BenefitCollectionViewCell.reuseIdentifier)

            if let flow = benefitCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flow.scrollDirection = .horizontal
                flow.minimumInteritemSpacing = 10
                flow.minimumLineSpacing = 10
                flow.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            }
            benefitCollectionView.showsHorizontalScrollIndicator = false
        }
    }
    
    
    // 실시간 데이터? 무조건 있어야된다 하네요
    private func bindViewModel() {
        viewModel?.onStoriesChanged = { [weak self] _ in
            self?.storyCollectionView?.reloadData()
            self?.cityRecCollectionView?.reloadData()
            self?.benefitCollectionView?.reloadData()
        }
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.mainViewDidScroll(to: scrollView.contentOffset.y)
    }
    
    // 외부에서 컬렉션뷰 핸들러 주입
    func setCollectionHandlers(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegateFlowLayout) {
        storyCollectionView?.dataSource = dataSource
        storyCollectionView?.delegate = delegate
        storyCollectionView?.reloadData()
    }
    
    func setCityRecHandlers(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegateFlowLayout) {
        cityRecCollectionView?.dataSource = dataSource
        cityRecCollectionView?.delegate = delegate
        cityRecCollectionView?.reloadData()
    }

    func setBenefitHandlers(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegateFlowLayout) {
        benefitCollectionView?.dataSource = dataSource
        benefitCollectionView?.delegate = delegate
        benefitCollectionView?.reloadData()
    }
}
