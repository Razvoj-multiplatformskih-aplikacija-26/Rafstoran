import 'package:flutter/material.dart';

void main() {
  runApp(const BackofficeApp());
}

class BackofficeApp extends StatelessWidget {
  const BackofficeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Rafstoran Backoffice',
      home: Scaffold(body: Center(child: Text('Rafstoran Backoffice'))),
    );
  }
}
