import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
}
