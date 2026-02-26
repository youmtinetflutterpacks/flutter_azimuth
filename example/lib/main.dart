import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_azimuth/flutter_azimuth.dart';
import 'package:flutter_azimuth_example/audio_bytes.dart';
import 'package:flutter_azimuth_example/settings.dart';
import 'package:flutter_azimuth_example/stream.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

void main() {
  runApp(const AzimuthApp());
}

class AzimuthApp extends StatelessWidget {
  const AzimuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff0B1220),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF02569B),
          secondary: Color(0xFF13B9FD),
          surface: Color(0xFF111827),
          onSurface: Color(0xFFE5E7EB),
        ),
      ),
      home: const CompassScreen(),
    );
  }
}

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioAsset _selectedAudio = AudioAsset.tick_01;
  double _heading = 127.0;
  bool _playSoundOnChange = true;
  bool _playHapticsOnChange = false;
  int _selectedIndex = 1;

  /// check if device has sensors
  int? haveSensor = 0;

  /// check if device has sensors
  String sensorType = '';

  @override
  void initState() {
    super.initState();
    // Simulate a slight movement for dev-demo vibes
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await checkDeviceSensors();
      _controller.addListener(() async {
        setState(() {
          _heading = 127.0 + (_controller.value * 12.0);
        });
        if (_playSoundOnChange) {
          log('Heading changed: ${_heading.toInt()}°', name: 'FlutterAzimuth');
          await _audioPlayer.play(
            BytesSource(_selectedAudio.bytes),
            volume: 0.5,
          );
        }
        if (_heading.toInt() % 5 == 0 && _playHapticsOnChange) {
          await Haptics.vibrate(HapticsType.soft);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/logo.png'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Flutter Azimuth',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFE5E7EB),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Builder(
          builder: (context) {
            switch (_selectedIndex) {
              case 0:
                return _calibrateSection();
              case 1:
                return _headingSection();
              case 2:
                return _settingsSection();
              default:
                return _headingSection();
            }
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0B1220),
        indicatorColor: const Color(0xFF02569B).withValues(alpha: 0.5),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.tune), label: 'Calibrate'),
          NavigationDestination(icon: Icon(Icons.navigation), label: 'Heading'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _calibrateSection() {
    return const Center(
      child: Text(
        'Calibration coming soon!',
        style: TextStyle(fontSize: 18, color: Colors.white70),
      ),
    );
  }

  Widget _settingsSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sensor Type: $sensorType',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Text(
          'Have Sensor Code: $haveSensor',
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: checkDeviceSensors,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF02569B),
              ),
              child: const Text(
                'Check Sensors',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => _audioPlayer.play(
                BytesSource(_selectedAudio.bytes),
                volume: 0.5,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF13B9FD),
              ),
              child: const Text(
                'Play Tick Sound',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        _tickSection(),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Play Tick Sound on Heading Change',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Play a tick sound whenever the heading changes.',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          value: _playSoundOnChange,
          onChanged: (bool newValue) {
            setState(() {
              _playSoundOnChange = newValue;
            });
          },
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Play Haptics on Heading Change',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Play a subtle vibration whenever the heading changes.',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          value: _playHapticsOnChange,
          onChanged: (bool newValue) {
            setState(() {
              _playHapticsOnChange = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _tickSection() {
    return Row(
      spacing: 12,
      children: [
        Text(
          'Select Tick Sound:',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: DropdownButton(
            enableFeedback: true,
            value: _selectedAudio,
            isExpanded: true,
            items: AudioAsset.values.map((e) {
              return DropdownMenuItem(value: e, child: Text(e.name));
            }).toList(),
            onChanged: (AudioAsset? newValue) {
              setState(() {
                _selectedAudio = newValue ?? AudioAsset.tick_01;
              });
            },
          ),
        ),
      ],
    );
  }

  Column _headingSection() {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Heading Degree Readout
        Text(
          '${_heading.toInt()}°',
          style: const TextStyle(
            fontFamily: 'Digital',
            fontSize: 120,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        // Compass UI
        Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (haveSensor != 0)
                  StreamWidget<int?>(
                    stream: FlutterAzimuth.azimuthStream,
                    child: (snapshot) {
                      /* double size2 = 300.0;
                var factor = (13.5 / 50); */
                      return CustomPaint(
                        size: const Size(300, 300),
                        painter: CompassPainter(
                          heading: snapshot?.toDouble() ?? _heading,
                        ),
                      );
                    },
                  )
                else
                  CustomPaint(
                    size: const Size(300, 300),
                    painter: CompassPainter(heading: _heading),
                  ),
                // Center Glow
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF13B9FD).withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        // Sensor Status Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: haveSensor != 0
                ? const Color(0xFF111827)
                : Colors.redAccent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            spacing: 12,
            children: [
              if (haveSensor != 0)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF29B6F6),
                  size: 24,
                )
              else
                const Icon(Icons.cancel, color: Colors.redAccent, size: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (haveSensor != 0)
                      Text(
                        'Sensor Status: Active',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'Sensor Status: Inactive, showing simulated data',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.redAccent,
                        ),
                      ),
                    if (haveSensor != 0)
                      Text(
                        'Accuracy: High',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Future<void> checkDeviceSensors() async {
    int? haveSensor;

    try {
      haveSensor = await FlutterAzimuth.checkSensors;
      log(haveSensor.toString());
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
}
