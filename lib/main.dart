import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:image_picker/image_picker.dart';

Future<void> main() async { // 여기서 어플 구동

  //그럼 여기서부터 구동하겠네
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized(); // 비동기 사용하기 위한 코드

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras(); // 카메라 활성화(권한같이)

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first; // 첫번째 카메라(후면의미 추정)

  runApp( // 앱 띄어주세요
    MaterialApp( // 이렇게 생긴 뷰로 출력
      theme: ThemeData.dark(), // 다크 배경은 영원하다(?)
      home: TakePictureScreen( // TakePictureScreen 뷰 띄어주세요.
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera, // 무슨 카메라?
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    key,
    required this.camera,
  });

  final CameraDescription camera;

  @override // 뷰 새롭게 생성되면 TakePictureScreenState 실행해주셈
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;


  File? _imageFile;
  late ModelObjectDetection _objectModel;
  String? _imagePrediction;
  List? _prediction;
  File? _image;
  ImagePicker _picker = ImagePicker();
  bool objectDetection = false;
  List<ResultObjectDetection?> objDetect = [];

  // late List _outputs;
  // late File _image;
  // late bool _loading = false;


  @override
  void initState() { // 클래스 생성자 느낌으로 보면 됨
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController( // 카메라 모듈 실행
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium, // 휴대폰 좋은 기종이면, ResolutionPresent.high 으로 해보세요
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize(); // 초기화 과정

    // pytorch model load
    loadModel();
  }

  @override
  Future<void> dispose() async { // OCR 결과 위젯으로 옮겨질 때 실행되는 이벤트(위젯이 닫힐 때 실행되는 코드)
    // Dispose of the controller when the widget is disposed.
    _controller.dispose(); // camera 메모리 초기화(카메라 기능 끔)
    super.dispose();
  }

  Future loadModel() async {
    String pathObjectDetectionModel = "assets/models/yolov8n.torchscript";
    try {
      _objectModel = await FlutterPytorch.loadObjectDetectionModel(
        //Remeber here 80 value represents number of classes for custom model it will be different don't forget to change this.
          pathObjectDetectionModel, 80, 640, 640,
          labelPath: "assets/labels/labels.txt");
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }

  // object detection model running after process...
  Future runObjectDetection() async {
    //pick an image

    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 200, maxHeight: 200);
    objDetect = await _objectModel.getImagePrediction(
        await File(image!.path).readAsBytes(),
        minimumScore: 0.1,
        IOUThershold: 0.3);
    objDetect.forEach((element) {
      print({
        "score": element?.score,
        "className": element?.className,
        "class": element?.classIndex,
        "rect": {
          "left": element?.rect.left,
          "top": element?.rect.top,
          "width": element?.rect.width,
          "height": element?.rect.height,
          "right": element?.rect.right,
          "bottom": element?.rect.bottom,
        },
      });
    });
    setState(() {
      _image = File(image!.path);
    });
  }

  @override
  Widget build(BuildContext context) { // 화면 어떻게 띄울 것인지 코드 작성(카메라 미리보기, 카메라 찍기 버튼 등)
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')), // 상단 위 "Take a picture" 띄우기
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: Column( // 본격적인 xml 코드 짠다고 보면 됨
        children: [
          FutureBuilder<void>( // 위젯 어떤거 넣을 것인지 FutureBuilder가 비동기 구동하기 위한 위젯 사용
            future: _initializeControllerFuture, // 카메라 컨트롤 관련 대기 및 비동기 구동
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) { // 완전히 로딩 됬는가?
                // If the Future is complete, display the preview.
                return CameraPreview(_controller); // 그럼 카메라 이미지 계속 띄어주셈
              } else { // 아직도 카메라 기능 로딩중이면
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator()); // 로딩바 보여주셈
              }
            },
          ),
          FloatingActionButton( // 이미지 버튼 위젯 일반적인 Button 위젯이라고 보면 됨
            // Provide an onPressed callback.
            onPressed: () async { // 만약 버튼 누르면?
              // Take the Picture in a try / catch block. If anything goes wrong,
              // catch the error.
              try { // 예외처리 코드 작성함
                // Ensure that the camera is initialized.
                await _initializeControllerFuture; // 카메라 초기화

                // Attempt to take a picture and get the file `image`
                // where it was saved.
                final image = await _controller.takePicture(); // 사진 찍기




                // 아래 코드는 tflite 예제 코드임.
                loadModel().then((value) async {

                  // var outputLabel = await Tflite.runModelOnImage(
                  //     path: image.path,   // required
                  //     imageMean: 0.0,   // defaults to 117.0
                  //     imageStd: 255.0,  // defaults to 1.0
                  //     numResults: 2,    // defaults to 5
                  //     threshold: 0.2,   // defaults to 0.1
                  //     asynch: true      // defaults to true
                  // );

                  await Navigator.of(context).push( // 다른 위젯 보여주셈(다른 XML로 띄어주세요.)
                    MaterialPageRoute( // 다른 인텐트, Fragment 기능이라고 보면 될듯 합니다.
                      builder: (context) => DisplayPictureScreen( // DisplayPictureScreen 뷰 보여주셈
                        // Pass the automatically generated path to
                        // the DisplayPictureScreen widget.
                        imagePath: image.path, //이미지 경로 인자 넣기
                        output:outputLabel![0]['label'], // OCR 결과 인자
                      ),
                    ),
                  );


                });
                // If the picture was taken, display it on a new screen.

              } catch (e) { // 예외처리 하던 도중 에러가 발생하다면?
                // If an error occurs, log the error to the console.
                print(e); // 콘솔창에 에러 출력
              }
            },
            child: const Icon(Icons.camera_alt), // 버튼 이미지는 camera_alt로 설정
          ),
        ],
      ),
    );
  }

  // loadModel() async {
  //   await Tflite.loadModel(
  //       model: 'assets/mobilenet_v1_1.0_224.tflite',
  //       labels:'assets/mobilenet_v1_1.0_224.txt',
  //       numThreads: 1,
  //       isAsset: true, // defaults to true, set to false to load resources outside assets
  //       useGpuDelegate: false // defaults to false, set to true to use GPU delegate
  //   );
  // }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget { // OCR 결과를 혹인하는 위젯 화면,
  final String imagePath; // 이미지 파일 경로
  final String output; // OCR 결과 가지고 있음.

  // 위젯 받아올 인자들, 2가지(이미지 경로, OCR 결과 텍스트)
  const DisplayPictureScreen({key, required this.imagePath, required this.output});

  @override
  Widget build(BuildContext context) { // 어떻게 화면 보여줄텐가?
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')), // 상단 출력할 내용
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: ListView( // 흔히 아는 리스트 뷰(상하)
        children: [
          Image.file(File(imagePath)), // 이미지 띄우기
          Text(output), // OCR 텍스트 출력
        ],
      ),
    );
  }
}