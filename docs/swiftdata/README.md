# SwiftData 구현 가이드

이 문서는 Mentory 프로젝트에서 SwiftData를 어떻게 사용하고 있는지 설명합니다.

## 목차
1. [SwiftData란?](#swiftdata란)
2. [프로젝트 구조](#프로젝트-구조)
3. [주요 개념 및 사용법](#주요-개념-및-사용법)
4. [데이터 흐름](#데이터-흐름)

---

## SwiftData란?

SwiftData는 Swift의 데이터 영속화 프레임워크로, Core Data를 대체하는 최신 기술입니다.

### 주요 특징
- **매크로 기반**: `@Model`, `#Predicate` 등의 매크로로 간결한 코드 작성
- **타입 안전성**: 컴파일 타임에 에러 검출
- **SwiftUI 통합**: 네이티브하게 SwiftUI와 연동
- **간단한 설정**: Core Data에 비해 훨씬 간단한 초기 설정

---

## 프로젝트 구조

```
Mentory/
├── Domain/
│   └── MentoryDB/
│       ├── MentoryRecord.swift          # @Model 데이터 모델
│       └── MentoryRecordRepository.swift # Repository 패턴 구현
└── Presentation/
    └── Graphic/
        └── MentoryApp.swift              # ModelContainer 설정
```

---

## 주요 개념 및 사용법

### 1. `@Model` 매크로 - 데이터 모델 정의

`@Model`은 클래스를 SwiftData 모델로 변환해주는 매크로입니다.

**우리 프로젝트 코드:** `MentoryRecord.swift`

```swift
@Model
final class MentoryRecord {
    // MARK: 기본 정보
    var id: UUID
    var recordDate: Date

    // MARK: AI 분석 결과
    var analyzedContent: String?
    var emotionType: String?

    // MARK: 메타 데이터
    var completionTimeInSeconds: TimeInterval?

    init(
        id: UUID = UUID(),
        recordDate: Date = Date(),
        analyzedContent: String? = nil,
        emotionType: String? = nil,
        completionTimeInSeconds: TimeInterval? = nil
    ) {
        self.id = id
        self.recordDate = recordDate
        self.analyzedContent = analyzedContent
        self.emotionType = emotionType
        self.completionTimeInSeconds = completionTimeInSeconds
    }
}
```

**특징:**
- `@Model` 매크로를 class 위에 붙이면 SwiftData가 이 클래스를 데이터베이스 테이블로 변환
- `final class`를 사용해 상속 방지 및 성능 최적화
- 모든 stored property는 반드시 초기값이 있거나 initializer에서 초기화되어야 함
- Optional 타입(`String?`, `TimeInterval?`)도 사용 가능

**왜 이렇게 설계했나요?**
- `id`: 각 기록을 고유하게 식별 (UUID 사용)
- `recordDate`: 기록 작성 날짜/시간 (오늘 기록 필터링에 사용)
- `analyzedContent`: AI가 분석한 내용 (Alan LLM의 응답)
- `emotionType`: 감정 유형 (MindAnalyzer의 MindType enum 값)
- `completionTimeInSeconds`: 기록 작성에 걸린 시간

---

### 2. `ModelContainer` - 데이터베이스 컨테이너

`ModelContainer`는 SwiftData의 데이터 저장소를 관리하는 최상위 객체입니다.

**우리 프로젝트 코드:** `MentoryApp.swift:20-26`

```swift
@main
struct MentoryApp: App {
    // MARK: SwiftData
    let modelContainer: ModelContainer

    init() {
        // ModelContainer 초기화
        do {
            modelContainer = try ModelContainer(for: MentoryRecord.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }

        // ...
    }
}
```

**역할:**
- `ModelContainer(for: MentoryRecord.self)`: MentoryRecord 타입을 위한 데이터베이스를 생성
- 앱이 시작될 때 딱 한 번만 초기화
- SQLite 파일을 자동으로 생성하고 관리
- 여러 모델 타입이 있다면 배열로 전달 가능: `ModelContainer(for: [MentoryRecord.self, OtherModel.self])`

**SwiftUI에 주입:** `MentoryApp.swift:42-46`

```swift
var body: some Scene {
    WindowGroup {
        MentoryiOSView(mentoryiOS)
    }
    .modelContainer(modelContainer)  // View hierarchy에 주입
}
```

---

### 3. `ModelContext` - 데이터 조작 인터페이스

`ModelContext`는 실제 CRUD 작업을 수행하는 객체입니다.

**우리 프로젝트에서 사용:** `MentoryApp.swift:28-29`

```swift
// Repository 생성 시 mainContext를 주입
let repository = MentoryRecordRepository(modelContext: modelContainer.mainContext)
```

**Repository에서 사용:** `MentoryRecordRepository.swift:24-37`

```swift
@MainActor
final class MentoryRecordRepository: MentoryRecordRepositoryInterface {
    // MARK: core
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: flow
    func save(_ record: MentoryRecord) async throws {
        modelContext.insert(record)  // 1. 컨텍스트에 객체 추가
        try modelContext.save()      // 2. 디스크에 실제 저장
    }
}
```

**주요 메서드:**
- `insert(_:)`: 새로운 객체를 추가 (아직 디스크에는 저장 안됨)
- `save()`: 변경사항을 디스크에 실제로 저장
- `fetch(_:)`: FetchDescriptor를 사용해 데이터 조회
- `delete(_:)`: 객체 삭제

**삭제 예시:** `MentoryRecordRepository.swift:76-79`

```swift
func delete(_ record: MentoryRecord) async throws {
    modelContext.delete(record)
    try modelContext.save()
}
```

---

### 4. `FetchDescriptor` - 데이터 조회 설정

`FetchDescriptor`는 데이터를 어떻게 가져올지 정의합니다.

**전체 조회 + 최신순 정렬:** `MentoryRecordRepository.swift:39-44`

```swift
func fetchAll() async throws -> [MentoryRecord] {
    let descriptor = FetchDescriptor<MentoryRecord>(
        sortBy: [SortDescriptor(\.recordDate, order: .reverse)]
    )
    return try modelContext.fetch(descriptor)
}
```

**구성 요소:**
- `FetchDescriptor<MentoryRecord>`: MentoryRecord 타입을 조회
- `sortBy`: 정렬 방식 지정
- `SortDescriptor(\.recordDate, order: .reverse)`: recordDate 기준 내림차순 (최신이 먼저)

---

### 5. `#Predicate` 매크로 - 타입 안전한 필터링

`#Predicate`는 Swift 표현식으로 필터링 조건을 작성할 수 있게 해줍니다.

**오늘 날짜 기록만 조회:** `MentoryRecordRepository.swift:46-61`

```swift
func fetchToday() async throws -> [MentoryRecord] {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

    // 타입 안전한 조건식: 오늘 00:00 ~ 내일 00:00 사이
    let predicate = #Predicate<MentoryRecord> { record in
        record.recordDate >= today && record.recordDate < tomorrow
    }

    let descriptor = FetchDescriptor<MentoryRecord>(
        predicate: predicate,
        sortBy: [SortDescriptor(\.recordDate, order: .reverse)]
    )

    return try modelContext.fetch(descriptor)
}
```

**작동 원리:**
1. `calendar.startOfDay(for: Date())`: 오늘 0시 0분 0초
2. `calendar.date(byAdding: .day, value: 1, to: today)`: 내일 0시 0분 0초
3. `#Predicate`는 컴파일 타임에 타입을 체크하므로 안전
4. `record.recordDate >= today && record.recordDate < tomorrow`: 오늘 범위 내의 기록만 필터링

**날짜 범위 조회:** `MentoryRecordRepository.swift:63-74`

```swift
func fetchByDateRange(from: Date, to: Date) async throws -> [MentoryRecord] {
    let predicate = #Predicate<MentoryRecord> { record in
        record.recordDate >= from && record.recordDate <= to
    }

    let descriptor = FetchDescriptor<MentoryRecord>(
        predicate: predicate,
        sortBy: [SortDescriptor(\.recordDate, order: .reverse)]
    )

    return try modelContext.fetch(descriptor)
}
```

**장점:**
- String 기반 쿼리(`"recordDate >= today"`)보다 안전
- 컴파일러가 오타나 타입 오류를 자동으로 잡아줌
- 자동완성 지원으로 개발 속도 향상

---

### 6. Repository 패턴

Repository 패턴을 사용해 데이터 접근 로직을 캡슐화합니다.

**인터페이스 정의:** `MentoryRecordRepository.swift:12-19`

```swift
// MARK: Domain Interface
protocol MentoryRecordRepositoryInterface: Sendable {
    func save(_ record: MentoryRecord) async throws
    func fetchAll() async throws -> [MentoryRecord]
    func fetchToday() async throws -> [MentoryRecord]
    func fetchByDateRange(from: Date, to: Date) async throws -> [MentoryRecord]
    func delete(_ record: MentoryRecord) async throws
}
```

**구현:** `MentoryRecordRepository.swift:23-30`

```swift
// MARK: Domain
@MainActor
final class MentoryRecordRepository: MentoryRecordRepositoryInterface {
    // MARK: core
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // ... 메서드 구현
}
```

**장점:**
- **테스트 용이**: 프로토콜로 정의되어 있어 Mock 구현 가능
- **비즈니스 로직 분리**: SwiftData 의존성을 Repository에만 격리
- **유연성**: 나중에 다른 DB로 교체 시 Repository만 수정

---

### 7. `@MainActor` - 메인 스레드 격리

SwiftData의 `ModelContext`는 스레드 안전하지 않으므로, `@MainActor`로 메인 스레드에서만 실행되도록 보장합니다.

**Repository에서:** `MentoryRecordRepository.swift:23-24`
```swift
@MainActor
final class MentoryRecordRepository: MentoryRecordRepositoryInterface {
    // 이 클래스의 모든 메서드는 자동으로 메인 스레드에서 실행
}
```

**TodayBoard에서 사용:** `TodayBoard.swift:63-80`

```swift
@MainActor
final class TodayBoard: Sendable, ObservableObject {
    func saveRecord(_ record: MentoryRecord) async {
        // capture
        guard let repository = recordRepository else {
            logger.error("RecordRepository가 설정되지 않았습니다.")
            return
        }

        // process
        do {
            try await repository.save(record)  // 메인 스레드에서 안전하게 실행
            logger.info("레코드 저장 성공: \(record.id)")

            // 저장 후 오늘의 레코드 다시 로드
            await loadTodayRecords()
        } catch {
            logger.error("레코드 저장 실패: \(error)")
        }
    }
}
```

**중요:**
- `ModelContext`는 반드시 생성된 스레드에서만 사용해야 함
- `@MainActor`는 컴파일러가 자동으로 스레드 안전성 체크

---

### 8. `Sendable` 프로토콜

Swift Concurrency에서 타입 안전성을 보장하기 위해 `Sendable`을 사용합니다.

`MentoryRecordRepository.swift:13`

```swift
protocol MentoryRecordRepositoryInterface: Sendable {
    // 이 프로토콜을 따르는 타입은 다른 스레드/Task로 안전하게 전달 가능
}
```

**왜 필요한가?**
- Swift Concurrency는 데이터 레이스를 방지하기 위해 타입을 체크
- `Sendable`을 준수하면 다른 Task나 Actor로 안전하게 전달 가능
- Repository는 여러 곳에서 사용되므로 `Sendable` 필요

---

## 데이터 흐름

### 앱 시작 시 초기화

`MentoryApp.swift:20-37`

```swift
init() {
    // 1. ModelContainer 생성
    do {
        modelContainer = try ModelContainer(for: MentoryRecord.self)
    } catch {
        fatalError("Failed to initialize ModelContainer: \(error)")
    }

    // 2. Repository 생성 (mainContext 주입)
    let repository = MentoryRecordRepository(modelContext: modelContainer.mainContext)

    // 3. MentoryiOS 초기화 시 Repository 주입
    mentoryiOS = MentoryiOS(
        mentoryDB: MentoryDB(),
        alanLLM: AlanLLM(),
        recordRepository: repository
    )
}
```

**흐름:**
```
MentoryApp
    ↓ 생성
ModelContainer (for: MentoryRecord.self)
    ↓ mainContext
MentoryRecordRepository
    ↓ 주입
MentoryiOS
    ↓ 전달
TodayBoard
```

---

### 데이터 저장 과정

**1단계: MindAnalyzer에서 분석 결과 저장** `MindAnalyzer.swift:74-95`

```swift
private func saveRecord() async {
    // capture
    guard let recordForm = owner else {
        logger.error("RecordForm owner가 없습니다.")
        return
    }
    guard let todayBoard = recordForm.owner else {
        logger.error("TodayBoard owner가 없습니다.")
        return
    }

    // MentoryRecord 생성
    let record = MentoryRecord(
        recordDate: Date(),
        analyzedContent: self.analyzedResult,        // AI 분석 결과
        emotionType: self.mindType?.rawValue,        // 감정 타입
        completionTimeInSeconds: recordForm.completionTime  // 작성 시간
    )

    // TodayBoard를 통해 저장
    await todayBoard.saveRecord(record)
}
```

**2단계: TodayBoard에서 Repository 호출** `TodayBoard.swift:63-80`

```swift
func saveRecord(_ record: MentoryRecord) async {
    // capture
    guard let repository = recordRepository else {
        logger.error("RecordRepository가 설정되지 않았습니다.")
        return
    }

    // process
    do {
        try await repository.save(record)
        logger.info("레코드 저장 성공: \(record.id)")

        // 저장 후 오늘의 레코드 다시 로드
        await loadTodayRecords()
    } catch {
        logger.error("레코드 저장 실패: \(error)")
    }
}
```

**3단계: Repository에서 실제 저장** `MentoryRecordRepository.swift:34-37`

```swift
func save(_ record: MentoryRecord) async throws {
    modelContext.insert(record)  // ModelContext에 추가
    try modelContext.save()      // SQLite에 실제 저장
}
```

**흐름:**
```
사용자가 분석 완료
    ↓
MindAnalyzer.saveRecord()
    ↓ MentoryRecord 객체 생성
TodayBoard.saveRecord()
    ↓
MentoryRecordRepository.save()
    ↓
ModelContext.insert() + save()
    ↓
SQLite Database에 저장
```

---

### 데이터 조회 과정

**TodayBoard에서 오늘의 기록 로드** `TodayBoard.swift:82-99`

```swift
func loadTodayRecords() async {
    // capture
    guard let repository = recordRepository else {
        logger.error("RecordRepository가 설정되지 않았습니다.")
        return
    }

    // process
    do {
        let todayRecords = try await repository.fetchToday()
        logger.info("오늘의 레코드 \(todayRecords.count)개 로드 성공")

        // mutate
        self.records = todayRecords  // @Published 속성에 할당 → UI 자동 업데이트
    } catch {
        logger.error("레코드 로드 실패: \(error)")
    }
}
```

**Repository에서 오늘 기록 필터링** `MentoryRecordRepository.swift:46-61`

```swift
func fetchToday() async throws -> [MentoryRecord] {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

    let predicate = #Predicate<MentoryRecord> { record in
        record.recordDate >= today && record.recordDate < tomorrow
    }

    let descriptor = FetchDescriptor<MentoryRecord>(
        predicate: predicate,
        sortBy: [SortDescriptor(\.recordDate, order: .reverse)]
    )

    return try modelContext.fetch(descriptor)
}
```

**흐름:**
```
TodayBoard.loadTodayRecords()
    ↓
MentoryRecordRepository.fetchToday()
    ↓
#Predicate로 오늘 날짜 필터링
    ↓
FetchDescriptor로 최신순 정렬
    ↓
ModelContext.fetch()
    ↓
SQLite에서 조회
    ↓
[MentoryRecord] 반환
    ↓
TodayBoard.records에 할당
    ↓
@Published로 인해 UI 자동 업데이트
```

---

## 핵심 정리

### 1. 데이터 모델 계층
- `@Model` 매크로로 `MentoryRecord` 정의
- SwiftData가 자동으로 SQLite 테이블 생성
- Optional 타입 지원으로 유연한 모델링

### 2. 저장소 계층
- `ModelContainer`: 앱 시작 시 한 번만 초기화
- `ModelContext`: CRUD 작업 수행
- `mainContext`를 Repository에 주입

### 3. Repository 계층
- 프로토콜(`MentoryRecordRepositoryInterface`)로 인터페이스 정의
- `@MainActor`로 스레드 안전성 보장
- `async/await`로 비동기 처리
- `Sendable`로 동시성 안전성 보장

### 4. 도메인 계층
- `TodayBoard`, `MindAnalyzer` 등에서 Repository를 통해서만 데이터 접근
- 비즈니스 로직과 데이터 로직 분리
- 의존성 주입으로 테스트 용이

### 5. 조회 계층
- `FetchDescriptor`: 조회 설정
- `#Predicate`: 타입 안전한 필터링
- `SortDescriptor`: 정렬

---

## 실제 사용 예시 정리

### 전체 조회
`MentoryRecordRepository.swift:39-44`
```swift
repository.fetchAll()  // 모든 기록을 최신순으로
```

### 오늘 기록 조회
`MentoryRecordRepository.swift:46-61`
```swift
repository.fetchToday()  // 오늘 0시 ~ 내일 0시 사이 기록
```

### 날짜 범위 조회
`MentoryRecordRepository.swift:63-74`
```swift
repository.fetchByDateRange(from: startDate, to: endDate)
```

### 저장
`MentoryRecordRepository.swift:34-37`
```swift
let record = MentoryRecord(/* ... */)
repository.save(record)
```

### 삭제
`MentoryRecordRepository.swift:76-79`
```swift
repository.delete(record)
```

---

## 참고 자료

- [Apple SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [WWDC23: Meet SwiftData](https://developer.apple.com/videos/play/wwdc2023/10187/)
- [WWDC23: Build an app with SwiftData](https://developer.apple.com/videos/play/wwdc2023/10154/)
