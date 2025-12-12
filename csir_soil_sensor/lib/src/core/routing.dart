import 'package:flutter/material.dart';

import '../features/live/live_screen.dart';
import '../features/history/history_screen.dart';
import '../features/crop_params/crop_form_screen.dart';
import '../features/export/export_screen.dart';
import '../features/charts/charts_screen.dart';

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _currentIndex = 0;

  final _pages = const [
    LiveScreen(),
    HistoryScreen(),
    ChartsScreen(),
    CropFormScreen(),
    ExportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'Live Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Charts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'Crop Params',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ios_share),
            label: 'Export',
          ),
        ],
      ),
    );
  }
}


