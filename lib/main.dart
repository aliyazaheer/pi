import 'package:flutter_platform_integration/home_page/home_vu.dart';
import '../shared_pref/shared_pref.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPref.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    SharedPref.getTheme().then((theme) {
      themeModeNotifier.value = theme;
    });
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeModeNotifier,
        builder: (context, themeMode, child) {
          return MaterialApp(
            title: 'CHI Servers',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF41A3FF),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              primaryColor: const Color(0xFF41A3FF),
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Color(0xFF2B313D)),
              ),
            ),
            darkTheme: ThemeData(
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
            themeMode: themeMode,
            home: HomeVU(
              onThemeToggle: () async {
                final newThemeMode = themeModeNotifier.value == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
                themeModeNotifier.value = newThemeMode;
                await SharedPref.saveTheme(newThemeMode);
                // themeModeNotifier.value =
                //     themeModeNotifier.value == ThemeMode.dark
                //         ? ThemeMode.light
                //         : ThemeMode.dark;
              },
            ),
            // home: PracVU(),
          );
        });
  }
}
