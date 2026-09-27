import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:flutter/material.dart';

/// One-time hint bubble pointing down at a control (Flow A: the add
/// button). Same inverse colors as the snackbar so it reads as system UI.
class CoachMark extends StatelessWidget {
  const CoachMark({
    required this.message,
    required this.dismissLabel,
    required this.onDismiss,
    super.key,
  });

  final String message;
  final String dismissLabel;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    return Semantics(
      liveRegion: true,
      container: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.coachMarkMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.inverseSurface,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.md),
                ),
                boxShadow: tokens.floatingShadow,
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppSpacing.space4,
                  end: AppSpacing.space1,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.space3,
                        ),
                        child: Text(
                          message,
                          style: AppTextStyles.body.copyWith(
                            color: colors.onInverseSurface,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onDismiss,
                      style: TextButton.styleFrom(
                        foregroundColor: colors.inversePrimary,
                        minimumSize: const Size(
                          AppSizes.minTouchTarget,
                          AppSizes.minTouchTarget,
                        ),
                        textStyle: AppTextStyles.label,
                      ),
                      child: Text(dismissLabel),
                    ),
                  ],
                ),
              ),
            ),
            ExcludeSemantics(
              child: CustomPaint(
                size: const Size(
                  AppSizes.coachMarkPointer * 2,
                  AppSizes.coachMarkPointer,
                ),
                painter: _PointerPainter(colors.inverseSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  const _PointerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PointerPainter oldDelegate) => oldDelegate.color != color;
}
