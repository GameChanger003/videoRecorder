import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:video_recoder/features/camera/videoRecoder.dart';

List<CameraDescription> camera=[];
Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  camera=await availableCameras();
runApp(const MyApp());
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: VideoRecorder(camera),
    );
  }
}