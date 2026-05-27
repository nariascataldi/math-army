import '../../domain/entities/math_problem.dart';
import '../../domain/repositories/math_repository.dart';
import '../data_sources/problem_generator.dart';

class MathRepositoryImpl implements MathRepository {
  final ProblemGenerator _generator;

  MathRepositoryImpl(this._generator);

  @override
  List<MathProblem> getProblemsForLevel(int level) {
    // Por defecto generamos niveles de 5 zonas de decisión
    return _generator.generateLevelProblems(level: level, totalPortals: 5);
  }
}
