import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_painter.dart';
import '../../../../core/theme.dart';
import '../../domain/entities/game_state.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameController>(
        builder: (context, controller, child) {
          return SafeArea(
            child: Stack(
              children: [
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final double screenWidth = MediaQuery.of(
                      context,
                    ).size.width;
                    final double normalizedDelta =
                        (details.primaryDelta ?? 0.0) / (screenWidth * 0.4);
                    controller.moveLeo(normalizedDelta);
                  },
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: GamePainter(
                      state: GameControllerState(
                        status: controller.status,
                        progress: controller.progress,
                        leoX: controller.leo.x,
                        soldiersCount: controller.activeSoldiers.length,
                        soldiers: controller.activeSoldiers,
                        bossSoldiers: controller.boss.currentSoldiers,
                        decisionZones: controller.decisionZones,
                        levelProblems: controller.levelProblems,
                        soldiersCountAtPortal: controller.soldiersCountAtPortal,
                      ),
                    ),
                  ),
                ),
                _buildHUD(context, controller),
                if (controller.status == GameStatus.running)
                  _buildSideTouchControls(controller),
                _buildGameOverlays(context, controller),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHUD(BuildContext context, GameController controller) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: GameTheme.neonGlow(color: GameTheme.neonCyan),
                child: Text(
                  'NIVEL ${controller.currentLevel}',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: GameTheme.neonCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      controller.audioSystem.isMuted
                          ? Icons.volume_off
                          : Icons.volume_up,
                      color: GameTheme.neonCyan,
                    ),
                    onPressed: () => controller.toggleMute(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: GameTheme.neonCyan),
                    onPressed: () => controller.resetLevel(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.flag_outlined,
                color: GameTheme.neonCyan,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 8,
                    child: LinearProgressIndicator(
                      value: controller.progress,
                      backgroundColor: GameTheme.slateBlue,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        controller.progress > 0.85
                            ? GameTheme.neonOrange
                            : GameTheme.neonCyan,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.stars_sharp,
                color: GameTheme.neonOrange,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideTouchControls(GameController controller) {
    return Positioned.fill(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (_) => controller.moveLeo(-0.15),
              child: const SizedBox.expand(),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (_) => controller.moveLeo(0.15),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverlays(BuildContext context, GameController controller) {
    switch (controller.status) {
      case GameStatus.idle:
        return _buildStartOverlay(context, controller);
      case GameStatus.mathChallenge:
        return _MathChallengeOverlay(
          key: ValueKey('challenge_${controller.currentChallengeIndex}'),
          controller: controller,
        );
      case GameStatus.bossBattle:
        return _buildBossBattleOverlay(context, controller);
      case GameStatus.victory:
        return _buildVictoryOverlay(context, controller);
      case GameStatus.defeat:
        return _buildDefeatOverlay(context, controller);
      case GameStatus.running:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStartOverlay(BuildContext context, GameController controller) {
    return Container(
      color: GameTheme.spaceCadet.withValues(alpha: 0.9),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'MATH ARMY',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 42,
                  color: GameTheme.neonCyan,
                  shadows: [
                    const Shadow(blurRadius: 15, color: GameTheme.neonCyan),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '¡El runner de matemáticas!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GameTheme.textGrey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: GameTheme.neonGlow(
                  color: GameTheme.neonCyan.withValues(alpha: 0.5),
                ),
                child: Column(
                  children: [
                    Text(
                      'Misión del Nivel ${controller.currentLevel}',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '1. Controla al héroe "Leo" deslizando tu dedo a los lados.\n'
                      '2. Resuelve los desafíos matemáticos.\n'
                      '3. ¡Reúne al menos 70 soldados para vencer al jefe enemigo!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: GameTheme.textWhite,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTheme.neonCyan,
                  foregroundColor: GameTheme.spaceCadet,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                  shadowColor: GameTheme.neonCyan,
                ),
                onPressed: () => controller.startGame(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '¡JUGAR AHORA!',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: GameTheme.spaceCadet,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.play_arrow_rounded, size: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBossBattleOverlay(
    BuildContext context,
    GameController controller,
  ) {
    return Positioned(
      bottom: 80,
      left: 32,
      right: 32,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: GameTheme.neonGlow(color: GameTheme.neonOrange),
        child: Column(
          children: [
            Text(
              '¡COMBATE FINAL!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: GameTheme.neonOrange,
                fontSize: 20,
                shadows: [
                  const Shadow(blurRadius: 10, color: GameTheme.neonOrange),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(Icons.people, color: GameTheme.neonCyan),
                    Text(
                      '${controller.activeSoldiers.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Tu Ejército',
                      style: TextStyle(fontSize: 10, color: GameTheme.textGrey),
                    ),
                  ],
                ),
                const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Column(
                  children: [
                    const Icon(Icons.security, color: GameTheme.neonRed),
                    Text(
                      '${controller.boss.currentSoldiers}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Jefe Enemigo',
                      style: TextStyle(fontSize: 10, color: GameTheme.textGrey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVictoryOverlay(BuildContext context, GameController controller) {
    return Container(
      color: GameTheme.spaceCadet.withValues(alpha: 0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Colors.amber,
                size: 100,
              ),
              const SizedBox(height: 16),
              Text(
                '¡VICTORIA!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 46,
                  color: GameTheme.neonGreen,
                  shadows: [
                    const Shadow(blurRadius: 15, color: GameTheme.neonGreen),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Derrotaste al jefe enemigo con éxito.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GameTheme.textWhite,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTheme.neonGreen,
                  foregroundColor: GameTheme.spaceCadet,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadowColor: GameTheme.neonGreen,
                  elevation: 10,
                ),
                onPressed: () => controller.nextLevel(),
                child: Text(
                  'SIGUIENTE NIVEL',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: GameTheme.spaceCadet,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefeatOverlay(BuildContext context, GameController controller) {
    return Container(
      color: GameTheme.spaceCadet.withValues(alpha: 0.95),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sentiment_very_dissatisfied,
                color: GameTheme.neonRed,
                size: 100,
              ),
              const SizedBox(height: 16),
              Text(
                'DERROTA',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 46,
                  color: GameTheme.neonRed,
                  shadows: [
                    const Shadow(blurRadius: 15, color: GameTheme.neonRed),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tu ejército no fue lo suficientemente grande.\n'
                '¡El jefe requiere al menos 70 soldados!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GameTheme.textWhite,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tip: Calcula mentalmente antes de responder.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: GameTheme.neonCyan,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GameTheme.neonRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  shadowColor: GameTheme.neonRed,
                  elevation: 10,
                ),
                onPressed: () => controller.resetLevel(),
                child: Text(
                  'REINTENTAR',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// OVERLAY DE DESAFÍO MATEMÁTICO (2 FASES)
// ==========================================

class _MathChallengeOverlay extends StatefulWidget {
  final GameController controller;
  const _MathChallengeOverlay({super.key, required this.controller});
  @override
  State<_MathChallengeOverlay> createState() => _MathChallengeOverlayState();
}

class _MathChallengeOverlayState extends State<_MathChallengeOverlay>
    with SingleTickerProviderStateMixin {
  int? _selectedIndex;
  bool? _isCorrect;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onMathAnswerSelected(int index) {
    if (_selectedIndex != null) return;

    final problem = widget
        .controller
        .levelProblems[widget.controller.currentChallengeIndex];
    final question = problem.getMathQuestion(
      widget.controller.challengeSoldiersCount,
    );

    setState(() {
      _selectedIndex = index;
      _isCorrect = index == question.correctIndex;
    });

    widget.controller.submitMathAnswer(index);
  }

  void _onOperationSelected(int index) {
    widget.controller.submitOperationChoice(index);
  }

  @override
  Widget build(BuildContext context) {
    final phase = widget.controller.challengePhase;

    return Container(
      color: GameTheme.spaceCadet.withValues(alpha: 0.97),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildHeader(),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: phase == MathChallengePhase.question
                      ? _buildQuestionPhase(key: const ValueKey('question'))
                      : _buildOperationPhase(key: const ValueKey('operation')),
                ),
                const Spacer(),
                _buildProgressIndicator(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final soldiers = widget.controller.challengeSoldiersCount;
    final phase = widget.controller.challengePhase;
    final title = phase == MathChallengePhase.question
        ? '¡DESAFÍO MATEMÁTICO!'
        : '¡ELIGE TU PODER!';
    final titleColor = phase == MathChallengePhase.question
        ? GameTheme.neonOrange
        : GameTheme.neonGreen;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: GameTheme.neonGlow(
            color: GameTheme.neonCyan.withValues(alpha: 0.6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield, color: GameTheme.neonCyan, size: 24),
              const SizedBox(width: 12),
              Text(
                '$soldiers soldados',
                style: const TextStyle(
                  color: GameTheme.neonCyan,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: titleColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 12, color: titleColor)],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // FASE 1: PREGUNTA MATEMÁTICA
  // ==========================================

  Widget _buildQuestionPhase({required Key key}) {
    final problem = widget
        .controller
        .levelProblems[widget.controller.currentChallengeIndex];
    final question = problem.getMathQuestion(
      widget.controller.challengeSoldiersCount,
    );

    return Column(
      key: key,
      children: [
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: GameTheme.slateBlue,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: GameTheme.neonCyan.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: GameTheme.neonCyan.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.psychology, color: GameTheme.neonCyan, size: 40),
              const SizedBox(height: 16),
              Text(
                question.text,
                style: const TextStyle(
                  color: GameTheme.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ...List.generate(3, (index) {
          final option = question.options[index];
          final isSelected = _selectedIndex == index;
          final isCorrectOption = index == question.correctIndex;
          final showResult = _selectedIndex != null;

          Color bgColor;
          Color borderColor;
          Color textColor;
          IconData? icon;

          if (!showResult) {
            bgColor = GameTheme.slateBlue;
            borderColor = GameTheme.neonCyan.withValues(alpha: 0.3);
            textColor = GameTheme.textWhite;
            icon = null;
          } else if (isCorrectOption) {
            bgColor = GameTheme.neonGreen.withValues(alpha: 0.2);
            borderColor = GameTheme.neonGreen;
            textColor = GameTheme.neonGreen;
            icon = Icons.check_circle;
          } else if (isSelected && !_isCorrect!) {
            bgColor = GameTheme.neonRed.withValues(alpha: 0.2);
            borderColor = GameTheme.neonRed;
            textColor = GameTheme.neonRed;
            icon = Icons.cancel;
          } else {
            bgColor = GameTheme.slateBlue.withValues(alpha: 0.5);
            borderColor = Colors.white.withValues(alpha: 0.1);
            textColor = GameTheme.textGrey;
            icon = null;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _selectedIndex == null
                      ? () => _onMathAnswerSelected(index)
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: borderColor,
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: showResult && isCorrectOption
                          ? [
                              BoxShadow(
                                color: GameTheme.neonGreen.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$option',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (icon != null)
                          Icon(icon, color: textColor, size: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // FASE 2: ELECCIÓN DE OPERACIÓN
  // ==========================================

  Widget _buildOperationPhase({required Key key}) {
    final problem = widget
        .controller
        .levelProblems[widget.controller.currentChallengeIndex];
    final choices = problem.getOperationChoices(widget.controller.mathResult);
    final currentSoldiers = widget.controller.mathResult;

    return Column(
      key: key,
      children: [
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: GameTheme.slateBlue,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: GameTheme.neonGreen.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: GameTheme.neonGreen.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.star, color: GameTheme.neonGreen, size: 40),
              const SizedBox(height: 12),
              Text(
                'Tienes $currentSoldiers soldados.',
                style: const TextStyle(
                  color: GameTheme.textWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '¿Qué quieres hacer?',
                style: TextStyle(
                  color: GameTheme.neonGreen.withValues(alpha: 0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ...List.generate(2, (index) {
          final choice = choices[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onOperationSelected(index),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: GameTheme.slateBlue,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: GameTheme.neonGreen.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: GameTheme.neonGreen.withValues(alpha: 0.1),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        choice.label,
                        style: const TextStyle(
                          color: GameTheme.neonGreen,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        choice.resultLabel,
                        style: TextStyle(
                          color: GameTheme.textWhite.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isCompleted = index < widget.controller.currentChallengeIndex;
        final isCurrent = index == widget.controller.currentChallengeIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 24 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isCompleted
                ? GameTheme.neonGreen
                : isCurrent
                ? GameTheme.neonCyan
                : GameTheme.slateBlue,
            borderRadius: BorderRadius.circular(5),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: GameTheme.neonCyan.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
