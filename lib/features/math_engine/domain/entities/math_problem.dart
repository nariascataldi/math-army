import 'dart:math';
import 'math_operation.dart';

class MathQuestion {
  final String text;
  final int correctAnswer;
  final List<int> options;
  final int correctIndex;

  const MathQuestion({
    required this.text,
    required this.correctAnswer,
    required this.options,
    required this.correctIndex,
  });
}

class OperationChoice {
  final String label;
  final String resultLabel;
  final int resultValue;
  final MathOperation operation;

  const OperationChoice({
    required this.label,
    required this.resultLabel,
    required this.resultValue,
    required this.operation,
  });
}

class MathProblem {
  final MathOperation optionA;
  final MathOperation optionB;

  const MathProblem({required this.optionA, required this.optionB});

  MathOperation getOptimalOperation(int currentSoldiers) {
    final resultA = optionA.apply(currentSoldiers);
    final resultB = optionB.apply(currentSoldiers);
    return resultA >= resultB ? optionA : optionB;
  }

  int getCorrectOptionIndex(int currentSoldiers) {
    final resultA = optionA.apply(currentSoldiers);
    final resultB = optionB.apply(currentSoldiers);
    return resultA >= resultB ? 0 : 1;
  }

  MathOperation getOperationByIndex(int index) {
    return index == 0 ? optionA : optionB;
  }

  // ==========================================
  // FASE 1: PREGUNTA MATEMÁTICA
  // ==========================================

  MathQuestion getMathQuestion(int currentSoldiers) {
    final random = Random();

    // Generar una pregunta que SIEMPRE sea positiva (suma o multiplicación)
    final isAddition = random.nextBool();
    final int a = currentSoldiers;
    final int b;
    final int correctAnswer;
    final String text;

    if (isAddition) {
      b = 2 + random.nextInt(9); // 2 a 10
      correctAnswer = a + b;
      text = '$a + $b = ?';
    } else {
      b = 2 + random.nextInt(3); // 2 a 4
      correctAnswer = a * b;
      text = '$a x $b = ?';
    }

    // Generar 3 opciones (correcta + 2 incorrectas)
    final Set<int> options = {correctAnswer};
    while (options.length < 3) {
      final offset = (correctAnswer * 0.3).toInt().clamp(2, 20);
      final candidate = correctAnswer + random.nextInt(offset * 2 + 1) - offset;
      if (candidate > 0 && !options.contains(candidate)) {
        options.add(candidate);
      }
    }

    final List<int> shuffled = options.toList()..shuffle(random);
    return MathQuestion(
      text: text,
      correctAnswer: correctAnswer,
      options: shuffled,
      correctIndex: shuffled.indexOf(correctAnswer),
    );
  }

  // ==========================================
  // FASE 2: ELECCIÓN DE OPERACIÓN
  // ==========================================

  List<OperationChoice> getOperationChoices(int mathResult) {
    // Ambas opciones son POSITIVAS (suma o multiplicación)
    final choiceA = _buildChoice(optionA, mathResult);
    final choiceB = _buildChoice(optionB, mathResult);
    return [choiceA, choiceB];
  }

  OperationChoice _buildChoice(MathOperation op, int mathResult) {
    String label;
    String resultLabel;
    int resultValue;

    switch (op.type) {
      case MathOperationType.add:
        label = '+${op.value} soldados';
        resultValue = mathResult + op.value;
        resultLabel = '→ $resultValue soldados';
        break;
      case MathOperationType.sub:
        // Convertir resta a suma para que siempre sea positivo
        label = '+${op.value} soldados';
        resultValue = mathResult + op.value;
        resultLabel = '→ $resultValue soldados';
        break;
      case MathOperationType.mult:
        label = 'x${op.value} soldados';
        resultValue = mathResult * op.value;
        resultLabel = '→ $resultValue soldados';
        break;
      case MathOperationType.div:
        // Convertir división a multiplicación para que siempre sea positivo
        label = 'x${op.value} soldados';
        resultValue = mathResult * op.value;
        resultLabel = '→ $resultValue soldados';
        break;
    }

    return OperationChoice(
      label: label,
      resultLabel: resultLabel,
      resultValue: resultValue,
      operation: op,
    );
  }
}
