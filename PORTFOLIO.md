# Portfolio (포트폴리오)

- **프로젝트: Cam_cook — Flutter 모바일 앱**
  - **사용한 프로그램:** Flutter, Dart, Android Studio, Xcode, Gradle, Git, Visual Studio Code, PyTorch (모델 준비), TorchScript, `flutter_pytorch` 플러그인, Pigeon(플랫폼 채널)
  - **작품 설명:** 모바일 카메라로 식자재를 실시간 인식하고, 인식된 식자재를 바탕으로 만들 수 있는 레시피를 추천하는 앱입니다. YOLO 기반의 커스텀 물체감지 모델을 모바일 환경에 통합하여 네이티브 코드와 연동해 실행하도록 구성했습니다.

- **프로젝트: Food Ingredient YOLO 모델**
  - **사용한 프로그램:** Python, PyTorch, Ultralytics YOLO (YOLOv8), Jupyter Notebook, 라벨링 툴(예: LabelImg), (선택) CUDA, Git
  - **작품 설명:** COCO 형식 데이터로 식자재(과일·채소·육류 등) 객체 탐지용 커스텀 YOLO 모델을 학습한 연구·실험 프로젝트입니다. 데이터 전처리와 학습 실험은 노트북에서 수행하였고, 학습된 모델(`best.pt`, `last.pt`)과 실험 결과는 `runs/` 폴더에 보관되어 있습니다.

  - **훈련 세부사항 및 성능 요약:**
    - **아키텍처:** YOLOv8 (작은 버전, `yolov8n`) 기반으로 실험 진행 (기본 가중치 `yolov8n.pt` 사용).
    - **클래스 수:** 38개 (COCO 형식, `data.yaml`의 `nc: 38`).
    - **학습 기간:** 약 100 epochs로 학습(학습 로그 `runs/detect/train/results.csv` 참조).
    - **주요 성능 지표 (best):**
      - mAP@0.5 (mAP50): 약 44.8% (best 기준)
      - mAP@0.5:0.95 (mAP50-95): 약 29% 대
      - Precision / Recall (peak): Precision 약 53% 수준, Recall 약 47% 수준 (로그에 기록된 최고치 기준)
    - **해석:** 클래스 수가 많고(38개) 데이터 불균형이 있을 수 있어 mAP는 중간 수준입니다. PR 곡선, 혼동행렬, F1 곡선 등이 `runs/detect/train/`에 저장되어 있어 클래스별 성능과 오탐/미탐을 자세히 분석할 수 있습니다.
    - **저장된 산출물:** `runs/detect/train/weights/best.pt`, `runs/detect/train/weights/last.pt`, `runs/detect/train/confusion_matrix.png`, `runs/detect/train/PR_curve.png` 등

원하시면 위 문구를 더 간단히 요약하거나 영어 번역본으로 변환해 드리겠습니다.
