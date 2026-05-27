import 'math_operation.dart';

class MathProblem {
  final MathOperation optionA;
  final MathOperation optionB;

  const MathProblem({
    required this.optionA,
    required this.optionB,
  });

  /// Evalúa ambas opciones dado el número actual de soldados y retorna
  /// la operación que ofrece el mejor resultado (mayor cantidad de soldados).
  MathOperation getOptimalOperation(int currentSoldiers) {
    final resultA = optionA.apply(currentSoldiers);
    final resultB = optionB.apply(currentSoldiers);
    return resultA >= resultB ? optionA : optionB;
  }

  /// Retorna el índice de la opción correcta (0 para Opción A, 1 para Opción B)
  /// dado el número actual de soldados.
  int getCorrectOptionIndex(int currentSoldiers) {
    final resultA = optionA.apply(currentSoldiers);
    final resultB = optionB.apply(currentSoldiers);
    return resultA >= resultB ? 0 : 1;
  }

  /// Retorna la operación correspondiente al índice seleccionado (0 o 1).
  MathOperation getOperationByIndex(int index) {
    return index == 0 ? optionA : optionB;
  }
}
