import 'package:flutter_platform_integration/home_page/home_vu.dart';
import '../shared_pref/shared_pref.dart';
import 'package:flutter/material.dart';

import 'prac/prac_vu.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPref.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHI Servers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF41A3FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        primaryColor: const Color(0xFF41A3FF),
        scaffoldBackgroundColor: const Color(0xFF2B313D),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: HomeVU(),
      // home: PracVU(),
    );
  }
}

//scaffoldBackgroundColor: const Color(0xFF2B313D),
//seedColor: const Color(0xFF41A3FF),


