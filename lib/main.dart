import 'package:flutter/material.dart';
import 'main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Stok',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1565C0), // Warna biru utama aplikasi
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const MainNavigation(),
    );
  }
}