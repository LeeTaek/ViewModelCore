# ViewModelCore

TCA의 `@Reducer` 매크로와 RxSwift 참고하여 만든 ViewModel용 라이브러리입니다.  
UIKit 또는 SwiftUI 환경에서 ViewModel을 구성할 때 반복되는 보일러플레이트 코드를 줄이고, 선언적 방식으로 상태 기반 아키텍처를 구현할 수 있도록 돕습니다.

---

## ✅ 구현한 내용

### 🔗 BindingSupport 모듈

`BindingSupport`는 UIKit 환경에서 `ViewModel`의 상태를 양방향 바인딩할 수 있도록 도와주는 도우미 유틸입니다.  
`UIControl`의 이벤트를 Combine 퍼블리셔로 변환하거나, `@Binding` 스타일로 값을 다룰 수 있게 해주는 기능들을 포함합니다.

#### 주요 기능:

- `BindableCompatible` 프로토콜
- `UIControl.publisher(for:)` 를 통한 이벤트 스트림 처리
- `@Published` 값을 바인딩할 수 있는 `bind(to:)` 유틸 제공
- SwiftUI의 `@Binding`과 유사한 인터페이스로 UIKit 코드 작성 가능



`@ViewModel` 매크로를 통해 다음을 자동으로 생성합니다:

- `@Published private(set) var state = State()`
- `func send(_ action: Action)`  
  → `reduce(state: &state, action: action)` 호출
- `subscript<Value>(dynamicMember:)`  
  → `state[keyPath: keyPath]`로 위임
- `@dynamicMemberLookup`을 ViewModel 클래스에 자동 추가  
  → `viewModel.count`처럼 `state.count`에 직접 접근 가능
- `ObservableObject` 프로토콜 자동 채택
- `State`, `Action`, `reduce` 누락 시 컴파일 타임 진단 & Fix-it 제안 제공

---

## 🧩 사용법
- 예제 프로젝트 참고 


### ✅ 자동 생성되는 내부 코드

```swift
@Published private(set) var state = State()

func send(_ action: Action) {
    reduce(state: &state, action: action)
}

subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
    state[keyPath: keyPath]
}
```

viewModel에 @dynamicMemberLookup attribute를 붙이면 
`viewModel.count`처럼 `state.count`를 직접 ViewModel에서 접근할 수 있습니다.

---

## 📦 요구사항

- Swift 5.9 이상
- Xcode 15 이상
- Swift Macros 지원되는 컴파일러

---

## 📜 참고

본 매크로는 TCA의 `@Reducer`, SwiftSyntax 기반 macro 구조, SwiftUI의 상태 관리 방식 등을 참고하여 설계되었습니다.

