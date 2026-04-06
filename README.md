# TRIPLE (트리플) - iOS 여행 가이드 앱

TRIPLE은 사용자의 여행 일정을 계획하고, 전 세계 도시의 정보, 호텔, 맛집, 그리고 실시간 날씨를 탐색할 수 있도록 돕는 iOS 애플리케이션입니다. 

> **Note**: 본 프로젝트는 실제 서비스 중인 [TRIPLE](https://triple.guide/) 앱의 디자인과 기능을 고안하여 개발된 클론 코딩/참고 프로젝트입니다.

**현재 이 프로젝트의 개발은 중단되었습니다.** 주요 기능의 골격과 실시간 데이터 연동이 일부 구현된 상태입니다.

---

## 🛠 기술 스택 (Tech Stack)

- **Language**: Swift (5.0+)
- **Architecture**: MVVM (Model-View-ViewModel)
- **UI Framework**: UIKit (Storyboard, XIB, Programmatic UI 병행)
- **Networking**: URLSession, Native Networking Layer
- **External APIs**: OpenWeather API (날씨), Firebase (인증 및 데이터)
- **Dependency Manager**: CocoaPods

---

## ✨ 주요 기능 (Key Features)

### 1. 메인 화면 (Main Home)
- **Sticky Header**: 사용자의 스크롤에 반응하여 네비게이션 바와 상호작용하는 상단 헤더 구현.
- **Side Menu**: 슬라이딩 방식의 사이드 메뉴를 통해 프로필 및 설정 앱 내부 메뉴로 접근 가능.
- **카테고리별 탐색**: 스토리, 도시 추천, 호텔, 티켓, 이벤트 등 섹션별 컬렉션 뷰 구성.

### 2. 탐색 및 검색 (Search)
- **도시/장소 검색**: 가고 싶은 도시나 장소를 키워드로 검색할 수 있는 전용 UI 제공.
- **자동 완성 및 최근 검색**: 효율적인 검색 경험을 위한 기초 로직 포함.

### 3. 실시간 데이터 연동 (Real-time Data)
- **날씨 정보**: OpenWeather API를 연동하여 조회 시점의 도시별 실시간 날씨 데이터 반영.
- **호텔 추천**: 실시간 API를 통해 특정 도시(예: 도쿄)의 최신 호텔 리스트 및 가격 정보 제공.

### 4. 사용자 인증 (Authentication)
- **Firebase Auth**: 로그인, 회원가입 및 프로필 관리 기능을 Firebase 플랫폼을 통해 안정적으로 처리.

---

## 🚧 미완성 및 향후 계획 (Unfinished & Future Plans)

현재 일부 기능은 UI 프로토타입 단계이거나 데이터가 Mock(가상) 데이터로 채워져 있습니다.

1. **데이터 실시간화 (Mock to Real)**:
   - 현재 **스토리(Story), 추천 도시, 혜택, 항공권, 이벤트** 섹션은 Mock 데이터를 사용 중입니다. 향후 백엔드 API 또는 외부 서버와 연동하여 실시간 데이터를 불러올 예정입니다.
2. **일정 관리 (Schedule)**:
   - 메인 화면의 '일정' 버튼 클릭 시 기능 미구현 안내 팝업이 노출됩니다. 실제 여행 스케줄을 생성하고 관리하는 상세 로직 개발이 필요합니다.
3. **상세 예약 로직**:
   - 호텔 상세 정보 조회 및 실제 예약 단계로 넘어가는 결제/예약 시스템 연동이 남아있습니다.
4. **지도 서비스 (Map Integration)**:
   - 장소 정보를 지도로 시각화하고 현재 위치 기반 추천 기능을 추가할 예정입니다.

---

## 🔑 설정 방법 (Setup)

이 프로젝트는 API 키 보호를 위해 `Secret.plist` 파일을 사용합니다.

1. `TRIPLE/Secret.plist` 파일을 생성합니다.
2. 다음 키 값을 추가합니다:
   - `OpenWeather-API-KEY`: [OpenWeather](https://openweathermap.org/)에서 발급받은 API 키.

---

## 📸 프로젝트 구조

- **Application**: 앱 델리게이트 및 초기 설정.
- **Features**: 각 기능별(Auth, City, Main, Search, Weather 등) UI 및 비즈니스 로직.
- **Models**: 데이터 구조 정의.
- **Network**: API 통신 관련 서비스 레이어.
- **Resource**: 이미지, 에셋 및 환경 설정 파일.

---

## 📄 라이선스 (License)

이 프로젝트는 [MIT License](LICENSE)를 따릅니다.
