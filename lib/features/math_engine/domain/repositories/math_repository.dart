import '../entities/math_problem.dart';

abstract class MathRepository {
  /// Retorna la lista de problemas para un nivel específico.
  List<MathProblem> getProblemsForLevel(int level);
}
