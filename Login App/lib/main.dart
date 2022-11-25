import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/screens/homepage.dart';
import 'package:flutter_app/screens/loginpage.dart';
import 'package:flutter_app/screens/signuppage.dart';
import 'package:flutter_app/screens/splshscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'splashscreen',
      routes: {
        '/': (context) => const LoginPage(),
        'homepage': (context) => const HomePage(),
        'splashscreen': (context) => const SplashScreen(),
        'signuppage': (context) => const Signup(),
      },
    ),
  );
}
