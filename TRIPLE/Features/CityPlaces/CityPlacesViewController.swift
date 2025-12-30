//
//  CityPlacesViewController.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/18/25.
//

import UIKit
import GoogleMaps
import GooglePlaces

class CityPlacesViewController: UIViewController {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var cityTravelName: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var tourButton: UIButton!
    @IBOutlet weak var restaurantButton: UIButton!
    @IBOutlet weak var lodgingButton: UIButton!
    
    // MARK: - 변수 & 상수
    // 외부 주입 데이터
    var initialCityName: String?
    var initialPlaceID: String?
    
    // 지도 및 검색 관련
    private var mapView: GMSMapView!
    private let placesClient = GMSPlacesClient.shared()
    private var currentCategoryMarkers: [GMSMarker] = []
    private let viewModel = CityPlacesViewModel()
    private let searchRadius: Double = 1500
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupMap()
        setupButtons()
        bindViewModel()
    }
    
    // MARK: - 3. UI Setup
    
    /// 내비게이션 바 타이틀 설정
    private func setupNavigation() {
        if let name = initialCityName, !name.isEmpty {
            cityTravelName.title = "\(name) 여행"
        }
    }
    
    /// 구글 맵 초기화 및 오토레이아웃 설정
    private func setupMap() {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 1)
        options.frame = .zero

        let map = GMSMapView(options: options)
        map.settings.myLocationButton = true
        map.isMyLocationEnabled = true
        map.translatesAutoresizingMaskIntoConstraints = false
        
        mainView.addSubview(map)
        NSLayoutConstraint.activate([
            map.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            map.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            map.topAnchor.constraint(equalTo: mainView.topAnchor),
            map.bottomAnchor.constraint(equalTo: mainView.bottomAnchor)
        ])
        
        self.mapView = map
        centerToInitialCityIfAvailable()
    }
    
    // MARK: - @IBOutlets -> @IBActions
    private func setupButtons() {
        tourButton.addTarget(self, action: #selector(didTapTour), for: .touchUpInside)
        restaurantButton.addTarget(self, action: #selector(didTapRestaurant), for: .touchUpInside)
        lodgingButton.addTarget(self, action: #selector(didTapLodging), for: .touchUpInside)
    }

    /// 뷰모델 바인딩 (데이터 업데이트 감지)
    private func bindViewModel() {
        viewModel.onPlacesUpdate = { [weak self] places, color in
            self?.addMarkers(for: places, color: color)
        }
        viewModel.onError = { error in
            print("Nearby Search error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 4. Logic & Actions
    
    /// 전달받은 PlaceID가 있다면 해당 위치로 카메라 이동
    private func centerToInitialCityIfAvailable() {
        guard let pid = initialPlaceID, !pid.isEmpty else { return }
        
        let properties = [GMSPlaceProperty.name, GMSPlaceProperty.coordinate].map { $0.rawValue }
        let request = GMSFetchPlaceRequest(placeID: pid, placeProperties: properties, sessionToken: nil)
        
        placesClient.fetchPlace(with: request) { [weak self] place, error in
            guard let self = self, let coord = place?.coordinate else { return }
            let camera = GMSCameraPosition.camera(withLatitude: coord.latitude, longitude: coord.longitude, zoom: 14)
            self.mapView.animate(to: camera)
        }
    }

    /// 지도 위 기존 마커들 모두 제거
    private func clearCategoryMarkers() {
        currentCategoryMarkers.forEach { $0.map = nil }
        currentCategoryMarkers.removeAll()
    }

    /// 검색된 장소들을 지도에 마커로 표시
    private func addMarkers(for places: [GMSPlace], color: UIColor) {
        guard let mapView = self.mapView else { return }
        clearCategoryMarkers()
        
        for place in places {
            let marker = GMSMarker(position: place.coordinate)
            marker.title = place.name
            if place.rating != 0 { marker.snippet = "Rating: \(place.rating)" }
            marker.icon = GMSMarker.markerImage(with: color)
            marker.map = mapView
            currentCategoryMarkers.append(marker)
        }
        
        // 검색된 첫 번째 장소로 카메라 이동
        if let first = places.first {
            let update = GMSCameraUpdate.setTarget(first.coordinate, zoom: 14)
            mapView.animate(with: update)
        }
    }
    
    // MARK: - @objc Actions (버튼 클릭 이벤트)
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapTour() {
        viewModel.search(category: .touristAttraction, center: mapView.camera.target, radius: searchRadius, color: .systemBlue)
    }

    @objc private func didTapRestaurant() {
        viewModel.search(category: .restaurant, center: mapView.camera.target, radius: searchRadius, color: .systemRed)
    }

    @objc private func didTapLodging() {
        viewModel.search(category: .lodging, center: mapView.camera.target, radius: searchRadius, color: .systemGreen)
    }
}
