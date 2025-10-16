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
  PrinterController printerController = Get.find<PrinterController>();
  late SharedPreferences pref;
  Uint8List? pngBytes;
  bool isInit = true;

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
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Printer')),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                spacing: 5,
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: printerController.getDevices,
                      child: Text(printerController.state.value.isLoading
                          ? "Scanning..."
                          : "Scan"),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: printerController.disconnect,
                      child: const Text("Disconnect"),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton(
                      onPressed: printerController.testPrint,
                      child: const Text("TestPrint"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(printerController.state.value.connectedMac!=null ? "Connected Device : ${printerController.state.value.connectedMac!.name}" : "" ),
              const SizedBox(height: 16),
              Expanded(
                child: printerController.state.value.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : printerController.state.value.devices.isEmpty
                        ? const Center(child: Text("No paired printers found"))
                        : ListView.builder(
                            itemCount:
                                printerController.state.value.devices.length,
                            itemBuilder: (context, i) {
                              BluetoothInfo d =
                                  printerController.state.value.devices[i];
                              final connected = d.macAdress ==
                                  printerController
                                      .state.value.connectedMac?.macAdress;
                              return Card(
                                child: ListTile(
                                  title: Text(d.name ?? "Unknown"),
                                  subtitle: Text(d.macAdress ?? ""),
                                  trailing: ElevatedButton(
                                    onPressed: () =>
                                        printerController.connect(d),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: connected
                                          ? Colors.green
                                          : Colors.blue,
                                    ),
                                    child: Text(
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      connected ? "Connected" : "Connect",
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
