# ViewModelCore

`ViewModelCore`는 TCA의 `@Reducer` 매크로와 RxSwift 아키텍처에서 영감을 받아 제작한, UIKit 및 SwiftUI 환경용 ViewModel 라이브러리입니다.  
보일러플레이트를 줄이고 선언적인 상태 기반 구조를 쉽게 도입할 수 있도록 설계되었습니다.

---

## ✅ 주요 구성

### 🧠 ViewModelMacro

`@ViewModel` 매크로를 통해 ViewModel에서 반복적으로 작성하는 코드들을 자동 생성합니다.

#### 주요 기능:

- `@Published private(set) var state = State()` 자동 생성
- `func send(_ action: Action)` → `reduce(state: &state, action: action)` 호출
- `@dynamicMemberLookup` 자동 적용 → `viewModel.count`처럼 `state.count` 직접 접근 가능
- `subscript<Value>(dynamicMember:)` → `state[keyPath: keyPath]` 위임
- `ObservableObject` 프로토콜 자동 채택
- `State`, `Action`, `reduce` 누락 시 컴파일 타임 진단 & Fix-it 제안

#### 생성되는 코드 예시:

```swift
@Published private(set) var state = State()

func send(_ action: Action) {
    reduce(state: &state, action: action)
}

subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
    state[keyPath: keyPath]
}
```

> `@dynamicMemberLookup` 덕분에 `viewModel.count`처럼 `state.count`를 ViewModel에서 바로 접근할 수 있습니다.

---

### 🔗 BindingSupport 모듈

`BindingSupport`는 UIKit 환경에서 `ViewModel`의 상태를 양방향 바인딩할 수 있도록 도와주는 유틸리티 모듈입니다.  
SwiftUI의 `@Binding`과 유사한 방식으로 UIKit 컴포넌트를 다룰 수 있게 해줍니다.

#### 주요 기능:

- `BindableCompatible` 프로토콜
- `UIControl.publisher(for:)` 확장
- `@Published` 값을 UI와 바인딩하는 `bind(to:)` 기능
- SwiftUI-style `Binding` 인터페이스를 UIKit에서도 사용 가능

---

## 🧪 사용법

- 예제 프로젝트는 `/Example/Counter` 디렉토리에 포함되어 있습니다.
- `@ViewModel`, `BindingSupport`의 사용 예시가 담겨 있습니다.

---

## 📦 요구사항

- Swift 5.9 이상
- Xcode 15 이상
- Swift Macros 지원 컴파일러 필요

---

## 📜 참고

- [TCA - The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)
- [SwiftSyntax](https://github.com/apple/swift-syntax)
- [Swift Macros Proposal](https://github.com/apple/swift-evolution/blob/main/proposals/0396-macros.md)
- [RxSwift](https://github.com/ReactiveX/RxSwift)
