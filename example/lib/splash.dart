import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_azimuth_example/main.dart';
import 'package:video_player/video_player.dart';

class NativeSplashVideo extends StatefulWidget {
  const NativeSplashVideo({Key? key}) : super(key: key);

  @override
  State<NativeSplashVideo> createState() => _NativeSplashVideoState();
}

class _NativeSplashVideoState extends State<NativeSplashVideo> {
  late VideoPlayerController _controller;
  bool _ended = false;

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
    await _controller.play();
    _controller.addListener(() async {
      bool ended = _controller.value.position == _controller.value.duration;
      if (ended) {
        if (!_ended) {
          setState(() {
            _ended = ended;
          });
        } else {
          await SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          );
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (contxt) => const ExapleAzimuthBodyApp(),
            ),
            (route) => false,
          );
        }
      }
    });
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
