//
//  CityRecService.swift
//  TRIPLE
//
//  Created by 홍승표 on 12/16/25.
//

import Foundation
import UIKit
import GooglePlaces

// MARK: - [프로토콜] 사진 서비스
protocol PlacePhotoProviding {
    /// 특정 장소의 대표 사진(첫 번째 사진)을 가져옵니다.
    func fetchFirstPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (Data?) -> Void)
}

// MARK: - 서비스 구현
final class GooglePlacesPhotoService: PlacePhotoProviding {
    private let placesClient: GMSPlacesClient

    init(placesClient: GMSPlacesClient = GMSPlacesClient.shared()) {
        self.placesClient = placesClient
    }

    /// Google Places API를 통해 장소 정보를 조회한 후, 해당 장소의 첫 번째 사진을 Data 형식으로 변환
    func fetchFirstPhoto(for placeID: String, maxSize: CGSize, completion: @escaping (Data?) -> Void) {
        // 사진 메타데이터를 포함한 장소 속성 정의
        let properties: [GMSPlaceProperty] = [.photos]
        let fetchRequest = GMSFetchPlaceRequest(
            placeID: placeID,
            placeProperties: properties.map { $0.rawValue },
            sessionToken: nil
        )

        // 장소 상세 정보 요청 (메타데이터 획득 목적)
        placesClient.fetchPlace(with: fetchRequest) { [weak self] place, error in
            if let error = error {
                print("[CityRec] 상세 정보 조회 실패 (\(placeID)): \(error.localizedDescription)")
                completion(nil)
                return
            }

            // 사진 목록 중 첫 번째 메타데이터 확인
            guard let photoMetadata = place?.photos?.first else {
                print("[CityRec] 사진 메타데이터 없음 (ID: \(placeID))")
                completion(nil)
                return
            }

            // 메타데이터를 사용하여 실제 사진 데이터 요청
            let fetchPhotoRequest = GMSFetchPhotoRequest(photoMetadata: photoMetadata, maxSize: maxSize)
            
            self?.placesClient.fetchPhoto(with: fetchPhotoRequest) { image, error in
                guard let image = image, error == nil else {
                    print("[CityRec] 사진 데이터 로드 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                    completion(nil)
                    return
                }

                // 이미지를 JPEG 또는 PNG 데이터로 변환하여 전달
                if let data = image.jpegData(compressionQuality: 0.9) {
                    completion(data)
                } else {
                    completion(image.pngData())
                }
            }
        }
    }
}

// MARK: - [프로토콜] 도시 추천 서비스
protocol CityRecServicing {
    /// 테스트용 목업 데이터를 생성합니다.
    func loadMock(verifiedPlaceIDs: [String], count: Int) -> [CityRecItem]
    /// 시스템에 등록된 검증된 도시 목록을 가져옵니다.
    func loadVerified(limit: Int?) -> [CityRecItem]
    /// 도시 이름에 해당하는 Google Place ID를 반환합니다.
    func placeID(for city: String) -> String?
}

// MARK: - 도시별 장소 ID 매핑
enum CityPlaceIDs {
    /// 영문 도시명을 키로 사용하는 Place ID 딕셔너리
    static let byCity: [String: String] = [
        "Ho Chi Minh City": "ChIJ0T2NLikpdTERKxE8d61aX_E",
        "Hanoi": "ChIJoRyG2ZurNTERqRfKcnt_iOc",
        "Da Nang": "ChIJEyolkscZQjERBn5yhkvL8B0",
        "Tokyo": "ChIJ51cu8IcbXWARiRtXIothAS4",
        "Osaka": "ChIJ4eIGNFXmAGAR5y9q5G7BW8U",
        "Kyoto": "ChIJ8cM8zdaoAWARPR27azYdlsA",
        "Fukuoka": "ChIJKYSE6aHtQTURg4c5NplyCvY",
        "Seoul": "ChIJzWXFYYuifDUR64Pq5LTtioU",
        "Taipei": "ChIJi73bYWusQjQRgqQGXK260bw",
        "Hong Kong": "ChIJD5gyo-3iAzQRfMnq27qzivA",
        "Bangkok": "ChIJ82ENKDJgHTERIEjiXbIAAQE",
        "Singapore": "ChIJdZOLiiMR2jERxPWrUs9peIg",
        "Kuala Lumpur": "ChIJ0-cIvSo2zDERmWzYQPUfLiM",
        "Manila": "ChIJi8MeVwPKlzMRH8FpEHXV0Wk",
        "Jakarta": "ChIJnUvjRenzaS4RoobX2g-_cVM",
        "Sydney": "ChIJP3Sa8ziYEmsRUKgyFmh9AQM",
        "Melbourne": "ChIJ90260rVG1moRkM2MIXVWBAQ",
        "Auckland": "ChIJ--acWvtHDW0RF5miQ2HvAAU",
        "Los Angeles": "ChIJE9on3F3HwoAR9AhGJW_fL-I",
        "New York": "ChIJOwg_06VPwokRYv534QaPC8g",
        "San Francisco": "ChIJW2ZfkQqlfDUR4vz9Xs0Q66s",
        "Vancouver": "ChIJs0-pQ_FzhlQRi_OBm-qWkbs",
        "Toronto": "ChIJpTvG15DL1IkRd8S0KlBVNTI",
        "London": "ChIJdd4hrwug2EcRmSrV3Vo6llI",
        "Paris": "ChIJdd4hrwug2EcRmSrV3Vo6llI",
        "Berlin": "ChIJAVkDPzdOqEcRcDteW0YgIQQ",
        "Barcelona": "ChIJk_s92NyipBIRUMnDG8Kq2Js",
        "Rome": "ChIJu46S-ZZhLxMROG5lkwZ3D7k",
        "Istanbul": "ChIJawhoAASnyhQR0LABvJj-zOE",
        "Dubai": "ChIJRcbZaklDXz4RYlEphFBu5r0"
    ]

    /// 별칭(Alias) 처리를 포함하여 Place ID를 조회합니다.
    static func placeID(for city: String) -> String? {
        switch city {
        case "Saigon": return byCity["Ho Chi Minh City"] // 호치민 별칭 처리
        default: return byCity[city]
        }
    }
}

// MARK: - 도시 추천 서비스 구현체
struct CityRecService: CityRecServicing {
    
    /// 무작위 도시 목록을 생성하여 반환합니다. (UI 테스트 및 초기 로딩용)
    func loadMock(verifiedPlaceIDs: [String], count: Int) -> [CityRecItem] {
        let cityNames = Array(CityPlaceIDs.byCity.keys) + ["Saigon"]
        let shuffled = cityNames.shuffled()
        
        var items: [CityRecItem] = []
        for i in 0..<max(0, count) {
            let title = i < shuffled.count ? shuffled[i] : "City \(i + 1)"
            let id = CityPlaceIDs.placeID(for: title)
            
            // 등록된 ID가 있고, 전달받은 검증 목록에 포함되어 있는지 확인 (로직 보강 가능)
            let placeID = id
            items.append(CityRecItem(title: title, placeID: placeID))
        }
        return items
    }

    /// 현재 시스템에 정의된 모든 도시를 반환
    func loadVerified(limit: Int?) -> [CityRecItem] {
        let all = CityPlaceIDs.byCity.map { CityRecItem(title: $0.key, placeID: $0.value) }
        
        // 정렬 로직 추가 가능 (예: 이름순)
        let sortedAll = all.sorted { $0.title < $1.title }
        
        if let limit = limit, limit > 0 {
            return Array(sortedAll.prefix(limit))
        }
        return sortedAll
    }

    /// 특정 도시에 대한 Google Place ID를 가져옵니다.
    func placeID(for city: String) -> String? {
        CityPlaceIDs.placeID(for: city)
    }
}
