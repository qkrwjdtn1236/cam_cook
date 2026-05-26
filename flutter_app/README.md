
# Flutter PyTorch 플러그인을 활용한 Cam_cook 앱

## 📱 주요 기능

### 1. **실시간 카메라 식자재 인식**
   - **기능:** 모바일 카메라를 통해 식자재를 실시간으로 감지
   - **구현:** `RunModelByCameraDemo.dart`에서 카메라 스트림 처리
   - **모델:** 커스텀 YOLO v8 객체 탐지 모델 (38개 식자재 클래스)
   - **UI:** `camera_view.dart`에서 카메라 화면 및 탐지 박스 렌더링

### 2. **이미지 기반 식자재 인식**
   - **기능:** 갤러리에서 선택한 이미지 또는 촬영 이미지에서 식자재 인식
   - **구현:** `RunModelByImageDemo.dart`에서 정적 이미지 처리
   - **출력:** 인식된 식자재 목록 및 신뢰도 점수 표시

### 3. **플랫폼 채널 통합 (Pigeon)**
   - **기능:** Flutter와 네이티브 코드(Android/iOS) 간 양방향 통신
   - **구현:** `pigeon.dart`, `pigeon.h`, `pigeon.m`, `SwiftFlutterPytorchPlugin.swift` 활용
   - **목적:** PyTorch 모델을 네이티브 성능으로 실행하고 결과 반환

### 4. **PyTorch 모바일 모델 실행**
   - **기능:** TorchScript 형식의 모델을 모바일에서 경량 실행
   - **지원:** Android (Java), iOS (Swift/Objective-C)
   - **모델 포맷:** `.pt` (TorchScript), `.torchscript` (최적화 모델)

### 5. **객체 탐지 결과 시각화**
   - **기능:** 탐지된 식자재 주위에 바운딩 박스 그리기
   - **구현:** `box_widget.dart`에서 박스 위젯 정의
   - **정보 표시:** 식자재명, 신뢰도 점수, 위치 좌표

### 6. **이미지 전처리**
   - **기능:** 카메라/갤러리 이미지를 모델 입력 형식으로 변환
   - **구현:** `utils/image_utils.dart`에서 리사이징, 정규화(normalization) 처리
   - **입력 크기:** 640×640 (YOLO 표준)

## 🛠️ 사용된 프로그램 & 기술 스택

- **프레임워크:** Flutter (Dart)
- **개발 환경:** Android Studio, Xcode, Visual Studio Code
- **빌드 도구:** Gradle (Android), CocoaPods (iOS)
- **머신러닝:** PyTorch, TorchScript, `flutter_pytorch` 플러그인
- **플랫폼 연동:** Pigeon (코드 생성), Method Channel
- **네이티브 코드:** Java (Android), Swift/Objective-C (iOS)
- **버전 관리:** Git

## 📂 핵심 파일 구조

```
lib/
├── main.dart                          # 앱 진입점
├── RunModelByCameraDemo.dart          # 실시간 카메라 인식 화면
├── RunModelByImageDemo.dart           # 이미지 인식 화면
├── ui/
│   ├── camera_view.dart               # 카메라 UI 렌더링
│   ├── camera_view_singleton.dart     # 카메라 싱글톤 관리
│   └── box_widget.dart                # 탐지 박스 UI 위젯
└── utils/
    └── image_utils.dart               # 이미지 전처리 유틸

ios/Classes/
├── SwiftFlutterPytorchPlugin.swift    # iOS PyTorch 네이티브 구현
├── FlutterPytorchPlugin.m/.h          # Objective-C 브릿지
└── pigeon.m/.h                        # Pigeon 생성 코드

android/src/main/java/com/aneeqmalik/
└── FlutterPytorchPlugin.java          # Android PyTorch 네이티브 구현
```

## 🎯 작동 흐름

1. **카메라 시작** → 카메라 프레임 수집
2. **이미지 전처리** → 640×640으로 리사이징 + 정규화
3. **PyTorch 모델 추론** → 네이티브 코드에서 YOLO 실행
4. **결과 반환** → Pigeon을 통해 Flutter로 탐지 데이터 전달
5. **UI 렌더링** → 바운딩 박스 및 식자재명 표시

