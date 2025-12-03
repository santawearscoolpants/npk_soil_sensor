import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/theme.dart';
import 'src/core/routing.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'CSIR Soil Sensor',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const RootScaffold(),
    );
  }
}
