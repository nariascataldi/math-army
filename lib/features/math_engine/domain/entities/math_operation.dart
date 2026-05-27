import 'dart:math';

enum MathOperationType { add, sub, mult, div }

abstract class MathOperation {
  MathOperationType get type;
  int get value;

  /// Aplica la operación matemática sobre la cantidad actual de soldados.
  int apply(int currentSoldiers);

  /// Representación textual de la operación (ej: "+15", "x3").
  String get expression;

  /// Factoría para crear operaciones matemáticas. Facilita la extensión
  /// para docentes/padres que deseen añadir nuevas operaciones en el futuro.
  factory MathOperation.create({
    required MathOperationType type,
    required int value,
  }) {
    switch (type) {
      case MathOperationType.add:
        return AddOperation(value);
      case MathOperationType.sub:
        return SubOperation(value);
      case MathOperationType.mult:
        return MultOperation(value);
      case MathOperationType.div:
        return DivOperation(value);
    }
  }

  /// Factoría a partir de una cadena y un valor (ej: "ADD", 15)
  factory MathOperation.fromString(String typeStr, int value) {
    final type = MathOperationType.values.firstWhere(
      (e) => e.name.toLowerCase() == typeStr.toLowerCase(),
      orElse: () => MathOperationType.add,
    );
    return MathOperation.create(type: type, value: value);
  }
}

// ==========================================
// OPERACIONES CONCRETAS
// ==========================================

class AddOperation implements MathOperation {
  @override
  final MathOperationType type = MathOperationType.add;
  @override
  final int value;

  AddOperation(this.value);

  @override
  int apply(int currentSoldiers) => currentSoldiers + value;

  @override
  String get expression => '+$value';
}

class SubOperation implements MathOperation {
  @override
  final MathOperationType type = MathOperationType.sub;
  @override
  final int value;

  SubOperation(this.value);

  @override
  int apply(int currentSoldiers) => max(0, currentSoldiers - value);

  @override
  String get expression => '-$value';
}

class MultOperation implements MathOperation {
  @override
  final MathOperationType type = MathOperationType.mult;
  @override
  final int value;

  MultOperation(this.value);

  @override
  int apply(int currentSoldiers) => currentSoldiers * value;

  @override
  String get expression => 'x$value';
}

class DivOperation implements MathOperation {
  @override
  final MathOperationType type = MathOperationType.div;
  @override
  final int value;

  DivOperation(this.value);

  @override
  int apply(int currentSoldiers) {
    if (value <= 0) return currentSoldiers; // Evitar división por cero o negativos
    return currentSoldiers ~/ value;
  }

  @override
  String get expression => '÷$value';
}
