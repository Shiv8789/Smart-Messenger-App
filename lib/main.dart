import 'package:flutter/material.dart';
import './screens/authenticate.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:google_fonts/google_fonts.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Messenger Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Authenticate(),
    );
  }
}
