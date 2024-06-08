// ignore_for_file: file_names

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as pathprovider;
import 'package:gallery_saver/gallery_saver.dart';

class VideoRecorder extends StatefulWidget {
  final List<CameraDescription> cameras;
  const VideoRecorder(this.cameras);

  @override
  State<VideoRecorder> createState() => _VideoRecorderState();
}

class _VideoRecorderState extends State<VideoRecorder> {
  late CameraController controller;
  bool isRecording=false;
  String _videoPath='';
  int _selectCameraidx=0;
  bool _isFrontCamera=false;
  bool _isFlashOn=false;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    }); 
  }

@override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _switchCamera() async{
    if(controller!=null){
      await controller.dispose();
    }
    _selectCameraidx=(_selectCameraidx+1)%widget.cameras.length;
    _initCamera(_selectCameraidx);
  }

  Future <void> _initCamera(int idx) async{
    controller=CameraController(widget.cameras[idx], ResolutionPreset.max);
    try {
      await controller.initialize();
      setState(() {
        if(idx==0){
          _isFrontCamera=false;
        }
        else{
          _isFrontCamera=true;          
        }
      });
    } catch (e) {
      print(e);
    }

    if(mounted){
      setState(() {
      });
    }
  }

  //FlashLight Toggle 
  void _toggleFlashLight(){
    if(_isFlashOn){
      controller.setFlashMode(FlashMode.off);
      setState(() {
      _isFlashOn=false;
      });
    }
    else{
      controller.setFlashMode(FlashMode.torch);
      setState(() {
      _isFlashOn=true;
      });
    }
  }


  //Recording Toggle
  void toggleRecording(){
    if (isRecording) {
      _stopRecording();
    }
    else {
      _startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.black
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: (){
                          _toggleFlashLight();
                        },
                        child: _isFlashOn==false? const Icon(Icons.flash_off,color: Colors.white,):const Icon(Icons.flash_on,color: Colors.white,)),
                        GestureDetector(
                          onTap: (){
                            _switchCamera();
                          },
                          child: const Icon(Icons.cameraswitch_outlined,color: Colors.white,),
                        )

                    ],
                  ),
                ),
              ),
              Positioned.fill(
                top: 50,
                // bottom: _isFrontCamera==false?0:150,
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller),
                  ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: _isFrontCamera==false?Colors.black45:Colors.black,
                  ),
                  child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10,),
                      const Text("Video",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                      const SizedBox(height: 20,),
                      GestureDetector(
                        onTap: (){
                          toggleRecording();
                        },
                        child: Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                width: 4,
                                color: Colors.white,
                                style: BorderStyle.solid
                              )
                            ),
                            child: isRecording==false
                            ?const Icon(Icons.play_arrow,size: 40,color: Colors.white,):Icon(Icons.stop,size: 40,color: Colors.red[400],),
                          ),
                      )
                    
                    ],
                  ),
                )),
            ],
          );
        },
      ),
    ));
  }

//Stop recording
void _stopRecording() async{
if(controller.value.isRecordingVideo){
  try {
    
    final XFile videoFile=await controller.stopVideoRecording();
    setState(() {
      isRecording=false;
    });
    if(_videoPath.isNotEmpty){
      final File file=File(videoFile.path);
      await file.copy(_videoPath);
      await GallerySaver.saveVideo(_videoPath);
    }
  } catch (e) {
    print(e);
  }
}
}

//to start recording
void _startRecording() async{
  if(!controller.value.isRecordingVideo){
    final directory =await pathprovider.getTemporaryDirectory();
    final pth='${directory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4';

    try{
      await controller.initialize();
      await controller.startVideoRecording();
      setState(() {
        isRecording = true;
      _videoPath=pth;
      });
    }
    catch(e){
      print(e);
      return;
    }
  }
}
}