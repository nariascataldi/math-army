import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'core/audio_utils.dart';
import 'core/theme.dart';
import 'features/game/presentation/controllers/game_controller.dart';
import 'features/game/presentation/pages/game_screen.dart';
import 'features/math_engine/data/data_sources/problem_generator.dart';
import 'features/math_engine/data/repositories/math_repository_impl.dart';
import 'features/math_engine/domain/repositories/math_repository.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // 1. Core Services
  final audioSystem = MockAudioSystem();
  await audioSystem.init();
  sl.registerSingleton<AudioSystem>(audioSystem);

  // 2. Data Sources
  sl.registerLazySingleton<ProblemGenerator>(() => ProblemGenerator());

  // 3. Repositories
  sl.registerLazySingleton<MathRepository>(() => MathRepositoryImpl(sl()));

  // 4. Controllers/Blocs
  sl.registerFactory(() => GameController(
        mathRepository: sl(),
        audioSystem: sl(),
      ));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Army',
      debugShowCheckedModeBanner: false,
      theme: GameTheme.darkTheme,
      home: ChangeNotifierProvider(
        create: (_) => sl<GameController>(),
        child: const GameScreen(),
      ),
    );
  }
}
