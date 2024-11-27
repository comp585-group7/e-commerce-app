import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() async {
  // Ensure plugin services are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Get a list of available cameras
  final cameras = await availableCameras();

  // Select the first available camera (typically the rear camera)
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera, cameras: cameras));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.camera, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(camera: camera, cameras: cameras),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final List<CameraDescription> cameras;

  const CameraScreen({Key? key, required this.camera, required this.cameras}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late CameraDescription _currentCamera;

  @override
  void initState() {
    super.initState();
    _currentCamera = widget.camera;

    // Initialize the camera controller
    _controller = CameraController(
      _currentCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Method to switch between cameras
  void _switchCamera() {
    setState(() {
      // Get the other camera (toggle between front and back)
      int currentIndex = widget.cameras.indexOf(_currentCamera);
      int newIndex = (currentIndex + 1) % widget.cameras.length;

      _currentCamera = widget.cameras[newIndex];

      // Reinitialize the controller with the new camera
      _controller = CameraController(
        _currentCamera,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _controller.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Switch')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Camera preview
                CameraPreview(_controller),
                // Switch camera button
                ElevatedButton(
                  onPressed: _switchCamera,
                  child: const Text('Switch Camera'),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
