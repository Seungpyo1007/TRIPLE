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
    @IBOutlet weak var travelCollectionView: UICollectionView!
    @IBOutlet weak var hotelCollectionView: UICollectionView!
    @IBOutlet weak var ticketCollectionView: UICollectionView!
    @IBOutlet weak var eventCollectionView: UICollectionView!
    
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
            let storyNib = UINib(nibName: "StoryCollectionViewCell", bundle: Bundle(for: type(of: self)))
            storyCollectionView.register(storyNib,forCellWithReuseIdentifier: StoryCollectionViewCell.reuseIdentifier)

            if let flow = storyCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flow.scrollDirection = .horizontal
                flow.minimumInteritemSpacing = 10
                flow.minimumLineSpacing = 10
                flow.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            }
            storyCollectionView.showsHorizontalScrollIndicator = false
        }
        
        if let cityRecCollectionView = self.cityRecCollectionView {
            let cityRecNib = UINib(nibName: "CityRecCollectionViewCell", bundle: Bundle(for: type(of: self)))
            cityRecCollectionView.register(cityRecNib,forCellWithReuseIdentifier: CityRecCollectionViewCell.reuseIdentifier)

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
        
        if let travelCollectionView = self.travelCollectionView {
            let travelNib = UINib(nibName: "TravelCollectionViewCell", bundle: Bundle(for: type(of: self)))
            travelCollectionView.register(travelNib, forCellWithReuseIdentifier: TravelCollectionViewCell.reuseIdentifier)

            if let flow = travelCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flow.scrollDirection = .horizontal
                flow.minimumInteritemSpacing = 10
                flow.minimumLineSpacing = 10
                flow.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            }
            travelCollectionView.showsHorizontalScrollIndicator = false
        }
        
        if let hotelCollectionView = self.hotelCollectionView {
            let hotelNib = UINib(nibName: "HotelCollectionViewCell", bundle: Bundle(for: type(of: self)))
            hotelCollectionView.register(hotelNib, forCellWithReuseIdentifier: HotelCollectionViewCell.reuseIdentifier)
            
            if let flow = hotelCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flow.scrollDirection = .horizontal
                flow.minimumInteritemSpacing = 10
                flow.minimumLineSpacing = 10
                flow.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            }
            hotelCollectionView.showsHorizontalScrollIndicator = false
        }
        
        if let ticketCollectionView = self.ticketCollectionView {
            let ticketNib = UINib(nibName: "TicketCollectionViewCell", bundle: Bundle(for: type(of: self)))
            ticketCollectionView.register(ticketNib, forCellWithReuseIdentifier: TicketCollectionViewCell.reuseIdentifier)
            
            if let flow = ticketCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flow.scrollDirection = .horizontal
                flow.minimumInteritemSpacing = 10
                flow.minimumLineSpacing = 10
                flow.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            }
            ticketCollectionView.showsHorizontalScrollIndicator = false
        }
        
        if let eventCollectionView = self.eventCollectionView {
            let eventNib = UINib(nibName: "EventCollectionViewCell", bundle: Bundle(for: type(of: self)))
            eventCollectionView.register(eventNib, forCellWithReuseIdentifier: EventCollectionViewCell.reuseIdentifier)
            
            if let flow = eventCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                flow.scrollDirection = .horizontal
                flow.minimumInteritemSpacing = 10
                flow.minimumLineSpacing = 10
                flow.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            }
            eventCollectionView.showsHorizontalScrollIndicator = false
        }
    }
    
    
    // 실시간 데이터? 무조건 있어야된다 하네요
    private func bindViewModel() {
        viewModel?.onStoriesChanged = { [weak self] _ in
            self?.storyCollectionView?.reloadData()
            self?.cityRecCollectionView?.reloadData()
            self?.benefitCollectionView?.reloadData()
            self?.travelCollectionView?.reloadData()
            self?.hotelCollectionView?.reloadData()
            self?.ticketCollectionView?.reloadData()
            self?.eventCollectionView?.reloadData()
        }
    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.mainViewDidScroll(to: scrollView.contentOffset.y)
    }
    
    // MARK: - Delegate
    
    // 외부에서 컬렉션뷰 핸들러 주입
    func setStoryHandlers(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegateFlowLayout) {
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
    
    func setTravelHandlers(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegateFlowLayout) {
        travelCollectionView?.dataSource = dataSource
        travelCollectionView?.delegate = delegate
        travelCollectionView?.reloadData()
    }
    func setHotelHandlers(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegateFlowLayout) {
        hotelCollectionView?.dataSource = dataSource
        hotelCollectionView?.delegate = delegate
        hotelCollectionView?.reloadData()
    }
    func setTicketHandlers(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegateFlowLayout) {
        ticketCollectionView?.dataSource = dataSource
        ticketCollectionView?.delegate = delegate
        ticketCollectionView?.reloadData()
    }
    func setEventHandlers(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegateFlowLayout) {
        eventCollectionView?.dataSource = dataSource
        eventCollectionView?.delegate = delegate
        eventCollectionView?.reloadData()
    }
}
