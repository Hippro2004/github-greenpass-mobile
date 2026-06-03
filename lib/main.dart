import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greenpass/features/auth/views/login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenPass Platfrom',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.promptTextTheme(),
      ),
      home: const LoginView(),
    );
  }
}
