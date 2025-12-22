import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

void main() {
  runApp(const XenoApp());
}

class XenoApp extends StatelessWidget {
  const XenoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XenoMirror',
      theme: ThemeData.dark(), // Темная тема для киберпанка
      home: const UnityScreen(),
    );
  }
}

class UnityScreen extends StatefulWidget {
  const UnityScreen({super.key});

  @override
  State<UnityScreen> createState() => _UnityScreenState();
}

class _UnityScreenState extends State<UnityScreen> {
  UnityWidgetController? _unityWidgetController;

  @override
  void dispose() {
    _unityWidgetController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("XenoMirror Protocol")),
      body: Stack(
        children: [
          // Слой 1: Unity (Фон)
          UnityWidget(
            onUnityCreated: _onUnityCreated,
            useAndroidViewSurface: true, // ВАЖНО для Android
            borderRadius: BorderRadius.circular(20.0),
          ),
          
          // Слой 2: Flutter UI (Поверх Unity)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Status: Connection Established",
                  style: TextStyle(color: Colors.greenAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Callback, когда Unity загрузилась
  void _onUnityCreated(UnityWidgetController controller) {
    _unityWidgetController = controller;
    print("Unity loaded successfully");
  }
}