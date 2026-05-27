import 'package:flutter_test/flutter_test.dart';
import 'package:math_army/features/math_engine/data/data_sources/problem_generator.dart';
import 'package:math_army/features/math_engine/domain/entities/math_operation.dart';
import 'package:math_army/features/math_engine/domain/entities/math_problem.dart';

void main() {
  group('Pruebas de MathOperation (Entidades y Factoría)', () {
    test('AddOperation debe sumar correctamente', () {
      final op = AddOperation(15);
      expect(op.apply(10), 25);
      expect(op.expression, '+15');
    });

    test('SubOperation debe restar correctamente sin bajar de 0', () {
      final op = SubOperation(8);
      expect(op.apply(15), 7);
      expect(op.apply(5), 0); // No debe dar negativo
      expect(op.expression, '-8');
    });

    test('MultOperation debe multiplicar correctamente', () {
      final op = MultOperation(3);
      expect(op.apply(5), 15);
      expect(op.expression, 'x3');
    });

    test('DivOperation debe dividir usando división entera', () {
      final op = DivOperation(2);
      expect(op.apply(9), 4); // 9 ~/ 2 = 4
      expect(op.apply(1), 0); // 1 ~/ 2 = 0
      expect(op.expression, '÷2');
    });

    test('La factoría create debe instanciar las operaciones correctas', () {
      final add = MathOperation.create(type: MathOperationType.add, value: 5);
      final sub = MathOperation.create(type: MathOperationType.sub, value: 3);
      final mult = MathOperation.create(type: MathOperationType.mult, value: 2);
      final div = MathOperation.create(type: MathOperationType.div, value: 4);

      expect(add, isA<AddOperation>());
      expect(sub, isA<SubOperation>());
      expect(mult, isA<MultOperation>());
      expect(div, isA<DivOperation>());
    });

    test('La factoría fromString debe instanciar operaciones desde texto', () {
      final op = MathOperation.fromString('mult', 3);
      expect(op, isA<MultOperation>());
      expect(op.apply(4), 12);
    });
  });

  group('Pruebas de MathProblem e Invariante de Nivel (Garantía >= 70)', () {
    late ProblemGenerator generator;

    setUp(() {
      generator = ProblemGenerator();
    });

    test('El camino perfecto (decisión correcta) debe resultar en >= 70 soldados', () {
      // Probar en varios niveles para asegurar robustez
      for (int level = 1; level <= 10; level++) {
        final List<MathProblem> problems = generator.generateLevelProblems(level: level, totalPortals: 5);
        
        int soldiers = 1; // Comenzamos con 1 soldado
        for (var problem in problems) {
          final optimalOp = problem.getOptimalOperation(soldiers);
          soldiers = optimalOp.apply(soldiers);
        }
        
        expect(soldiers, greaterThanOrEqualTo(70), 
          reason: 'Fallo en nivel $level: El camino óptimo dio $soldiers soldados, que es menor a 70');
      }
    });

    test('Elegir al menos una opción incorrecta debe dejar al jugador con < 70 soldados', () {
      for (int level = 1; level <= 10; level++) {
        final List<MathProblem> problems = generator.generateLevelProblems(level: level, totalPortals: 5);

        // Simularemos cometer un error en cada uno de los pasos para verificar que
        // CUALQUIER error individual hace imposible llegar a 70 soldados.
        for (int errorStep = 0; errorStep < problems.length; errorStep++) {
          int soldiers = 1;
          for (int step = 0; step < problems.length; step++) {
            final problem = problems[step];
            if (step == errorStep) {
              // Tomar la opción incorrecta (la que da menor resultado)
              final correctIndex = problem.getCorrectOptionIndex(soldiers);
              final incorrectIndex = correctIndex == 0 ? 1 : 0;
              final incorrectOp = problem.getOperationByIndex(incorrectIndex);
              soldiers = incorrectOp.apply(soldiers);
            } else {
              // Tomar la opción óptima
              final optimalOp = problem.getOptimalOperation(soldiers);
              soldiers = optimalOp.apply(soldiers);
            }
          }

          expect(soldiers, lessThan(70), 
            reason: 'Fallo en nivel $level: Cometiendo un error en el paso $errorStep se llegó a $soldiers soldados (>= 70), violando la regla del juego.');
        }
      }
    });
  });
}
