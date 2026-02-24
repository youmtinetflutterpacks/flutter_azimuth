<div align="center">
<div align="center">
    <img src="https://raw.githubusercontent.com/youmtinetflutterpacks/flutter_azimuth/refs/heads/main/assets/flutter_azimuth.png" alt="flutter_azimuth logo"/>
</div>

[![pub package](https://img.shields.io/pub/v/flutter_azimuth.svg)](https://pub.dev/packages/flutter_azimuth)
[![pub likes](https://img.shields.io/pub/likes/flutter_azimuth.svg)](https://pub.dev/packages/flutter_azimuth/score)
[![pub points](https://img.shields.io/pub/points/flutter_azimuth.svg?color=blue)](https://pub.dev/packages/flutter_azimuth/score)
[![platform](https://img.shields.io/badge/platform-flutter-blue)](https://flutter.dev)

[![GitHub stars](https://img.shields.io/github/stars/ymrabti/flutter_azimuth.svg?style=flat&logo=github&colorB=&label=Stars)](https://github.com/ymrabti/flutter_azimuth/stargazers)
[![GitHub issues](https://img.shields.io/github/issues/ymrabti/flutter_azimuth.svg?style=flat&logo=github&colorB=&label=Issues)](https://github.com/ymrabti/flutter_azimuth/issues)
[![GitHub license](https://img.shields.io/github/license/ymrabti/flutter_azimuth.svg?style=flat&logo=github&colorB=&label=License)](https://github.com/ymrabti/flutter_azimuth/blob/main/LICENSE)
[![GitHub last commit](https://img.shields.io/github/last-commit/ymrabti/flutter_azimuth.svg?style=flat&logo=github&colorB=&label=Last%20Commit)](https://github.com/ymrabti/flutter_azimuth/commits/main)


[![Build status](https://github.com/ymrabti/flutter_azimuth/workflows/Publish%20to%20pub.dev/badge.svg?style=flat&logo=github&colorB=&label=Build)](https://github.com/youmtinetflutterpacks/flutter_azimuth)

&nbsp; 📦 [Download the latest APK](https://github.com/ymrabti/flutter_azimuth/releases/latest/download/flutter_azimuth_demo-release-universal.apk)

</div>

Flutter plugin for reading the device azimuth to build compass-like experiences. Uses the available position sensors on Android and azimuth data on iOS.

![Image](https://github.com/youmtinetflutterpacks/flutter_azimuth/blob/main/demogif.gif?raw=true)

## Versioning policy

- The package version mirrors the minimum supported Flutter version. Example: release `3.10.8` requires Flutter `3.10.8` or newer.
- When you upgrade Flutter, bump to the matching `flutter_azimuth` version to stay compatible.

## Install

Add the package that matches your Flutter version:

```yaml
dependencies:
  flutter_azimuth: 3.41.1
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

## Issues

Please file any issues, bugs or feature requests as an issue on our [GitHub](https://github.com/ymrabti/flutter_azimuth/issues) page. Commercial support is available, you can contact us at <hello@baseflow.com>.


## 🔗 More Packages

- [Power Geojson](https://pub.dev/packages/power_geojson)
- [Popup Menu 2](https://pub.dev/packages/popup_menu_2)
- [Map Contextual Menu](https://pub.dev/packages/longpress_popup)
- [Simple Logger](https://pub.dev/packages/console_tools)

---

## 👨‍💻 Developer Card

<div align="center">
    <img src="https://avatars.githubusercontent.com/u/47449165?v=4" alt="Younes M'rabti avatar" width="120" height="120" style="border-radius: 50%;" />

### Younes M'rabti

📧 Email: [admin@youmti.net](mailto:admin@youmti.net)  
🌐 Website: [youmti.net](https://www.youmti.net/)  
💼 LinkedIn: [younesmrabti1996](https://www.linkedin.com/in/younesmrabti1996/)
</div>
