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
    
    // 초기 도시 정보 (CityViewController에서 주입)
    var initialCityName: String?
    var initialPlaceID: String?
    
    // MARK: - 변수 & 상수
    private var mapView: GMSMapView!
    private let placesClient = GMSPlacesClient.shared()
    private var currentCategoryMarkers: [GMSMarker] = []
    private let viewModel = CityPlacesViewModel()
    
    // Default search radius in meters
    private let searchRadius: Double = 1500
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = initialCityName, !name.isEmpty {
            cityTravelName.title = "\(name) 여행"
        }

        setupMap()
        setupButtons()
        bindViewModel()
    }
    
    // MARK: - Setup
    private func setupMap() {
        // 기본 카메라 (전세계 뷰)
        let defaultCamera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 1)
        let map = GMSMapView(frame: .zero, camera: defaultCamera)
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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

        // 초기 도시 좌표로 카메라 이동
        centerToInitialCityIfAvailable()
    }
    
    private func centerToInitialCityIfAvailable() {
        guard let mapView = mapView else { return }
        // placeID가 있으면 우선 사용
        if let pid = initialPlaceID, !pid.isEmpty {
            let properties = [GMSPlaceProperty.name, GMSPlaceProperty.coordinate].map { $0.rawValue }
            let request = GMSFetchPlaceRequest(placeID: pid, placeProperties: properties, sessionToken: nil)
            placesClient.fetchPlace(with: request) { [weak self] place, error in
                guard let self = self else { return }
                if let coord = place?.coordinate {
                    let camera = GMSCameraPosition.camera(withLatitude: coord.latitude, longitude: coord.longitude, zoom: 14)
                    mapView.animate(to: camera)
                }
            }
            return
        }
        // placeID가 없으면 이름 기반으로는 여기서 별도 처리 생략(추후 텍스트 검색 연동 가능)
    }

    private func setupButtons() {
        tourButton.addTarget(self, action: #selector(didTapTour), for: .touchUpInside)
        restaurantButton.addTarget(self, action: #selector(didTapRestaurant), for: .touchUpInside)
        lodgingButton.addTarget(self, action: #selector(didTapLodging), for: .touchUpInside)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    

    private func clearCategoryMarkers() {
        currentCategoryMarkers.forEach { $0.map = nil }
        currentCategoryMarkers.removeAll()
    }

    private func bindViewModel() {
        viewModel.onPlacesUpdate = { [weak self] places, color in
            guard let self = self else { return }
            self.addMarkers(for: places, color: color)
        }
        viewModel.onError = { error in
            print("Nearby Search error: \(error.localizedDescription)")
        }
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

    private func addMarkers(for places: [GMSPlace], color: UIColor) {
        guard let mapView = mapView else { return }
        clearCategoryMarkers()
        for place in places {
            let marker = GMSMarker(position: place.coordinate)
            marker.title = place.name
            if place.rating != 0 {
                marker.snippet = "Rating: \(place.rating)"
            }
            marker.icon = GMSMarker.markerImage(with: color)
            marker.map = mapView
            currentCategoryMarkers.append(marker)
        }
        if let first = places.first {
            let update = GMSCameraUpdate.setTarget(first.coordinate, zoom: 14)
            mapView.animate(with: update)
        }
    }

}
