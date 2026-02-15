import 'package:flutter/services.dart';
import 'package:flutter_azimuth/flutter_azimuth.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:flutter_azimuth_example/stream.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(const ExapleAzimuthApp());
}

class ExapleAzimuthApp extends StatelessWidget {
  const ExapleAzimuthApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Azimuth Example',
      theme: CupertinoThemeData(
        primaryColor: Color(0xFF771089),
        barBackgroundColor: Color(0xFF171717),
        brightness: Brightness.dark,
      ),
      home: ExapleAzimuthBodyApp(),
    );
  }
}

class ExapleAzimuthBodyApp extends StatefulWidget {
  const ExapleAzimuthBodyApp({Key? key}) : super(key: key);

  @override
  State<ExapleAzimuthBodyApp> createState() => _ExapleAzimuthBodyAppState();
}

class _ExapleAzimuthBodyAppState extends State<ExapleAzimuthBodyApp> {
  /// check if device has sensors
  int? haveSensor;

  /// check if device has sensors
  late String sensorType;

  @override
  void initState() {
    super.initState();
    checkDeviceSensors();
    sensorType = '';
  }

  Future<void> checkDeviceSensors() async {
    int? haveSensor;

    try {
      haveSensor = await FlutterAzimuth.checkSensors;

      switch (haveSensor) {
        case 0:
          {
            // statements;
            sensorType = "No sensors for Compass";
          }
          break;

        case 1:
          {
            //statements;
            sensorType = "Accelerometer + Magnetoneter";
          }
          break;

        case 2:
          {
            //statements;
            sensorType = "Gyroscope";
          }
          break;

        default:
          {
            //statements;
            sensorType = "Error!";
          }
          break;
      }
    } on Exception {
      //
    }

    if (!mounted) return;

    setState(() {
      haveSensor = haveSensor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("SensorType: $sensorType"),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamWidget<int?>(
              stream: FlutterAzimuth.azimuthStream,
              child: (snapshot) {
                /* double size2 = 300.0;
                  var factor = (13.5 / 50); */
                return Column(
                  children: [
                    Hero(
                      tag: 'fluttercompass',
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const CompassBackground(),
                          RotationTransition(
                            turns: AlwaysStoppedAnimation(snapshot! / 360),
                            child: const CompassForeground(),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        RotationTransition(
                          turns: AlwaysStoppedAnimation(-snapshot / 360),
                          child: const CompassBackground(),
                        ),
                        const CompassForeground(),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CompassBackground extends StatelessWidget {
  const CompassBackground({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/compass-dark.png');
  }
}

class CompassForeground extends StatelessWidget {
  const CompassForeground({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/compass.png');
  }
}
