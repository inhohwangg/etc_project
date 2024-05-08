import 'dart:typed_data';

class SensorData {
  final double temperature;
  final int light;
  final int moisture;
  final int conductivity;

  SensorData({
    required this.temperature,
    required this.light,
    required this.moisture,
    required this.conductivity,
  });

  factory SensorData.fromByteArray(Uint8List data) {
    final ByteData byteData = ByteData.sublistView(data);

    return SensorData(
      temperature: byteData.getInt16(0, Endian.little) / 10.0,
      light: byteData.getUint32(3, Endian.little),
      moisture: byteData.getUint8(7),
      conductivity: byteData.getUint16(8, Endian.little),
    );
  }
}
