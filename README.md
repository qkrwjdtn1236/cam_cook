# Cam_cook

Flutter Framework를 기반으로 레시피를 추천합니다. 현재 가지고 있는 식자재를 사진을 통해서 인식하며, 인식한 식자재 포함하여 만들 수 있는 레시피를 추천하여 제공합니다.

## 식자재 인식 pretraining Custom YOLO model
COCO format으로 구성된 데이터를 제공하고 있습니다. 또한 아래와 같은 내용으로 데이터 label 제공되고 있습니다.

```
{0: '-',
1: '아몬드',
2: '사과',
3: '아보카도',
4: '쇠고기',
5: '피망',
6: '블루베리',
7: '빵',
8: '브로콜리',
9: '버터',
10: '당근',
11: '치즈',
12: '칠리',
13: '쿠키',
14: '옥수수',
15: '오이',
16: '계란',
17: '가지',
18: '마늘',
19: '레몬',
20: '우유',
21: '모짜렐라 치즈',
22: '버섯',
23: '홍합',
24: '양파',
25: '굴',
26: '파마산 치즈',
27: '파스타',
28: '돼지고기 갈비',
29: '감자',
30: '연어',
31: '가리비',
32: '새우',
33: '딸기',
34: '토스트 빵',
35: '토마토',
36: '참치',
37: '요거트'}
```

위 내용으로 인식한 내용을 기반하여 식자재를 인식합니다.

## 레피치 추천 데이터
식자재 인식한 것들을 pytorch_flutter 패키지를 기반으로 yolo 모델을 모바일에서 구동하여 식자재를 인식합니다.

## preview
![Recording_2023-08-02-10-52-50-ezgif com-video-to-gif-converter (3)](https://github.com/user-attachments/assets/012c7067-2847-408d-b247-7cc2b4b79cbe)


# TMI
* 구현은 3일만에 만든..ㅎㅎ
