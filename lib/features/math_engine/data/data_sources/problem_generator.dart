import 'dart:math';
import '../../domain/entities/math_operation.dart';
import '../../domain/entities/math_problem.dart';

class ProblemGenerator {
  final Random _random = Random();

  /// Genera una lista de [totalPortals] problemas (zonas de decisión) para el [level] indicado.
  /// Garantiza matemáticamente que:
  /// 1. El camino perfecto partiendo de 1 soldado resulta en un ejército final >= 70.
  /// 2. Cualquier error en el trayecto hace imposible alcanzar los 70 soldados.
  List<MathProblem> generateLevelProblems({required int level, int totalPortals = 5}) {
    List<MathProblem> problems = [];
    int currentOptimalSoldiers = 1;

    // Patrón de crecimiento para 5 portales que asegura llegar a >= 70.
    // Ej: Nivel 1
    // Paso 1: 1 -> +9 -> 10  (incorrecto: +2 -> 3)
    // Paso 2: 10 -> x3 -> 30  (incorrecto: +5 -> 15)
    // Paso 3: 30 -> +15 -> 45 (incorrecto: -10 -> 20)
    // Paso 4: 45 -> x2 -> 90  (incorrecto: ÷3 -> 15)
    // Paso 5: 90 -> -10 -> 80 (incorrecto: ÷2 -> 45)
    
    // Podemos parametrizar esto según el nivel del juego para añadir variedad numérica.

    for (int step = 0; step < totalPortals; step++) {
      MathOperation correctOp;
      MathOperation incorrectOp;

      if (step == 0) {
        // Paso 1: Suma inicial para tener una base de soldados.
        final int valCorrect = 8 + _random.nextInt(3); // 8 a 10
        final int valIncorrect = 1 + _random.nextInt(2); // 1 a 2
        correctOp = MathOperation.create(type: MathOperationType.add, value: valCorrect);
        incorrectOp = MathOperation.create(type: MathOperationType.add, value: valIncorrect);
      } 
      else if (step == 1) {
        // Paso 2: Multiplicación moderada.
        final int valCorrect = 3; 
        final int valIncorrect = 2; // Suma muy pequeña
        correctOp = MathOperation.create(type: MathOperationType.mult, value: valCorrect);
        incorrectOp = MathOperation.create(type: MathOperationType.add, value: valIncorrect);
      } 
      else if (step == 2) {
        // Paso 3: Suma grande o Resta.
        final int valCorrect = 12 + _random.nextInt(5); // 12 a 16
        final int valIncorrect = 5 + _random.nextInt(4); // Resta
        correctOp = MathOperation.create(type: MathOperationType.add, value: valCorrect);
        incorrectOp = MathOperation.create(type: MathOperationType.sub, value: valIncorrect);
      } 
      else if (step == 3) {
        // Paso 4: Multiplicación de soldados.
        final int valCorrect = 2;
        final int valIncorrect = 3; // División por 3 (penalización severa)
        correctOp = MathOperation.create(type: MathOperationType.mult, value: valCorrect);
        incorrectOp = MathOperation.create(type: MathOperationType.div, value: valIncorrect);
      } 
      else {
        // Paso 5: Ajuste final.
        final int valCorrect = 5 + _random.nextInt(4); // +5 a +8
        final int valIncorrect = 2; // División por 2 (reduce a la mitad)
        correctOp = MathOperation.create(type: MathOperationType.add, value: valCorrect);
        incorrectOp = MathOperation.create(type: MathOperationType.div, value: valIncorrect);
      }

      // Aplicar operación correcta al acumulado teórico óptimo
      currentOptimalSoldiers = correctOp.apply(currentOptimalSoldiers);

      // Decidir aleatoriamente el orden de los portales (Opción A vs Opción B)
      final bool correctIsA = _random.nextBool();
      problems.add(
        MathProblem(
          optionA: correctIsA ? correctOp : incorrectOp,
          optionB: correctIsA ? incorrectOp : correctOp,
        ),
      );
    }

    // Validación de seguridad de último recurso:
    // Si el algoritmo dinámico generó valores que no alcanzan 70 por azar,
    // forzamos un set precalculado garantizado.
    if (currentOptimalSoldiers < 70) {
      return _generateFallbackProblems();
    }

    return problems;
  }

  List<MathProblem> _generateFallbackProblems() {
    return [
      MathProblem(
        optionA: MathOperation.create(type: MathOperationType.add, value: 9),
        optionB: MathOperation.create(type: MathOperationType.add, value: 2),
      ),
      MathProblem(
        optionA: MathOperation.create(type: MathOperationType.add, value: 5),
        optionB: MathOperation.create(type: MathOperationType.mult, value: 3),
      ),
      MathProblem(
        optionA: MathOperation.create(type: MathOperationType.add, value: 15),
        optionB: MathOperation.create(type: MathOperationType.sub, value: 10),
      ),
      MathProblem(
        optionA: MathOperation.create(type: MathOperationType.mult, value: 2),
        optionB: MathOperation.create(type: MathOperationType.div, value: 3),
      ),
      MathProblem(
        optionA: MathOperation.create(type: MathOperationType.add, value: 10),
        optionB: MathOperation.create(type: MathOperationType.div, value: 2),
      ),
    ];
  }
}
