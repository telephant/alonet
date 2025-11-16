import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'lib/widgets/timeline.dart';

void main() {
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timeline Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Timeline Test', style: TextStyle(color: Colors.black)),
        ),
        body: const DualTimelineWidget(),
      ),
    );
  }
}