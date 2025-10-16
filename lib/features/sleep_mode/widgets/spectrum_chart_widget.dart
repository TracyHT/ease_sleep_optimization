import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:neurosdk2/neurosdk2.dart';
import 'package:spectrum_lib/spectrum_lib.dart';

class ChannelSpectrum {
  final deltaPoints = <FlSpot>[];
  final thetaPoints = <FlSpot>[];
  final alphaPoints = <FlSpot>[];
  final betaPoints = <FlSpot>[];
  final gammaPoints = <FlSpot>[];
}

class SpectrumChart extends StatefulWidget {
  final BrainBit sensor;
  const SpectrumChart({super.key, required this.sensor});

  @override
  State<SpectrumChart> createState() => _SpectrumChartState();
}

class _SpectrumChartState extends State<SpectrumChart> {
  static const int sampleRate = 250;
  final Map<String, ChannelSpectrum> _channels = {
    "O1": ChannelSpectrum(),
    "O2": ChannelSpectrum(),
    "T3": ChannelSpectrum(),
    "T4": ChannelSpectrum(),
  };

  late final SpectrumLib _libO1, _libO2, _libT3, _libT4;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _libO1 = _createLib();
    _libO2 = _createLib();
    _libT3 = _createLib();
    _libT4 = _createLib();
    _sub = widget.sensor.signalDataStream.listen(_processEEG);
  }

  SpectrumLib _createLib() {
    final lib = SpectrumLib(sampleRate, sampleRate * 4, 10);
    lib.initParams(125, false);
    lib.setWavesCoeffs(1, 1, 1, 1, 1);
    return lib;
  }

  void _processEEG(List<BrainBitSignalData> data) {
    if (data.isEmpty) return;
    _updateSpectrum(_libO1, data.map((e) => e.o1).toList(), _channels["O1"]!);
    _updateSpectrum(_libO2, data.map((e) => e.o2).toList(), _channels["O2"]!);
    _updateSpectrum(_libT3, data.map((e) => e.t3).toList(), _channels["T3"]!);
    _updateSpectrum(_libT4, data.map((e) => e.t4).toList(), _channels["T4"]!);
    setState(() {});
  }

  void _updateSpectrum(
    SpectrumLib lib,
    List<double> samples,
    ChannelSpectrum c,
  ) {
    lib.pushAndProcessData(samples);
    final waves = lib.readWavesSpectrumInfoArr();
    if (waves.isEmpty) return;

    final last = waves.last;
    c.deltaPoints.add(FlSpot(0, last.deltaRel));
    c.thetaPoints.add(FlSpot(1, last.thetaRel));
    c.alphaPoints.add(FlSpot(2, last.alphaRel));
    c.betaPoints.add(FlSpot(3, last.betaRel));
    c.gammaPoints.add(FlSpot(4, last.gammaRel));
  }

  @override
  void dispose() {
    _sub?.cancel();
    widget.sensor.execute(FSensorCommand.stopSignal);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          _channels.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 5,
                      minY: 0,
                      maxY: 1,
                      titlesData: const FlTitlesData(show: false),
                      gridData: const FlGridData(show: false),
                      lineBarsData: [
                        _makeLine(entry.value.deltaPoints, Colors.red),
                        _makeLine(entry.value.thetaPoints, Colors.orange),
                        _makeLine(entry.value.alphaPoints, Colors.yellow),
                        _makeLine(entry.value.betaPoints, Colors.green),
                        _makeLine(entry.value.gammaPoints, Colors.blue),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  LineChartBarData _makeLine(List<FlSpot> points, Color color) {
    return LineChartBarData(
      spots: points,
      color: color,
      isCurved: true,
      barWidth: 1.5,
      dotData: const FlDotData(show: false),
    );
  }
}
