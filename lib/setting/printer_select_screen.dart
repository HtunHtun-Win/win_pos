import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_pos/setting/controller/printer_controller.dart';

class PrinterSelectScreen extends StatefulWidget {
  const PrinterSelectScreen({super.key});

  @override
  State<PrinterSelectScreen> createState() => _PrinterSelectScreenState();
}

class _PrinterSelectScreenState extends State<PrinterSelectScreen> {
  final PrinterController printerController = Get.find<PrinterController>();
  late SharedPreferences pref;
  Uint8List? pngBytes;

  @override
  void initState() {
    super.initState();
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    pref = await SharedPreferences.getInstance();
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    printerController.getDevices();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Printer'),
      ),
      body: Obx(
        () {
          final state = printerController.state.value;
          final connected = state.connectedMac;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: state.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.search),
                        label: Text(state.isLoading ? 'Scanning...' : 'Scan'),
                        onPressed: state.isLoading ? null : printerController.getDevices,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.wifi_off),
                        label: const Text('Disconnect'),
                        onPressed: printerController.disconnect,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.error,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Test Print'),
                    onPressed: printerController.testPrint,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (connected != null)
                  Row(
                    children: [
                      const Icon(Icons.bluetooth_connected, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Connected to ${connected.name}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                if (connected == null)
                  Text(
                    'No printer connected',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                const SizedBox(height: 18),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.devices.isEmpty
                          ? Center(
                              child: Text(
                                'No paired printers found',
                                style: theme.textTheme.bodyLarge,
                              ),
                            )
                          : ListView.builder(
                              itemCount: state.devices.length,
                              itemBuilder: (context, index) {
                                final BluetoothInfo device = state.devices[index];
                                final isConnected = device.macAdress == connected?.macAdress;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                    leading: Icon(Icons.bluetooth, color: theme.colorScheme.primary),
                                    title: Text(device.name ?? 'Unknown printer'),
                                    subtitle: Text(device.macAdress ?? ''),
                                    trailing: ElevatedButton(
                                      onPressed: () => printerController.connect(device),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isConnected ? Colors.green : theme.colorScheme.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                      child: Text(isConnected ? 'Connected' : 'Connect'),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
