# Flutter Azimuth Plugin

[![pub package](https://img.shields.io/pub/v/flutter_azimuth.svg)](https://pub.dev/packages/flutter_azimuth) ![Build status](https://github.com/ymrabti/flutter_azimuth/workflows/flutter_azimuth/badge.svg?branch=main) [![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://github.com/tenhobi/effective_dart) [![codecov](https://codecov.io/gh/ymrabti/flutter_azimuth/branch/main/graph/badge.svg)](https://codecov.io/gh/ymrabti/flutter_azimuth)

Flutter plugin for reading the device azimuth to build compass-like experiences. Uses the available position sensors on Android and azimuth data on iOS.

![Image](https://github.com/ymrabti/flutter_azimuth/blob/main/demogif.gif?raw=true) | ![](https://github.com/ymrabti/flutter_azimuth/blob/main/demogif.mp4?raw=true)

## Versioning policy

- The package version mirrors the minimum supported Flutter version. Example: release `3.10.8` requires Flutter `3.10.8` or newer.
- When you upgrade Flutter, bump to the matching `flutter_azimuth` version to stay compatible.

## Install

Add the package that matches your Flutter version:

```yaml
dependencies:
  flutter_azimuth: 3.10.8
```

## Features

- Get the angle of azimuth as a stream for compass UIs.

## Example

The code below shows an example on how to acquire the current position of the device, including checking if the location services are enabled and checking / requesting permission to access the position of the device:

```dart
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

```


### TO DO

Implementation iOS



## Issues

Please file any issues, bugs or feature requests as an issue on our [GitHub](https://github.com/ymrabti/flutter_azimuth/issues) page. Commercial support is available, you can contact us at <hello@baseflow.com>.



## Author

This Azimuth plugin for Flutter is developed by [ymrabti](https://baseflow.com).
