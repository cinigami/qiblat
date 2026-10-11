import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'qibla_calculator.dart';
import 'location_service.dart';
import 'compass_widget.dart';
import 'calibration_sheet.dart';

enum _LocationState { loading, acquired, denied, timeout }

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _compassHeading = 0.0;
  double _qiblaBearing = 292.0; // Malaysia fallback
  _LocationState _locationState = _LocationState.loading;
  String _locationLabel = '';
  bool _hasCompass = true;
  StreamSubscription<CompassEvent>? _compassSubscription;
  bool _wasAligned = false;

  @override
  void initState() {
    super.initState();
    _startCompass();
    _initLocation();
  }

  void _startCompass() {
    if (FlutterCompass.events == null) {
      setState(() => _hasCompass = false);
      return;
    }
    _compassSubscription = FlutterCompass.events!.listen((event) {
      if (event.heading == null) return;
      final arrowRot = normalizeArrowRotation(_qiblaBearing, event.heading!);
      final aligned = isAlignedWithQibla(arrowRot);
      if (aligned && !_wasAligned) {
        HapticFeedback.vibrate();
      }
      setState(() {
        _compassHeading = event.heading!;
        _wasAligned = aligned;
      });
    });
  }

  Future<void> _initLocation() async {
    final status = await Permission.location.request();
    if (!mounted) return;
    if (!status.isGranted) {
      setState(() => _locationState = _LocationState.denied);
      return;
    }
    await _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    if (mounted) setState(() => _locationState = _LocationState.loading);
    final position = await LocationService.getCurrentPosition();
    if (!mounted) return;
    if (position == null) {
      setState(() => _locationState = _LocationState.timeout);
      return;
    }
    setState(() {
      _qiblaBearing = calculateQiblaBearing(position.latitude, position.longitude);
      _locationLabel = LocationService.formatCoordinates(position.latitude, position.longitude);
      _locationState = _LocationState.acquired;
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCompass) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Compass not supported on this device',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final arrowRotation = normalizeArrowRotation(_qiblaBearing, _compassHeading);
    final aligned = isAlignedWithQibla(arrowRotation);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: CompassWidget(
                  compassHeading: _compassHeading,
                  arrowRotation: arrowRotation,
                  isAligned: aligned,
                  size: 280,
                ),
              ),
            ),
            _buildDegreeReadout(aligned),
            _buildStatusBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Column(
        children: [
          const Text(
            'Qiblat',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          _buildLocationChip(),
        ],
      ),
    );
  }

  Widget _buildLocationChip() {
    switch (_locationState) {
      case _LocationState.loading:
        return const Chip(
          backgroundColor: Colors.white12,
          label: Text('⏳ Getting location...', style: TextStyle(color: Colors.white70)),
        );
      case _LocationState.acquired:
        return Chip(
          backgroundColor: const Color.fromARGB(40, 76, 175, 80),
          label: Text('📍 $_locationLabel', style: const TextStyle(color: Colors.white)),
        );
      case _LocationState.denied:
        return const Chip(
          backgroundColor: Color.fromARGB(50, 255, 152, 0),
          label: Text(
            'Location unavailable — showing est. 292° for Malaysia',
            style: TextStyle(color: Colors.orange, fontSize: 11),
          ),
        );
      case _LocationState.timeout:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Chip(
              backgroundColor: Colors.red,
              label: Text('⚠️ Location timeout', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: _fetchLocation, child: const Text('Retry')),
          ],
        );
    }
  }

  Widget _buildDegreeReadout(bool aligned) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            '${_qiblaBearing.toStringAsFixed(1)}°',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: aligned ? const Color(0xFFFFD700) : Colors.white,
            ),
          ),
          Text(
            'You are facing: ${_compassHeading.toStringAsFixed(0)}°',
            style: const TextStyle(fontSize: 15, color: Colors.white54),
          ),
          if (aligned)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                '✅ Facing Qiblat',
                style: TextStyle(fontSize: 14, color: Color(0xFFFFD700), fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: () => showCalibrationSheet(context),
            icon: const Icon(Icons.tune, size: 16, color: Colors.white54),
            label: const Text('Calibrate', style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
}
