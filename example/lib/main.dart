import 'package:flutter_azimuth/flutter_azimuth.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:flutter_azimuth_example/stream.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? haveSensor;
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
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Azimuth Example',
      theme: const CupertinoThemeData(
        primaryColor: Color(0xFF771089),
        barBackgroundColor: CupertinoColors.darkBackgroundGray,
        brightness: Brightness.dark,
      ),
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("SensorType: " + sensorType),
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
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const CompassBackground(),
                          RotationTransition(
                            turns: AlwaysStoppedAnimation(snapshot! / 360),
                            child: const CompassForeground(),
                          ),
                        ],
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
