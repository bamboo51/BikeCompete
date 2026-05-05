import 'package:flutter/material.dart';

import 'navigation/main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2F6F3E);

    return MaterialApp(
      title: 'CyBon for Carbon Neutrality',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: primary,
              brightness: Brightness.light,
            ).copyWith(
              primary: primary,
              secondary: const Color(0xFF00897B),
              tertiary: const Color(0xFFF2A900),
              surface: const Color(0xFFFAFCF7),
              surfaceContainerLowest: Colors.white,
              surfaceContainer: const Color(0xFFF0F5EC),
              surfaceContainerHighest: const Color(0xFFE2ECDC),
            ),
        scaffoldBackgroundColor: const Color(0xFFFAFCF7),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAFCF7),
          foregroundColor: Color(0xFF16351E),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 68,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFD9EAD3),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w800
                  : FontWeight.w600,
            );
          }),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}
