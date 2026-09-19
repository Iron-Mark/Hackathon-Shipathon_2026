// Generates the app icon set (favicon.png, favicon.ico, PWA icons) as an
// original geometric mark: a dumbbell on the game's charcoal with the rust
// accent bar. Pure Dart PNG/ICO writers, no image dependencies.
//
//   dart run tool/assets/generate_icons.dart
import 'dart:io';
import 'dart:typed_data';

const bg = 0xFF14161A;
const surface = 0xFF272B31;
const rust = 0xFFC8641F;
const rustBright = 0xFFF2A35A;
const steel = 0xFFE8E4DA;

/// Paints the mark into an RGBA buffer of [size] x [size].
Uint8List paintIcon(int size, {bool maskable = false}) {
  final px = Uint8List(size * size * 4);
  void set(int x, int y, int argb) {
    if (x < 0 || y < 0 || x >= size || y >= size) return;
    final i = (y * size + x) * 4;
    px[i] = (argb >> 16) & 255;
    px[i + 1] = (argb >> 8) & 255;
    px[i + 2] = argb & 255;
    px[i + 3] = (argb >> 24) & 255;
  }

  void rect(double x0, double y0, double x1, double y1, int argb) {
    for (var y = (y0 * size).round(); y < (y1 * size).round(); y++) {
      for (var x = (x0 * size).round(); x < (x1 * size).round(); x++) {
        set(x, y, argb);
      }
    }
  }

  // Background: rounded square (full bleed when maskable).
  final r = maskable ? 0.0 : 0.18;
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final fx = (x + 0.5) / size, fy = (y + 0.5) / size;
      final cx = fx < r ? r : (fx > 1 - r ? 1 - r : fx);
      final cy = fy < r ? r : (fy > 1 - r ? 1 - r : fy);
      final dx = fx - cx, dy = fy - cy;
      if (dx * dx + dy * dy <= r * r) set(x, y, bg);
    }
  }
  final inset = maskable ? 0.12 : 0.0;
  double s(double v) => inset + v * (1 - 2 * inset);
  // Rust accent bar (the title rule).
  rect(s(0.18), s(0.20), s(0.62), s(0.27), rust);
  // Dumbbell: bar, inner plates, outer plates.
  rect(s(0.14), s(0.55), s(0.86), s(0.63), steel);
  rect(s(0.20), s(0.42), s(0.31), s(0.76), surface);
  rect(s(0.69), s(0.42), s(0.80), s(0.76), surface);
  rect(s(0.31), s(0.47), s(0.38), s(0.71), rustBright);
  rect(s(0.62), s(0.47), s(0.69), s(0.71), rustBright);
  return px;
}

Uint8List png(int size, Uint8List rgba) {
  final raw = BytesBuilder();
  for (var y = 0; y < size; y++) {
    raw.addByte(0);
    raw.add(rgba.sublist(y * size * 4, (y + 1) * size * 4));
  }
  final idat = ZLibEncoder(level: 9).convert(raw.toBytes());
  final out = BytesBuilder()
    ..add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  void chunk(String type, List<int> data) {
    final len = ByteData(4)..setUint32(0, data.length);
    out.add(len.buffer.asUint8List());
    final body = [...type.codeUnits, ...data];
    out.add(body);
    final crc = ByteData(4)..setUint32(0, _crc32(body));
    out.add(crc.buffer.asUint8List());
  }

  final ihdr = ByteData(13)
    ..setUint32(0, size)
    ..setUint32(4, size)
    ..setUint8(8, 8)
    ..setUint8(9, 6);
  chunk('IHDR', ihdr.buffer.asUint8List());
  chunk('IDAT', idat);
  chunk('IEND', const []);
  return out.toBytes();
}

/// ICO container holding PNG-encoded images (supported by all modern browsers).
Uint8List ico(Map<int, Uint8List> pngs) {
  final sizes = pngs.keys.toList()..sort();
  final header = ByteData(6 + 16 * sizes.length);
  header.setUint16(0, 0, Endian.little);
  header.setUint16(2, 1, Endian.little);
  header.setUint16(4, sizes.length, Endian.little);
  var offset = header.lengthInBytes;
  for (var i = 0; i < sizes.length; i++) {
    final size = sizes[i], data = pngs[size]!;
    final o = 6 + 16 * i;
    header.setUint8(o, size == 256 ? 0 : size);
    header.setUint8(o + 1, size == 256 ? 0 : size);
    header.setUint8(o + 2, 0);
    header.setUint8(o + 3, 0);
    header.setUint16(o + 4, 1, Endian.little);
    header.setUint16(o + 6, 32, Endian.little);
    header.setUint32(o + 8, data.length, Endian.little);
    header.setUint32(o + 12, offset, Endian.little);
    offset += data.length;
  }
  final out = BytesBuilder()..add(header.buffer.asUint8List());
  for (final size in sizes) {
    out.add(pngs[size]!);
  }
  return out.toBytes();
}

late final List<int> _crcTable = List.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> bytes) {
  var c = 0xFFFFFFFF;
  for (final b in bytes) {
    c = _crcTable[(c ^ b) & 0xFF] ^ (c >> 8);
  }
  return (c ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}

void write(String path, Uint8List bytes) {
  File(path)
    ..parent.createSync(recursive: true)
    ..writeAsBytesSync(bytes);
  stdout.writeln('$path  ${(bytes.length / 1024).toStringAsFixed(1)} KB');
}

void main() {
  Uint8List icon(int size, {bool maskable = false}) =>
      png(size, paintIcon(size, maskable: maskable));
  write('web/favicon.png', icon(64));
  write('web/favicon.ico', ico({16: icon(16), 32: icon(32), 48: icon(48)}));
  write('web/icons/Icon-192.png', icon(192));
  write('web/icons/Icon-512.png', icon(512));
  write('web/icons/Icon-maskable-192.png', icon(192, maskable: true));
  write('web/icons/Icon-maskable-512.png', icon(512, maskable: true));
  write('docs/demo/favicon.png', icon(64));
}
