import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_page.dart';

void main() {
  runApp(const PopDailyAsiaApp());
}

class PopDailyAsiaApp extends StatelessWidget {
  const PopDailyAsiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PopDaily Asia',

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7656D6),
          primary: const Color(0xFF7656D6),
        ),

        textTheme: GoogleFonts.poppinsTextTheme(),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF17182F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      home: const LoginPage(),
    );
  }
}