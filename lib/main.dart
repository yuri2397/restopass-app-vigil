import 'package:flutter/material.dart';
import 'package:vigil/views/Login.dart';
import 'package:vigil/views/Scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {'/': (context) => Login(), '/scanner': (context) => Scanner()},
      debugShowCheckedModeBanner: false,
      title: 'RestoVigil',
    );
  }
}
