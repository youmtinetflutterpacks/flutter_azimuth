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

  final files = dir.listSync(recursive: true).whereType<File>().toList();

  if (files.isEmpty) {
    print('⚠️ No audio files found.');
    return;
  }

  final buffer = StringBuffer();

  buffer.writeln('// GENERATED CODE - DO NOT MODIFY');
  buffer.writeln("import 'dart:typed_data';");
  buffer.writeln("import 'dart:convert';");
  buffer.writeln('');

  // ===== ENUM =====

  buffer.writeln('enum AudioAsset {');

  for (final file in files) {
    buffer.writeln('  ${_enumName(file.path)},');
  }

  buffer.writeln('}');
  buffer.writeln('');

  // ===== EXTENSION =====

  buffer.writeln('extension AudioAssetData on AudioAsset {');

  // bytes getter
  buffer.writeln('  Uint8List get bytes {');
  buffer.writeln('    switch (this) {');

  for (final file in files) {
    final bytes = await file.readAsBytes();
    final base64Data = base64Encode(bytes);

    buffer.writeln('      case AudioAsset.${_enumName(file.path)}:');
    buffer.writeln(
      "        return Uint8List.fromList(base64Decode('''$base64Data'''));",
    );
  }

  buffer.writeln('    }');
  buffer.writeln('  }');
  buffer.writeln('');

  // mime getter
  buffer.writeln('  String? get mimeType {');
  buffer.writeln('    switch (this) {');

  for (final file in files) {
    final mime = _guessMime(file.path);

    buffer.writeln('      case AudioAsset.${_enumName(file.path)}:');
    buffer.writeln("        return ${mime == null ? 'null' : "'$mime'"};");
  }

  buffer.writeln('    }');
  buffer.writeln('  }');

  buffer.writeln('}');

  final out = File(outputFile);
  await out.create(recursive: true);
  await out.writeAsString(buffer.toString());

  print('✅ Generated: $outputFile');
}

String _enumName(String path) {
  final relative = path.replaceFirst(
    '$inputFolder${Platform.pathSeparator}',
    '',
  );
  final withoutExt = p.withoutExtension(relative);
  return withoutExt.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
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
