import 'dart:async';
import 'dart:developer' as developer;

import 'package:compound_me/core/design/components/empty_state.dart';
import 'package:compound_me/core/design/icons.dart';
import 'package:compound_me/core/design/theme.dart';
import 'package:compound_me/core/design/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder block with a soft shimmer (§7.6), static when the device
/// asks for reduced motion.
class Skeleton extends StatefulWidget {
  const Skeleton({this.height = AppSizes.skeletonLine, this.width, super.key});

  final double height;
  final double? width;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.shimmer,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return FadeTransition(
      opacity: Tween<double>(
        begin: AppOpacity.skeletonLow,
        end: 1,
      ).animate(_controller),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
        ),
      ),
    );
  }
}

/// Skeleton rows shaped like a list of tiles.
class SkeletonList extends StatelessWidget {
  const SkeletonList({this.rows = 4, super.key});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          children: [
            for (var i = 0; i < rows; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.space2),
              const Skeleton(height: AppSizes.row),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state (§7.6): like [EmptyState] with a warning icon and a retry.
/// Technical details stay in the log.
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => EmptyState(
    icon: AppIcons.warningCircle,
    title: title,
    message: message,
    actionLabel: retryLabel,
    onAction: onRetry,
  );
}

/// Labels for the error state of [AsyncBody].
typedef AsyncErrorLabels = ({String title, String message, String retry});

/// Renders an [AsyncValue]: data, a skeleton that only appears after
/// [AppDurations.skeletonDelay] (03 §4), or an error with a retry.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({
    required this.value,
    required this.data,
    required this.errorLabels,
    required this.onRetry,
    this.loading = const SkeletonList(),
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final AsyncErrorLabels errorLabels;
  final VoidCallback onRetry;
  final Widget loading;

  @override
  Widget build(BuildContext context) => switch (value) {
    AsyncData(:final value) => data(value),
    AsyncError(:final error, :final stackTrace) => _LoggedError(
      error: error,
      stackTrace: stackTrace,
      child: ErrorState(
        title: errorLabels.title,
        message: errorLabels.message,
        retryLabel: errorLabels.retry,
        onRetry: onRetry,
      ),
    ),
    _ => DelayedReveal(child: loading),
  };
}

/// Shows [child] only once [delay] has passed, so fast loads never flash
/// a skeleton.
class DelayedReveal extends StatefulWidget {
  const DelayedReveal({
    required this.child,
    this.delay = AppDurations.skeletonDelay,
    super.key,
  });

  final Widget child;
  final Duration delay;

  @override
  State<DelayedReveal> createState() => _DelayedRevealState();
}

class _DelayedRevealState extends State<DelayedReveal> {
  late final Timer _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _visible ? widget.child : const SizedBox.shrink();
}

class _LoggedError extends StatefulWidget {
  const _LoggedError({
    required this.error,
    required this.stackTrace,
    required this.child,
  });

  final Object error;
  final StackTrace stackTrace;
  final Widget child;

  @override
  State<_LoggedError> createState() => _LoggedErrorState();
}

class _LoggedErrorState extends State<_LoggedError> {
  @override
  void initState() {
    super.initState();
    // Users see a friendly message; the details go to the log only.
    developer.log(
      'Failed to load data',
      name: 'compound_me',
      error: widget.error,
      stackTrace: widget.stackTrace,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
