import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/songs_list_screen.dart';
import '../config/app_texts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(1200, 850),
        minimumSize: Size(900, 700),
        center: true,
        title: AppTexts.appTitle,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTexts.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'NotoSansJP',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5C6BC0)),
      ),
      home: const SongsListScreen(),
    );
  }
}