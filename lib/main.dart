import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:guideart/button.dart';
import 'package:guideart/register.dart';

import 'profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'log in',
      routes: {
        'login': (context) => login(),
        'register': (context) => Myregister(),
      },
      title: 'Flutter Demo',
      themeMode: ThemeMode.system,
      home: Button(),
    );
  }
}
