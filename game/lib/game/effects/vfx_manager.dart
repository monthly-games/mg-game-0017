import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// VFX Manager for Dungeon Craft Tycoon (MG-0017)
/// Crafting + Idle Tycoon 게임 전용 이펙트 관리자
class VfxManager extends Component with HasGameRef {
  VfxManager();
  final Random _random = Random();

  // Crafting Effects
  void showMaterialGather(Vector2 position, Color materialColor) {
    gameRef.add(_createBurstEffect(position: position, color: materialColor, count: 10, speed: 50, lifespan: 0.4));
    showNumberPopup(position, '+1', color: materialColor);
  }

  void showCraftingComplete(Vector2 position, {required String quality}) {
    Color color; int particleCount;
    switch (quality) {
      case 'masterpiece': color = Colors.amber; particleCount = 40; break;
      case 'excellent': color = Colors.purple; particleCount = 30; break;
      case 'good': color = Colors.blue; particleCount = 20; break;
      default: color = Colors.grey; particleCount = 12;
    }
    gameRef.add(_createExplosionEffect(position: position, color: color, count: particleCount, radius: quality == 'masterpiece' ? 80 : 55));
    gameRef.add(_createSparkleEffect(position: position, color: Colors.white, count: 15));
    if (quality == 'masterpiece' || quality == 'excellent') {
      gameRef.add(_QualityText(position: position, quality: quality));
    }
  }

  void showCraftingProgress(Vector2 position) {
    gameRef.add(_createRisingEffect(position: position, color: Colors.orange, count: 5, speed: 40));
  }

  void showRecipeUnlock(Vector2 position) {
    gameRef.add(_createExplosionEffect(position: position, color: Colors.amber, count: 30, radius: 65));
    gameRef.add(_createSparkleEffect(position: position, color: Colors.yellow, count: 18));
    gameRef.add(_RecipeText(position: position));
  }

  // Shop Effects
  void showSaleSuccess(Vector2 position, int goldAmount) {
    gameRef.add(_createCoinEffect(position: position, count: (goldAmount / 20).clamp(5, 20).toInt()));
    showNumberPopup(position, '+$goldAmount G', color: Colors.amber);
  }

  void showCustomerSatisfied(Vector2 position) {
    gameRef.add(_createHeartEffect(position: position));
    gameRef.add(_createRisingEffect(position: position, color: Colors.pink.shade200, count: 5, speed: 35));
  }

  void showShopUpgrade(Vector2 position) {
    gameRef.add(_createExplosionEffect(position: position, color: Colors.green, count: 35, radius: 70));
    gameRef.add(_createSparkleEffect(position: position, color: Colors.lightGreen, count: 15));
    gameRef.add(_UpgradeText(position: position));
  }

  // Tycoon Effects
  void showOfflineReward(Vector2 centerPosition) {
    for (int i = 0; i < 6; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (!isMounted) return;
        gameRef.add(_createCoinEffect(position: centerPosition + Vector2((_random.nextDouble() - 0.5) * 150, -30), count: 8));
      });
    }
  }

  void showNumberPopup(Vector2 position, String text, {Color color = Colors.white}) {
    gameRef.add(_NumberPopup(position: position, text: text, color: color));
  }

  // Private generators
  ParticleSystemComponent _createBurstEffect({required Vector2 position, required Color color, required int count, required double speed, required double lifespan}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: lifespan, generator: (i) {
      final angle = (i / count) * 2 * pi;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * (speed * (0.5 + _random.nextDouble() * 0.5)), acceleration: Vector2(0, 120), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 4 * (1.0 - particle.progress * 0.5), Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createExplosionEffect({required Vector2 position, required Color color, required int count, required double radius}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.7, generator: (i) {
      final angle = _random.nextDouble() * 2 * pi; final speed = radius * (0.4 + _random.nextDouble() * 0.6);
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 90), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 5 * (1.0 - particle.progress * 0.3), Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createSparkleEffect({required Vector2 position, required Color color, required int count}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.5, generator: (i) {
      final angle = _random.nextDouble() * 2 * pi; final speed = 45 + _random.nextDouble() * 35;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 35), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0); final size = 3 * (1.0 - particle.progress * 0.5);
        final path = Path(); for (int j = 0; j < 4; j++) { final a = (j * pi / 2); if (j == 0) path.moveTo(cos(a) * size, sin(a) * size); else path.lineTo(cos(a) * size, sin(a) * size); } path.close();
        canvas.drawPath(path, Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createRisingEffect({required Vector2 position, required Color color, required int count, required double speed}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.8, generator: (i) {
      final spreadX = (_random.nextDouble() - 0.5) * 25;
      return AcceleratedParticle(position: position.clone() + Vector2(spreadX, 0), speed: Vector2(0, -speed), acceleration: Vector2(0, -15), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 3, Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createCoinEffect({required Vector2 position, required int count}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.7, generator: (i) {
      final angle = -pi / 2 + (_random.nextDouble() - 0.5) * pi / 4; final speed = 120 + _random.nextDouble() * 70;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 320), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress * 0.2).clamp(0.0, 1.0);
        canvas.save(); canvas.rotate(particle.progress * 3 * pi);
        canvas.drawOval(const Rect.fromLTWH(-3, -2, 6, 4), Paint()..color = Colors.amber.withOpacity(opacity));
        canvas.restore();
      }));
    }));
  }

  ParticleSystemComponent _createHeartEffect({required Vector2 position}) {
    return ParticleSystemComponent(particle: Particle.generate(count: 3, lifespan: 1.0, generator: (i) {
      return AcceleratedParticle(position: position.clone() + Vector2((_random.nextDouble() - 0.5) * 30, -10), speed: Vector2((_random.nextDouble() - 0.5) * 15, -35), acceleration: Vector2(0, -15), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0); final size = 7 * (1.0 - particle.progress * 0.3);
        final path = Path(); path.moveTo(0, size * 0.3); path.cubicTo(-size, -size * 0.3, -size * 0.5, -size, 0, -size * 0.5); path.cubicTo(size * 0.5, -size, size, -size * 0.3, 0, size * 0.3);
        canvas.drawPath(path, Paint()..color = Colors.pink.withOpacity(opacity));
      }));
    }));
  }
}

class _QualityText extends TextComponent {
  _QualityText({required Vector2 position, required String quality}) : super(text: quality.toUpperCase() + '!', position: position + Vector2(0, -40), anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: quality == 'masterpiece' ? 26 : 22, fontWeight: FontWeight.bold, color: quality == 'masterpiece' ? Colors.amber : Colors.purple, shadows: [Shadow(color: quality == 'masterpiece' ? Colors.orange : Colors.purple, blurRadius: 10)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.5); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.3, curve: Curves.elasticOut))); add(MoveByEffect(Vector2(0, -20), EffectController(duration: 1.2, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 1.2, startDelay: 0.5))); add(RemoveEffect(delay: 1.7)); }
}

class _RecipeText extends TextComponent {
  _RecipeText({required Vector2 position}) : super(text: 'NEW RECIPE!', position: position + Vector2(0, -40), anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber, shadows: [Shadow(color: Colors.orange, blurRadius: 10)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.5); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.3, curve: Curves.elasticOut))); add(MoveByEffect(Vector2(0, -15), EffectController(duration: 1.0, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 1.0, startDelay: 0.5))); add(RemoveEffect(delay: 1.5)); }
}

class _UpgradeText extends TextComponent {
  _UpgradeText({required Vector2 position}) : super(text: 'UPGRADE!', position: position + Vector2(0, -40), anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green, shadows: [Shadow(color: Colors.green, blurRadius: 10)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.5); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.3, curve: Curves.elasticOut))); add(MoveByEffect(Vector2(0, -20), EffectController(duration: 1.0, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 1.0, startDelay: 0.5))); add(RemoveEffect(delay: 1.5)); }
}

class _NumberPopup extends TextComponent {
  _NumberPopup({required Vector2 position, required String text, required Color color}) : super(text: text, position: position, anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))])));
  @override Future<void> onLoad() async { await super.onLoad(); add(MoveByEffect(Vector2(0, -25), EffectController(duration: 0.6, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 0.6, startDelay: 0.2))); add(RemoveEffect(delay: 0.8)); }
}
