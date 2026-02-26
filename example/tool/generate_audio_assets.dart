// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;

const inputFolder = 'assets/ticks';
const outputFile = 'lib/audio_bytes.dart';
const className = 'EmbeddedAudios';

void main() async {
  final dir = Directory(inputFolder);

  if (!dir.existsSync()) {
    print('❌ Folder "$inputFolder" not found');
    return;
  }

  final buffer = StringBuffer();

  buffer.writeln('// GENERATED CODE - DO NOT MODIFY');
  buffer.writeln("import 'dart:typed_data';");
  buffer.writeln("import 'dart:convert';");
  buffer.writeln('');
  buffer.writeln('abstract class $className {');

  final files = dir.listSync(recursive: true).whereType<File>();

  for (final file in files) {
    final bytes = await file.readAsBytes();
    final base64Data = base64Encode(bytes);

    final fieldName = _fieldName(file.path);
    final mime = _guessMime(file.path);

    buffer.writeln('  /// ${file.path}');
    buffer.writeln(
      "  static Uint8List get $fieldName => Uint8List.fromList(base64Decode('''$base64Data'''));",
    );
    buffer.writeln(
      "  static const String? ${fieldName}MimeType = ${mime == null ? 'null' : "'$mime'"};",
    );
    buffer.writeln('');
  }

  buffer.writeln('}');

  final out = File(outputFile);
  await out.create(recursive: true);
  await out.writeAsString(buffer.toString());

  print('✅ Generated: $outputFile');
}

String _fieldName(String path) {
  final name = p.basenameWithoutExtension(path);
  return name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
}

String? _guessMime(String path) {
  switch (p.extension(path).toLowerCase()) {
    case '.mp3':
      return 'audio/mpeg';
    case '.wav':
      return 'audio/wav';
    case '.ogg':
      return 'audio/ogg';
    case '.aac':
      return 'audio/aac';
    case '.m4a':
      return 'audio/mp4';
    case '.flac':
      return 'audio/flac';
    default:
      return null;
  }
}
