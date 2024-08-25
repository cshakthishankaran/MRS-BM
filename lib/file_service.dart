import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class FileService {
  Future<void> backupFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = await getTemporaryDirectory();  // Or another safe directory

      final vehiclesFile = File('${path.join(appDir.path, 'company_studio', 'lib', 'data', 'vehicles.json')}');
      final materialsFile = File('${path.join(appDir.path, 'company_studio', 'lib', 'data', 'materials.json')}');
      final ordersFile = File('${path.join(appDir.path, 'company_studio', 'lib', 'data', 'orders.json')}');


      final orderBackupFile = File('${path.join(backupDir.path, 'company_studio', 'lib', 'data', 'orders_backup.json')}');
      final vehiclesBackupFile = File('${path.join(backupDir.path, 'company_studio', 'lib', 'data', 'vehicles_backup.json')}');
      final materialsBackupFile = File('${path.join(backupDir.path, 'company_studio', 'lib', 'data', 'materials_backup.json')}');

      if (await ordersFile.exists() && await orderBackupFile.exists()) {
        await ordersFile.copy(orderBackupFile.path);
        print("Backup successful : Orders");
      } else {
        Directory(path.dirname(orderBackupFile.path)).create(recursive: true);
        await ordersFile.copy(orderBackupFile.path);
        print("No orders.json file to back up");
      }
      if (await vehiclesFile.exists() && await vehiclesBackupFile.exists()) {
        await vehiclesFile.copy(vehiclesBackupFile.path);
        print("Backup successful  :  Vehicles");
      } else {
        Directory(path.dirname(vehiclesBackupFile.path)).create(recursive: true);
        await vehiclesFile.copy(vehiclesBackupFile.path);
        print("No vehicles.json file to back up");
      }
      if (await materialsFile.exists() && await materialsBackupFile.exists()) {
        await materialsFile.copy(materialsBackupFile.path);
        print("Backup successful  :   Materials");
      } else {
        Directory(path.dirname(materialsBackupFile.path)).create(recursive: true);
        await materialsFile.copy(materialsBackupFile.path);
        print("No materials.json file to back up");
      }


    } catch (e) {
      print("Error during backup: $e");
    }
  }

  Future<void> restoreOrdersFile() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = await getTemporaryDirectory();  // Or another safe directory

      final vehiclesFile = File('${path.join(appDir.path, 'company_studio', 'lib', 'data', 'vehicles.json')}');
      final materialsFile = File('${path.join(appDir.path, 'company_studio', 'lib', 'data', 'materials.json')}');
      final ordersFile = File('${path.join(appDir.path, 'company_studio', 'lib', 'data', 'orders.json')}');

      final orderBackupFile = File('${path.join(backupDir.path, 'company_studio', 'lib', 'data', 'orders_backup.json')}');
      final vehiclesBackupFile = File('${path.join(backupDir.path, 'company_studio', 'lib', 'data', 'vehicles_backup.json')}');
      final materialsBackupFile = File('${path.join(backupDir.path, 'company_studio', 'lib', 'data', 'materials_backup.json')}');

      if (await orderBackupFile.exists()) {
        await orderBackupFile.copy(ordersFile.path);
        print("Restore successful");
      } else {
        print("No backup found to restore");
      }
      if (await vehiclesBackupFile.exists()) {
        await vehiclesBackupFile.copy(vehiclesFile.path);
        print("Restore successful");
      } else {
        print("No backup found to restore");
      }
      if (await materialsBackupFile.exists()) {
        await materialsBackupFile.copy(materialsFile.path);
        print("Restore successful");
      } else {
        print("No backup found to restore");
      }
    } catch (e) {
      print("Error during restore: $e");
    }
  }

  Future<void> uploadFile() async {
    // Pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);

      // DigiBoxx API URL
      final String url = 'https://api.digiboxx.com/upload';

      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add file to request
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Set headers (you might need to authenticate and get an auth token)
      request.headers.addAll({
        'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
        'Content-Type': 'multipart/form-data',
      });

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        print('File uploaded successfully');
      } else {
        print('File upload failed');
      }
    } else {
      // User canceled the picker
    }
  }
}
