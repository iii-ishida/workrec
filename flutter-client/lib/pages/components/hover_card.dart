import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class HoverCardController {
  final _animationDisabledNotifier = ValueNotifier<bool>(false);
}

class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final HoverCardController? controller;

  const HoverCard({
    Key? key,
    required this.child,
    required this.onTap,
    this.controller,
  }) : super(key: key);

  @override
  State createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    final curve = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animation = Tween<double>(begin: 1.0, end: 0.95).animate(curve);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller ?? HoverCardController();

    return ValueListenableBuilder<bool>(
      valueListenable: controller._animationDisabledNotifier,
      builder: (
        context,
        animationDisabled,
        child,
      ) {
        _animationController.reset();

        return GestureDetector(
          onTap: () async {
            await _animationController.forward();
            widget.onTap();
            await _animationController.reverse();
          },
          child: Listener(
            onPointerDown: (_) {
              if (!animationDisabled) {
                _animationController.forward();
              }
            },
            onPointerUp: (_) => _animationController.reverse(),
            onPointerCancel: (_) => _animationController.reverse(),
            child: ScaleTransition(
              scale: _animation,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class HoverCardAnimationDisable extends StatelessWidget {
  final Widget child;
  final HoverCardController controller;

  const HoverCardAnimationDisable({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifier = controller._animationDisabledNotifier;

    return Listener(
      onPointerDown: (_) => notifier.value = true,
      onPointerUp: (_) => notifier.value = false,
      onPointerCancel: (_) => notifier.value = false,
      child: child,
    );
  }
}
