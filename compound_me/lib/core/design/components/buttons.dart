import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:compound_me/core/design/typography.dart';
import 'package:flutter/material.dart';

/// Main action on a screen or sheet (§7.2). A null [onPressed] disables it.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return _AppButton(
      label: label,
      onPressed: onPressed,
      loading: loading,
      expand: expand,
      height: AppSizes.buttonHeight,
      background: colors.primary,
      pressedBackground: colors.primaryPressed,
      foreground: colors.onPrimary,
    );
  }
}

/// Supporting action on a tonal background (§7.2).
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return _AppButton(
      label: label,
      onPressed: onPressed,
      loading: loading,
      expand: expand,
      height: AppSizes.buttonHeight,
      background: colors.primaryTint,
      pressedBackground: colors.primaryTintPressed,
      foreground: colors.onPrimaryTint,
    );
  }
}

/// Third-level action without a background ("Lewati", "Nanti saja").
class GhostButton extends StatelessWidget {
  const GhostButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return _AppButton(
      label: label,
      onPressed: onPressed,
      loading: loading,
      expand: expand,
      height: AppSizes.minTouchTarget,
      background: colors.primaryTint.withValues(alpha: 0),
      pressedBackground: colors.primaryTint,
      foreground: colors.primary,
    );
  }
}

/// Like [SecondaryButton] in the danger color (§7.2). Only for confirming
/// something that cannot be undone, inside a confirmation sheet.
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return _AppButton(
      label: label,
      onPressed: onPressed,
      loading: loading,
      expand: expand,
      height: AppSizes.buttonHeight,
      background: colors.dangerTint,
      pressedBackground: colors.dangerTintPressed,
      foreground: colors.onDangerTint,
    );
  }
}

/// 40 dp tonal circle with a 20 dp icon and a 48 dp tap area (§7.2).
/// [label] is read by screen readers and shown as a tooltip.
class IconButtonTonal extends StatelessWidget {
  const IconButtonTonal({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        enabled: onPressed != null,
        label: label,
        onTap: onPressed,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onPressed,
          radius: AppSizes.minTouchTarget / 2,
          child: SizedBox.square(
            dimension: AppSizes.minTouchTarget,
            child: Center(
              child: Container(
                width: AppSizes.iconButtonTonal,
                height: AppSizes.iconButtonTonal,
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppSizes.iconSm,
                  color: onPressed == null
                      ? colors.textTertiary
                      : colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppButton extends StatefulWidget {
  const _AppButton({
    required this.label,
    required this.onPressed,
    required this.loading,
    required this.expand,
    required this.height,
    required this.background,
    required this.pressedBackground,
    required this.foreground,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool expand;
  final double height;
  final Color background;
  final Color pressedBackground;
  final Color foreground;

  @override
  State<_AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<_AppButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;
  bool get _interactive => _enabled && !widget.loading;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = AppDurations.resolve(
      AppDurations.fast,
      reduceMotion: reduceMotion,
    );
    const radius = BorderRadius.all(Radius.circular(AppRadius.md));

    final labelStyle = AppTextStyles.label.copyWith(color: widget.foreground);
    final content = widget.loading
        ? SizedBox.square(
            dimension: AppSizes.spinner,
            child: CircularProgressIndicator(
              strokeWidth: AppSizes.spinnerStroke,
              color: widget.foreground,
            ),
          )
        : Text(
            widget.label,
            style: labelStyle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          );

    final button = AnimatedScale(
      scale: _pressed ? AppScale.pressed : 1,
      duration: duration,
      curve: AppDurations.fastCurve,
      child: AnimatedContainer(
        duration: duration,
        curve: AppDurations.fastCurve,
        constraints: BoxConstraints(minHeight: widget.height),
        width: widget.expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space6,
          vertical: AppSpacing.space2,
        ),
        decoration: BoxDecoration(
          color: _pressed ? widget.pressedBackground : widget.background,
          borderRadius: radius,
        ),
        // Container.alignment would stretch to the max size and break
        // expand: false; the factors keep the button hugging its label, and
        // heightFactor stops it filling a loosely constrained slot such as
        // Scaffold.bottomNavigationBar.
        child: Center(widthFactor: 1, heightFactor: 1, child: content),
      ),
    );

    return Semantics(
      button: true,
      enabled: _interactive,
      label: widget.label,
      onTap: _interactive ? widget.onPressed : null,
      excludeSemantics: true,
      child: Opacity(
        opacity: _enabled ? 1 : AppOpacity.disabled,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _interactive ? (_) => _setPressed(true) : null,
          onTapUp: _interactive ? (_) => _setPressed(false) : null,
          onTapCancel: _interactive ? () => _setPressed(false) : null,
          onTap: _interactive ? widget.onPressed : null,
          child: button,
        ),
      ),
    );
  }
}
