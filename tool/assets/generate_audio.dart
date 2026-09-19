// Generates the original lightweight audio cues as 16-bit mono WAV files.
//
//   dart run tool/assets/generate_audio.dart
//
// Output: assets/audio/*.wav. Everything is synthesized (sine partials,
// filtered noise, envelopes), so nothing here is sampled or licensed.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const sampleRate = 22050;

typedef Synth = double Function(double t, double duration);

Uint8List wav(double seconds, Synth synth, {double gain = 0.8}) {
  final count = (seconds * sampleRate).round();
  final data = ByteData(44 + count * 2);
  void str(int o, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(o + i, s.codeUnitAt(i));
    }
  }

  str(0, 'RIFF');
  data.setUint32(4, 36 + count * 2, Endian.little);
  str(8, 'WAVE');
  str(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little); // PCM
  data.setUint16(22, 1, Endian.little); // mono
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  str(36, 'data');
  data.setUint32(40, count * 2, Endian.little);
  for (var i = 0; i < count; i++) {
    final t = i / sampleRate;
    final v = (synth(t, seconds) * gain).clamp(-1.0, 1.0);
    data.setInt16(44 + i * 2, (v * 32767).round(), Endian.little);
  }
  return data.buffer.asUint8List();
}

double env(double t, double d, {double attack = 0.005, double release = 0.08}) {
  if (t < attack) return t / attack;
  final tail = d - t;
  if (tail < release) return math.max(0, tail / release);
  return 1;
}

double tone(double t, double f) => math.sin(2 * math.pi * f * t);

/// A soft bell: fundamental plus quieter partials with exponential decay.
double bell(double t, double f, double decay) =>
    (tone(t, f) + 0.4 * tone(t, f * 2) + 0.15 * tone(t, f * 3)) *
    math.exp(-t * decay);

final _rng = math.Random(7);
double _brown = 0;
double brownNoise() {
  _brown = (_brown + (_rng.nextDouble() * 2 - 1) * 0.02).clamp(-1.0, 1.0);
  return _brown;
}

void main() {
  final out = Directory('assets/audio')..createSync(recursive: true);
  final clips = <String, Uint8List>{
    'ui_confirm': wav(0.12, (t, d) => bell(t, 880, 18) * env(t, d)),
    'discovery': wav(0.55, (t, d) {
      final f = t < 0.18 ? 659.0 : 988.0;
      return bell(t < 0.18 ? t : t - 0.18, f, 7) * env(t, d, release: 0.15);
    }),
    'rep_clean': wav(0.09, (t, d) => bell(t, 1320, 30) * env(t, d)),
    'rep_good': wav(0.09, (t, d) => bell(t, 990, 30) * env(t, d)),
    'rep_rough': wav(0.11, (t, d) => tone(t, 330) * 0.7 * env(t, d)),
    'rep_miss': wav(
      0.14,
      (t, d) => (tone(t, 160) + 0.5 * tone(t, 163)) * 0.6 * env(t, d),
    ),
    'water': wav(0.28, (t, d) {
      final f = 900 - 500 * (t / d);
      return tone(t, f) * env(t, d, release: 0.1) * 0.7;
    }),
    'recover': wav(0.6, (t, d) {
      return (tone(t, 330) + 0.5 * tone(t, 440) + 0.3 * tone(t, 550)) *
          0.4 *
          env(t, d, attack: 0.08, release: 0.3);
    }),
    'quest_complete': wav(0.9, (t, d) {
      const notes = [523.25, 659.25, 783.99];
      final idx = math.min(2, (t / 0.22).floor());
      final local = t - idx * 0.22;
      var v = bell(local, notes[idx], 5);
      if (t > 0.44) v += 0.5 * bell(t - 0.44, 1046.5, 3);
      return v * env(t, d, release: 0.25) * 0.8;
    }),
    'ambience': wav(4.0, (t, d) {
      // Low ventilation rumble with a faint 50 Hz hum; loops cleanly.
      final n = brownNoise() * 0.5;
      final hum = 0.05 * tone(t, 50) + 0.03 * tone(t, 100);
      final loopFade = math.min(1.0, math.min(t, d - t) / 0.2);
      return (n + hum) * 0.35 * loopFade;
    }, gain: 0.6),
  };
  for (final entry in clips.entries) {
    final file = File('${out.path}/${entry.key}.wav')
      ..writeAsBytesSync(entry.value);
    stdout.writeln(
      '${file.path}  ${(entry.value.length / 1024).toStringAsFixed(1)} KB',
    );
  }
}
