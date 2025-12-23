import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:client_app/config/supabase_config.dart';
import 'package:client_app/data/models/creature_state.dart';
import 'package:client_app/data/models/habit_entry.dart';
import 'package:client_app/data/datasources/local_data_source.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  // Initialize Hive (local database)
  await Hive.initFlutter();

  // Register Hive type adapters
  Hive.registerAdapter(CreatureStateAdapter()); // typeId: 0
  Hive.registerAdapter(HabitEntryAdapter()); // typeId: 1
  Hive.registerAdapter(HabitTypeAdapter()); // typeId: 2
  Hive.registerAdapter(ValidationMethodAdapter()); // typeId: 3

  debugPrint('✅ Hive initialized and type adapters registered');

  // Initialize local data source (opens Hive boxes)
  final localDataSource = LocalDataSource();
  await localDataSource.init();

  debugPrint('✅ Local data source initialized');

  // Initialize Supabase with credentials from .env
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  debugPrint('✅ Supabase initialized: ${SupabaseConfig.supabaseUrl}');

  runApp(const XenoApp());
}

class XenoApp extends StatelessWidget {
  const XenoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UnityControlScreen(),
    );
  }
}

class UnityControlScreen extends StatefulWidget {
  const UnityControlScreen({super.key});

  @override
  State<UnityControlScreen> createState() => _UnityControlScreenState();
}

class _UnityControlScreenState extends State<UnityControlScreen> {
  UnityWidgetController? _unityWidgetController;

  // Этот метод вызывается, когда Unity готова к работе
  void _onUnityCreated(UnityWidgetController controller) {
    _unityWidgetController = controller;
    debugPrint("Unity Controller Attached");
  }

  // Главная функция "выстрела" в Unity
  void _sendCommand(String color) {
    if (_unityWidgetController != null) {
      // 1. Имя объекта в иерархии Unity (Cube)
      // 2. Имя метода в C# скрипте (SetColor)
      // 3. Аргумент (red / blue)
      _unityWidgetController?.postMessage('Cube', 'SetColor', color);
      debugPrint("Command sent: $color");
    } else {
      debugPrint("Error: Controller is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('XenoMirror: Link Test')),
      body: Stack(
        children: [
          // Слой 1: Окно в Unity
          UnityWidget(
            onUnityCreated: _onUnityCreated,
            useAndroidViewSurface:
                true, // Критично для корректного рендера на Android
            borderRadius: BorderRadius.zero,
          ),

          // Слой 2: Flutter UI поверх Unity
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.extended(
                  onPressed: () => _sendCommand('red'),
                  backgroundColor: Colors.red,
                  label: const Text("Make RED"),
                  icon: const Icon(Icons.colorize),
                ),
                FloatingActionButton.extended(
                  onPressed: () => _sendCommand('blue'),
                  backgroundColor: Colors.blue,
                  label: const Text("Make BLUE"),
                  icon: const Icon(Icons.colorize),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
