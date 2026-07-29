import 'package:flutter/material.dart';
import '../enums/user_status.dart';
import '../theme/app_colors.dart';

/// Small colored circle indicating presence status. When [status] is
/// active, plays a slow breathing animation — the app's signature
/// "Pulse" motif tying the backend heartbeat to something felt at a
/// glance. Respects MediaQuery.disableAnimations for reduced motion.
class StatusDot extends StatefulWidget {
  final UserStatus status;
  final double size;

  const StatusDot({super.key, required this.status, this.size = 10});

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = colors.statusColor(_toNexusStatus(widget.status));
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (!widget.status.isLive || reduceMotion) {
      return _dot(color, opacity: 1, scale: 1);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            _dot(color, opacity: 1.0 - (t * 0.55), scale: 1.0 + (t * 0.35)),
            _dot(color, opacity: 1, scale: 1),
          ],
        );
      },
    );
  }

  NexusStatus _toNexusStatus(UserStatus s) {
    switch (s) {
      case UserStatus.active:
        return NexusStatus.online;
      case UserStatus.busy:
        return NexusStatus.busy;
      case UserStatus.offline:
      case UserStatus.onLeave:
        return NexusStatus.offline;
    }
  }

  Widget _dot(Color color, {required double opacity, required double scale}) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: opacity)),
      ),
    );
  }
}