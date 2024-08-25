import 'package:company_studio/auth/login_or_register.dart';
import 'package:company_studio/file_service.dart';
import 'package:company_studio/screens/home_screen.dart';
import 'package:company_studio/screens/materials.dart';
import 'package:company_studio/screens/orders_and_new_order.dart';
import 'package:company_studio/screens/splash_screen.dart';
import 'package:company_studio/screens/vehicles.dart';
import 'package:company_studio/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens/login_screen.dart';
import './screens/orders_screen.dart';
import './screens/profile_screen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  // Create an instance of the file service
  final fileService = FileService();

  // Restore orders file on app launch after an update
  await checkAndRestore(fileService);// Initialize Flutter Downloader
  runApp(
      ChangeNotifierProvider(
        create: (context)=> ThemeProvider(),
        child :  MyApp(),
      )
  );

}

Future<void> checkAndRestore(FileService fileService) async {
  // Compare stored app version with the current app version
  final prefs = await SharedPreferences.getInstance();
  final lastVersion = prefs.getString('app_version');
  final currentVersion = '1.1.0'; // Replace with your app's current version

  if (lastVersion != currentVersion) {
    // This is an update; restore the file
    await fileService.restoreOrdersFile();
    prefs.setString('app_version', currentVersion);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: Provider.of<ThemeProvider>(context).themeData,
      // home: const LoginOrRegister(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(onTap: (){}),
        '/home' : (context) => OrdersAndNewOrderScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/profile': (context) => ProfileScreen(),
        '/vehicle': (context) => VehicleScreen(),
        '/material' : (context) => const MaterialsScreen(),
      },
    );
  }
}


