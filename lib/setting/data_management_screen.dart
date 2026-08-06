import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:win_pos/user/screens/login_screen.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _dataTile(
              context,
              icon: Icons.backup,
              title: 'Data Backup',
              subtitle: 'Save a copy of your current database.',
              color: theme.colorScheme.primary,
              onTap: () async {
                await exportDatabase();
              },
            ),
            _dataTile(
              context,
              icon: Icons.restore,
              title: 'Data Restore',
              subtitle: 'Load a previously saved backup file.',
              color: theme.colorScheme.secondary,
              onTap: () async {
                await importDatabase();
              },
            ),
            _dataTile(
              context,
              icon: Icons.delete_forever,
              title: 'Delete Everything',
              subtitle: 'Reset the app to its initial state.',
              color: theme.colorScheme.error,
              onTap: () async {
                await Get.dialog(AlertDialog(
                  title: const Text('Format Everything'),
                  content: const Text('Backup data before format.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Get.back();
                        await format();
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getPermission() async {
    if (!Platform.isAndroid) return;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt <= 32) {
      // ✅ Android 12 and below
      var state = await Permission.storage.status;
      if (state != PermissionStatus.granted) {
        await Permission.storage.request();
      }
    } else {
      // ✅ Android 13–15: new storage model
      var managePermission = await Permission.manageExternalStorage.status;
      if (!managePermission.isGranted) {
        await Permission.manageExternalStorage.request();
      }

      // Also request read access for media files if needed
      await Permission.photos.request();
      await Permission.videos.request();
      await Permission.audio.request();
    }
  }

  Future<String> getPath() async {
    var filePath = '';
    var date = DateTime.now();
    final fileName =
        "LightPOS_${date.day}_${date.month}_${date.year}_(${date.hour}h-${date.minute}min).zip";
    if (Platform.isAndroid) {
      await _getPermission();
      final directory = Directory('/storage/emulated/0/Download');
      filePath = "${directory.path}/$fileName";
    } else if (Platform.isLinux) {
      final dir = await getApplicationDocumentsDirectory();
      filePath = '${dir.path}/$fileName';
    } else if (Platform.isWindows) {
      final dir = await getApplicationDocumentsDirectory();
      filePath = '${dir.path}/$fileName';
    }
    return filePath;
  }

  Future<void> exportDatabase() async {
    try {
      // Get the path to the current database
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String dbPath = join(documentsDirectory.path, "winpos.db");

      // Get the external storage directory path for Android
      String externalPath = await getPath();

      // Copy the database to the backup location
      await File(dbPath).copy(externalPath);
      Get.dialog(AlertDialog(
        title: const Text("Success"),
        content: const Text("Backup file was saved in download folder."),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("OK"))
        ],
      ));
    } catch (e) {
      // print(e.toString());
      Get.snackbar("Error", "$e");
    }
  }

  Future<void> importDatabase() async {
    String DB_NAME = "winpos.db";
    if (await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted) {
      // Open the file picker to select a file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        // Get the path of the selected file
        String pickedFilePath = result.files.single.path!;
        File pickedFile = File(pickedFilePath);

        // Define the destination path for the database
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
        String dbPath = join(documentsDirectory.path, DB_NAME);

        try {
          // Copy the picked file to the database path
          await pickedFile.copy(dbPath);
          Get.dialog(AlertDialog(
            title: const Text("Success"),
            content: const Text("Data restored successfully."),
            actions: [
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("OK"))
            ],
          ));
          Get.off(const LoginScreen());
        } catch (e) {
          Get.dialog(AlertDialog(
            title: const Text("Error"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("OK"))
            ],
          ));
        }
      } else {
        Get.dialog(AlertDialog(
          title: const Text("Error"),
          content: const Text("No file selected or file path is null."),
          actions: [
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text("OK"))
          ],
        ));
      }
    } else {
      Get.dialog(AlertDialog(
        title: const Text("Error"),
        content: const Text("Storage permission denied."),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("OK"))
        ],
      ));
    }
  }

  Future<void> format() async {
    String DB_NAME = "winpos.db";
    // Get the application documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    try {
      ByteData data = await rootBundle.load(join('assets/db', DB_NAME));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
      Get.dialog(AlertDialog(
        title: const Text("Success"),
        content: const Text("Operation Success!"),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("OK"))
        ],
      ));
      Get.off(const LoginScreen());
    } catch (e) {
      Get.dialog(AlertDialog(
        title: const Text("Error"),
        content: Text(e.toString()),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("OK"))
        ],
      ));
    }
  }

  Widget _dataTile(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: color.withValues(alpha: 0.14),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: onTap,
      ),
    );
  }
}
