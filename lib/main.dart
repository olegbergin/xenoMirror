import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:client_app/config/supabase_config.dart';
import 'package:client_app/data/models/creature_state.dart';
import 'package:client_app/data/models/habit_entry.dart';
import 'package:client_app/data/datasources/local_data_source.dart';
import 'package:client_app/data/repositories/creature_repository.dart';
import 'package:client_app/data/repositories/habit_repository.dart';
import 'package:client_app/presentation/blocs/creature/creature_bloc.dart';
import 'package:client_app/presentation/blocs/habit/habit_bloc.dart';
import 'package:client_app/presentation/pages/home_page.dart';
import 'package:client_app/core/theme/app_theme.dart';

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

  // Configure system UI overlay for dark theme
  AppTheme.setSystemUIOverlay();

  runApp(XenoApp(localDataSource: localDataSource));
}

class XenoApp extends StatelessWidget {
  const XenoApp({
    super.key,
    required this.localDataSource,
  });

  final LocalDataSource localDataSource;

  @override
  Widget build(BuildContext context) {
    // Initialize repositories
    final creatureRepository = CreatureRepository(localDataSource: localDataSource);
    final habitRepository = HabitRepository(localDataSource: localDataSource);

    return MultiBlocProvider(
      providers: [
        // Creature BLoC - manages creature evolution and XP
        BlocProvider<CreatureBloc>(
          create: (context) => CreatureBloc(
            creatureRepository: creatureRepository,
          ),
        ),
        // Habit BLoC - manages habit logging and history
        BlocProvider<HabitBloc>(
          create: (context) => HabitBloc(
            habitRepository: habitRepository,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'XenoMirror OS',
        theme: AppTheme.darkTheme,
        home: const HomePage(),
      ),
    );
  }
}
