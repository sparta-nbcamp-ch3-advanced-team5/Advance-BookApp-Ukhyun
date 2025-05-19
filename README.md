# Advance-BookApp

## 프로젝트 소개

BookApp은 카카오 API를 활용하여 도서 검색 및 상세 정보를 확인할 수 있는 iOS 사이드 프로젝트입니다.  
사용자는 다양한 도서들을 확인하고, 리스트에 추가하여 내역을 확인 할 수 있습니다.  
현재 Kakao API 하나만 사용 되었습니다.

## 시연 영상
https://github.com/user-attachments/assets/954d00d4-3892-4807-b659-717ed0f9c3db

## 기술스택
### 📌 개발 환경
- **Swift**  
  iOS 앱 개발을 위한 프로그래밍 언어
- **Xcode 16.0**  
  iOS 앱 개발을 위한 공식 IDE

### 🎨 라이브러리 구성
- **UIKit**  
  전통적인 iOS UI 구성 프레임워크
  
- **SnapKit**  
  AutoLayout을 코드로 간결하게 작성할 수 있는 DSL 라이브러리
  
- **UICollectionView Compositional Layout**  
  복잡한 레이아웃을 손쉽게 구성할 수 있는 컬렉션 뷰 레이아웃 방식
  
- **KingFisher**  
  이미지를 URL로 쉽게 다운로드하고 캐싱하는 라이브러리
  
- **AlamoFire**  
   HTTP 네트워크 요청을 간단하게 처리하는 라이브러리
  
- **RxSwift**  
   비동기 작업과 이벤트 기반 코드를 선언형으로 작성할 수 있게 해주는 리액티브 프로그래밍 라이브러리
  
- **RxCocoa**

  RxSwift 기반으로, UIKit 및 Cocoa 컴포넌트에 리액티브 확장 기능을 제공하는 라이브러리



### 🔄 반응형 프로그래밍
- **RxSwift**  
   비동기 작업과 이벤트 기반 코드를 선언형으로 작성할 수 있게 해주는 리액티브 프로그래밍 라이브러리
  
- **RxCocoa**
  
   RxSwift 기반으로, UIKit 및 Cocoa 컴포넌트에 리액티브 확장 기능을 제공하는 라이브러리

## 파일 구조
```
.
├── Application
│   ├── AppDelegate.swift
│   ├── Base.lproj
│   └── SceneDelegate.swift
├── Data
│   └── CoreData
│       ├── BookApp.xcdatamodeld
│       │   └── BookApp.xcdatamodel
│       └── CoreDataManager.swift
├── Domain
│   └── Model
│       ├── APIKey.swift
│       └── BookData.swift
├── Extension
│   └── Int+Extensions.swift
├── Present
│   ├── View
│   │   ├── BookDetail
│   │   │   └── DetailViewController.swift
│   │   ├── BookList
│   │   │   ├── BookListCell.swift
│   │   │   ├── BookListCompositionalLayout.swift
│   │   │   └── BookListViewController.swift
│   │   └── SearchBook
│   │       ├── LoadingIndicatorCell.swift
│   │       ├── MainSectionHeaderView.swift
│   │       ├── MainViewCompositionalLayout.swift
│   │       ├── MainViewController.swift
│   │       ├── RecentBooksCell.swift
│   │       └── SearchResultsCell.swift
│   └── ViewModel
│       ├── BookListViewModel.swift
│       ├── DetailViewModel.swift
│       └── MainViewModel.swift
├── Resource
│   ├── Assets.xcassets
│   │   ├── AccentColor.colorset
│   │   │   └── Contents.json
│   │   ├── AppIcon.appiconset
│   │   │   └── Contents.json
│   │   └── Contents.json
│   ├── Base.lproj
│   │   └── LaunchScreen.storyboard
│   └── Info.plist
└── Service
    └── NetworkManager.swift
```


## Convention 
### Commit Convention (PR 시 동일하게 적용)
- `feat`: 새로운 기능 추가
- `refactor`: 새로운 기능 추가 없이 개선이 이뤄진 경우(주석 수정, 네이밍 수정 포함)
- `fix`: 버그 수정
- `chore`: 프로젝트 설정, ignore 설정, 패키지 추가 등 코드 외적인 변경 사항
- `docs`: 문서 작업
- `test`: 테스트 관련 작업

###  Coding Convention
- 기본적으로 Swift API Design Guidelines를 기반으로 하거나, Swift Document에 예제로 쓰인 코드 스니펫들을 기준으로 진행
- 파일 생성시 생기는 상단 주석은 삭제
- UI 컴포넌트 네이밍
    - UI 컴포넌트 생성 시, suffix로 컴포넌트 타입 명시
- import 구문
    - Foundation, UIKit 2개는 반드시 맨 위에 작성(소스코드가 어디에 관여하는지 나타내기 때문)
    - 내부 import들을 먼저쓰고, 외부 import들을 밑에 쓴다. (개행은 x)
    - 그 외 순서는 자유롭게
- Extension 파일의 경우는 `{타입}+Extensions.swift` 형태로 작성
    -   ex) Array+Extensions.swift, UIStackView+Extensions.swift

### Branch Convention
- main: 배포 가능한 안정적인 코드가 유지되는 브랜치
- dev: 기본 브랜치로, 기능을 개발하는 브랜치
- {tag}/{#issue-number}-{keyword}
    - ex) feat/#3-category-ui
    - ex) refactor/#5-storage
- {tag}/* 브랜치들은 전부 dev로 PR 발행 후, 팀원 모두의 승인을 받고 merge할 것
- 기본적으로 merge 방식으로 진행, (원하면 rebase해도 상관없음)
- 브랜치는 가급적 소문자로 구성하기!
