import 'package:flutter/material.dart';

import 'screens/history.dart';
import 'screens/home.dart';
import 'screens/settings.dart';
import 'widgets/common.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.load(); // restore saved language
  runApp(const VeracityApp());
}

class VeracityApp extends StatelessWidget {
  const VeracityApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return MaterialApp(
      title: 'Veracity',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: base.textTheme.apply(bodyColor: AppColors.text, displayColor: AppColors.text),
        snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
        dialogTheme: const DialogThemeData(
          titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text),
        ),
      ),
      home: const MainShell(),
    );
  }
}

/// Bottom tab bar: Home, History, Settings (matches the mockup).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  int _historyVisit = 0; // forces History to reload each time it is opened

  void _select(int i) => setState(() {
        if (i == 1) _historyVisit++;
        _tab = i;
      });

  @override
  Widget build(BuildContext context) {
    final Widget body = switch (_tab) {
      0 => HomeScreen(onOpenHistory: () => _select(1)),
      1 => HistoryScreen(key: ValueKey(_historyVisit)),
      _ => const SettingsScreen(),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: body,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: AppColors.blueBg,
            labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
                  fontSize: 15,
                  fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
                  color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.subtle,
                )),
            iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
                  size: 28,
                  color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.subtle,
                )),
          ),
          child: NavigationBar(
            height: 74,
            selectedIndex: _tab,
            onDestinationSelected: _select,
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.history_rounded), label: 'History'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}
