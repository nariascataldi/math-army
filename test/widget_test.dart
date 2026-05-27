import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:math_army/core/audio_utils.dart';
import 'package:math_army/features/math_engine/data/data_sources/problem_generator.dart';
import 'package:math_army/features/math_engine/data/repositories/math_repository_impl.dart';
import 'package:math_army/features/math_engine/domain/repositories/math_repository.dart';
import 'package:math_army/features/game/presentation/controllers/game_controller.dart';
import 'package:math_army/main.dart';

void main() {
  setUp(() async {
    final sl = GetIt.instance;
    // Registrar dependencias si no han sido ya registradas
    if (!sl.isRegistered<AudioSystem>()) {
      sl.registerSingleton<AudioSystem>(MockAudioSystem());
    }
    if (!sl.isRegistered<ProblemGenerator>()) {
      sl.registerLazySingleton<ProblemGenerator>(() => ProblemGenerator());
    }
    if (!sl.isRegistered<MathRepository>()) {
      sl.registerLazySingleton<MathRepository>(() => MathRepositoryImpl(sl()));
    }
    if (!sl.isRegistered<GameController>()) {
      sl.registerFactory(() => GameController(
            mathRepository: sl(),
            audioSystem: sl(),
          ));
    }
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('Math Army smoke test - Verifica pantalla de bienvenida', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Debe mostrar el título principal
    expect(find.text('MATH ARMY'), findsOneWidget);
    
    // Debe mostrar el botón de inicio
    expect(find.text('¡JUGAR AHORA!'), findsOneWidget);
  });
}
