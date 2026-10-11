import 'dart:math';

const double _kaabaLat = 21.4225;
const double _kaabaLng = 39.8262;

double calculateQiblaBearing(double userLat, double userLng) {
  final double lat1 = userLat * (pi / 180);
  const double lat2 = _kaabaLat * (pi / 180);
  final double dLng = (_kaabaLng - userLng) * (pi / 180);

  final double x = sin(dLng) * cos(lat2);
  final double y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);

  final double bearing = atan2(x, y) * (180 / pi);
  return (bearing + 360) % 360;
}

double normalizeArrowRotation(double qiblaBearing, double compassHeading) {
  return (qiblaBearing - compassHeading + 360) % 360;
}

bool isAlignedWithQibla(double arrowRotation) {
  final double normalized = arrowRotation % 360;
  return normalized < 5.0 || normalized > 355.0;
}
