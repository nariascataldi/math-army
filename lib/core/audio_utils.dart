import 'dart:developer' as developer;

/// Interfaz abstracta para el sistema de audio, permitiendo inyectar una
/// implementación real con `audioplayers` o `soundpool` en el futuro.
abstract class AudioSystem {
  Future<void> init();
  void playPortalSuccess();
  void playPortalFailure();
  void playVictory();
  void playDefeat();
  void playSoldierSpawn();
  void toggleMute();
  bool get isMuted;
}

/// Implementación simulada (Mock) que imprime logs. Evita problemas de compilación
/// nativa iniciales y permite el desarrollo ágil de la lógica de juego.
class MockAudioSystem implements AudioSystem {
  bool _isMuted = false;

  @override
  Future<void> init() async {
    developer.log('MockAudioSystem: Inicializado');
  }

  @override
  void playPortalSuccess() {
    if (!_isMuted) developer.log('🔊 Sonido: ¡Portal Correcto!');
  }

  @override
  void playPortalFailure() {
    if (!_isMuted) developer.log('🔊 Sonido: Portal Incorrecto (Error)');
  }

  @override
  void playVictory() {
    if (!_isMuted) developer.log('🔊 Sonido: ¡Victoria!');
  }

  @override
  void playDefeat() {
    if (!_isMuted) developer.log('🔊 Sonido: Derrota');
  }

  @override
  void playSoldierSpawn() {
    if (!_isMuted) developer.log('🔊 Sonido: Clonación de soldado');
  }

  @override
  void toggleMute() {
    _isMuted = !_isMuted;
    developer.log('MockAudioSystem: Silencio = $_isMuted');
  }

  @override
  bool get isMuted => _isMuted;
}
