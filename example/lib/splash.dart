import 'package:flutter/material.dart';
import 'package:flutter_azimuth_example/main.dart';
import 'package:video_player/video_player.dart';

class NativeSplashVideo extends StatefulWidget {
  const NativeSplashVideo({Key? key}) : super(key: key);

  @override
  State<NativeSplashVideo> createState() => _NativeSplashVideoState();
}

class _NativeSplashVideoState extends State<NativeSplashVideo> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    _controller = VideoPlayerController.asset('assets/video-splash.mp4')
      ..initialize().then((value) => setState(() {}))
      ..setVolume(0);
    super.initState();
    _playVideo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _playVideo() async {
    _controller.play();
    await Future.delayed(const Duration(seconds: 3));
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (contxt) => const ExapleAzimuthBodyApp(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: 1,
                child: Hero(
                  tag: 'fluttercompass',
                  child: VideoPlayer(_controller),
                ),
              )
            : Container(),
      ),
    );
  }
}
