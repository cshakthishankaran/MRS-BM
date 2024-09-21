import "dart:io";

import "package:archive/archive.dart";
import "package:company_studio/components/my_button.dart";
import "package:company_studio/components/my_drawer.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import 'package:path/path.dart' as path;
import "package:path_provider/path_provider.dart";
import "package:shared_preferences/shared_preferences.dart";


class BackupRestoreScreen extends StatefulWidget {
  @override
  _BackupRestoreScreenState createState() => _BackupRestoreScreenState();
}


class _BackupRestoreScreenState extends State<BackupRestoreScreen>  {
  String? lastBackupTime;

  @override
  void initState() {
    super.initState();
    _getLastBackupTime();
  }

  Future<void> _getLastBackupTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lastBackupTime = prefs.getString('lastBackupTime');
    });
  }

  Future<String> _getFilePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final fullPath = path.join(directory.path, 'company_studio', 'lib', 'data', filename);
    print(fullPath);
    return fullPath;
  }

  Future<void> compressFilesToBak(List<String> files, String outputFileName) async {
    // Create an archive object
    final archive = Archive();

    // Add each file to the archive
    for (String fileObj in files) {

      final file = File(await _getFilePath(fileObj));
      final fileName = file.uri.pathSegments.last;
      final fileBytes = await file.readAsBytes();
      archive.addFile(ArchiveFile(fileName, fileBytes.length, fileBytes));
    }

    // Convert the archive to a Zip file
    final zipEncoder = ZipEncoder();
    final encodedData = zipEncoder.encode(archive);

    // Get the app's documents directory
    final directory = await getApplicationDocumentsDirectory();

    // Create a .bak file
    final bakFile = File('${directory.path}/$outputFileName.bak');
    await bakFile.writeAsBytes(encodedData!);
  }
  Future<void> backupFiles(BuildContext context) async {
    // Example list of file paths to back up
    List<String> filesToBackup = [
      'orders.json',
      'materials.json',
      'vehicles.json'
      // Add more file paths as needed
    ];

    // Compress files to a .bak file
    await compressFilesToBak(filesToBackup, 'backup_file');

    // Show the file picker to choose where to save the .bak file
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final directory = await getApplicationDocumentsDirectory();
      final bakFile = File('${directory.path}/backup_file.bak');
      final destination = File('$selectedDirectory/backup_file.bak');
      await bakFile.copy(destination.path);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String currentTime = DateFormat('hh:mm a dd MMM yyyy').format(DateTime.now());
      await prefs.setString('lastBackupTime', currentTime);
      await _getLastBackupTime();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup successful!')));
    }
  }
    Future<void> restoreFiles(BuildContext context) async {
      try {
        // Open file picker to select the .bak file
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['bak'],

        );

        if (result != null && result.files.single.path != null) {
          String bakFilePath = result.files.single.path!;

          // Call the restore function with the selected .bak file path
          await restoreFilesFromBak(bakFilePath);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore successful!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No file selected')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to restore: $e')));
      }
    }

    Future<void> restoreFilesFromBak(String bakFilePath) async {
      // Read the .bak file
      final bakFile = File(bakFilePath);
      final bytes = await bakFile.readAsBytes();

      // Decode the archive
      final archive = ZipDecoder().decodeBytes(bytes);

      // Restore each file in the archive
      for (final file in archive) {
        final fileName = file.name;
        final fileData = file.content as List<int>;

        // Define the output path where the files should be restored
        final outputDirectory = await _getFilePath("");
        final outputFile = File('$outputDirectory/$fileName');

        // Create the file and write the data
        await outputFile.create(recursive: true);
        await outputFile.writeAsBytes(fileData);
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Backup & Restore',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(child: ListView(
          children: [
            Padding(
                padding: const EdgeInsets.all(25.0),
            child: Text(
                lastBackupTime != null
                    ? "Last backup was at $lastBackupTime"
                    : "No backups have been made yet.",
              style: TextStyle(
                  fontSize: 15,
                  // color: Colors.black,
                  fontWeight: FontWeight.bold
              ),),),

            const SizedBox(height: 25.0),
            ElevatedButton(
              onPressed: () => backupFiles(context),
              child: Text('Backup'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                  foregroundColor: Colors.black
              ),
            ),
            const SizedBox(height: 25.0),
            ElevatedButton(
              onPressed: () => restoreFiles(context),
              child: Text('Restore'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow,
                foregroundColor: Colors.black

              ),
            ),

          ],)





        ),
      ),
    drawer: MyDrawer(),
    );
  }



  }

