import 'dart:math';
import 'math_operation.dart';

class MathProblem {
  final MathOperation optionA;
  final MathOperation optionB;

  const MathProblem({required this.optionA, required this.optionB});

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

  // ==========================================
  // MÚLTIPLE CHOICE (3 opciones)
  // ==========================================

  /// Retorna el texto de la pregunta para el desafío matemático.
  String getQuestionText(int currentSoldiers) {
    final correctOp = getOptimalOperation(currentSoldiers);
    final opName = _operationName(correctOp);
    return 'Si tienes $currentSoldiers soldados,\n¿cuántos tendrás si $opName ${correctOp.value}?';
  }

  /// Retorna las 3 opciones de respuesta como lista de enteros.
  /// La primera siempre es la correcta.
  List<int> getChoiceOptions(int currentSoldiers) {
    final correctResult = getOptimalOperation(
      currentSoldiers,
    ).apply(currentSoldiers);
    final wrongResult = getOperationByIndex(
      1 - getCorrectOptionIndex(currentSoldiers),
    ).apply(currentSoldiers);

    final Set<int> options = {correctResult, wrongResult};
    final random = Random();

    // Generar una tercera opción incorrecta cercana al resultado correcto
    int thirdOption;
    int attempts = 0;
    do {
      final offset = (correctResult * 0.2).toInt().clamp(1, 20);
      thirdOption = correctResult + random.nextInt(offset * 2 + 1) - offset;
      attempts++;
    } while (options.contains(thirdOption) || thirdOption < 0 || attempts < 50);

    // Si no se pudo generar una tercera opción única, usar un valor fallback
    if (options.contains(thirdOption) || thirdOption < 0) {
      thirdOption = correctResult + 7;
      while (options.contains(thirdOption)) {
        thirdOption++;
      }
    }

    options.add(thirdOption);

    // Mezclar las opciones (pero recordar cuál es la correcta)
    final List<int> shuffled = options.toList()..shuffle(random);
    return shuffled;
  }

  /// Retorna el índice de la respuesta correcta en la lista mezclada.
  int getCorrectChoiceIndex(int currentSoldiers) {
    final correctResult = getOptimalOperation(
      currentSoldiers,
    ).apply(currentSoldiers);
    final options = getChoiceOptions(currentSoldiers);
    return options.indexOf(correctResult);
  }

  /// Verifica si la opción seleccionada es correcta.
  bool isCorrectAnswer(int selectedIndex, int currentSoldiers) {
    return selectedIndex == getCorrectChoiceIndex(currentSoldiers);
  }

  String _operationName(MathOperation op) {
    switch (op.type) {
      case MathOperationType.add:
        return 'sumas';
      case MathOperationType.sub:
        return 'restas';
      case MathOperationType.mult:
        return 'multiplicas por';
      case MathOperationType.div:
        return 'divides entre';
    }
  }
}
