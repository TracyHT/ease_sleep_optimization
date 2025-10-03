/**
 * Device Search Widget
 * 
 * This widget is based on the working BrainBit example and provides
 * proper device discovery functionality using the neurosdk2 Scanner.
 */

import 'package:flutter/material.dart';
import 'package:neurosdk2/neurosdk2.dart';
import '../models/brainbit_device.dart';
import '../widgets/device_card_widget.dart';

class DeviceSearch extends StatefulWidget {
  final Scanner scanner;
  final Function(FSensorInfo) deviceSelected;

  const DeviceSearch({
    super.key,
    required this.scanner,
    required this.deviceSelected,
  });

  @override
  State<DeviceSearch> createState() => _DeviceSearchState();
}

class _DeviceSearchState extends State<DeviceSearch> {
  List<FSensorInfo> _sensors = [];

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _startScanning() {
    // Periodically update the sensor list
    Future.delayed(const Duration(milliseconds: 500), _updateSensorList);
  }

  void _updateSensorList() async {
    if (!mounted) return;
    
    try {
      final sensors = await widget.scanner.getSensors();
      if (mounted) {
        setState(() {
          _sensors = sensors.whereType<FSensorInfo>().toList();
        });
      }
    } catch (e) {
      print('Error updating sensor list: $e');
    }

    // Continue updating every 500ms
    Future.delayed(const Duration(milliseconds: 500), _updateSensorList);
  }

  @override
  Widget build(BuildContext context) {
    if (_sensors.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching for BrainBit devices...'),
            SizedBox(height: 8),
            Text(
              'Make sure your BrainBit is ON and in pairing mode',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _sensors.length,
      itemBuilder: (context, index) {
        final sensor = _sensors[index];
        final device = BrainBitDevice.fromFSensorInfo(sensor);
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: DeviceCardWidget(
            device: device,
            isConnecting: false,
            onConnect: () => widget.deviceSelected(sensor),
            onDisconnect: () {},
          ),
        );
      },
    );
  }
}