import 'package:flutter/material.dart';
import 'package:weekly_boss/screens/home_screen.dart';
import 'package:weekly_boss/screens/register_screen.dart';
import 'package:weekly_boss/services/auth_service.dart';
import 'package:weekly_boss/services/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService().initialize();

  final isRegistered = await AuthService().isUserRegistered();
  final initialRoute = isRegistered ? '/' : 'register';
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weekly boss',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const HomeScreen(),
        'register': (context) => const RegisterScreen(),
      },
    );
  }
}
