import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

class DynamicChartData {
  final double windowLength;
  final List<FlSpot> _points = [];
  Timer? _timer;
  double _currentTime = 0;

  DynamicChartData(this.windowLength);

  List<FlSpot> get points => _points;

  void start() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _currentTime += 50;
      if (_currentTime > windowLength) {
        _currentTime = 0;
        _points.clear();
      }
    });
  }

  void add(List<double> values) {
    for (double value in values) {
      // Keep a rolling window of points
      if (_points.length > 200) { // Limit points for performance
        _points.removeAt(0);
        // Shift all points left
        for (int i = 0; i < _points.length; i++) {
          _points[i] = FlSpot(_points[i].x - 1, _points[i].y);
        }
        _currentTime = _points.isNotEmpty ? _points.last.x + 1 : 0;
      }
      _points.add(FlSpot(_currentTime, value));
      _currentTime += 1;
    }
  }

  void generateSimulatedData() {
    final random = Random();
    final baseFreq = 0.5 + random.nextDouble() * 2;
    final amplitude = 50 + random.nextDouble() * 100;
    final noise = (random.nextDouble() - 0.5) * 20;
    
    final value = amplitude * sin(baseFreq * _currentTime / 100) + noise;
    add([value]);
  }

  void dispose() {
    _timer?.cancel();
    _points.clear();
  }
}