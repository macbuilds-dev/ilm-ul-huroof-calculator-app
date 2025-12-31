import 'package:flutter/material.dart';
import 'package:ilm_ul_huroof_calculator/view/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'علمُ الحروف',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Noto Nastaliq Urdu',
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00695C),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );

  }
}