import 'package:flutter/material.dart';
import 'package:mg_common_game/core/ui/mg_ui.dart';

/// MG UI 기반 던전 크래프트 HUD
/// mg_common_game의 공통 UI 컴포넌트 활용
class MGDungeonCraftHud extends StatelessWidget {
  final int gold;
  final int mana;
  final int invasionProgress;
  final int maxInvasionProgress;
  final VoidCallback? onPause;
  final VoidCallback? onMenu;

  const MGDungeonCraftHud({
    super.key,
    required this.gold,
    this.mana = 0,
    this.invasionProgress = 0,
    this.maxInvasionProgress = 100,
    this.onPause,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding;

    return Positioned.fill(
      child: Column(
        children: [
          // 상단 HUD: 자원 + 일시정지
          Container(
            padding: EdgeInsets.only(
              top: safeArea.top + MGSpacing.hudMargin,
              left: safeArea.left + MGSpacing.hudMargin,
              right: safeArea.right + MGSpacing.hudMargin,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 일시정지 버튼
                if (onPause != null)
                  MGIconButton(
                    icon: Icons.pause,
                    onPressed: onPause,
                    buttonSize: MGIconButtonSize.medium,
                    backgroundColor: MGColors.surface.withAlpha(0xCC),
                    color: Colors.white,
                  )
                else
                  const SizedBox(width: 44),

                // 자원 표시
                Row(
                  children: [
                    // 골드
                    MGResourceBar(
                      icon: Icons.monetization_on,
                      value: _formatNumber(gold),
                      iconColor: MGColors.gold,
                    ),
                    MGSpacing.hMd,

                    // 마나
                    MGResourceBar(
                      icon: Icons.auto_awesome,
                      value: _formatNumber(mana),
                      iconColor: Colors.lightBlueAccent,
                    ),
                  ],
                ),

                // 메뉴 버튼
                if (onMenu != null)
                  MGIconButton(
                    icon: Icons.menu,
                    onPressed: onMenu,
                    buttonSize: MGIconButtonSize.medium,
                    backgroundColor: MGColors.surface.withAlpha(0xCC),
                    color: Colors.white,
                  )
                else
                  const SizedBox(width: 44),
              ],
            ),
          ),

          // 중앙 공백 (게임 화면 영역)
          const Expanded(child: SizedBox()),

          // 하단: 침략 진행도
          Container(
            padding: EdgeInsets.only(
              bottom: safeArea.bottom + MGSpacing.hudMargin,
              left: safeArea.left + MGSpacing.hudMargin,
              right: safeArea.right + MGSpacing.hudMargin,
            ),
            child: Column(
              children: [
                // 침략 진행도 바
                Row(
                  children: [
                    Icon(
                      Icons.shield,
                      color: _getProgressColor(),
                      size: 24,
                    ),
                    MGSpacing.hSm,
                    Expanded(
                      child: MGLinearProgress(
                        value: invasionProgress / maxInvasionProgress,
                        height: 12,
                        valueColor: _getProgressColor(),
                        backgroundColor: _getProgressColor().withAlpha(0x4D),
                        borderRadius: 6,
                      ),
                    ),
                    MGSpacing.hSm,
                    Text(
                      '$invasionProgress/$maxInvasionProgress',
                      style: MGTextStyles.hudSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 침략 진행도에 따른 색상
  Color _getProgressColor() {
    final percentage = invasionProgress / maxInvasionProgress;
    if (percentage >= 0.8) {
      return MGColors.error; // 위험 (80% 이상)
    } else if (percentage >= 0.5) {
      return MGColors.warning; // 경고 (50% 이상)
    } else {
      return MGColors.success; // 안전
    }
  }

  /// 숫자 포맷팅
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
