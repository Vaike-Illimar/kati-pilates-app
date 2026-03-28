import 'package:flutter/material.dart';
import 'package:kati_pilates/config/theme.dart';

/// Animated booking confirmation overlay.
/// Shows a checkmark animation when booking is confirmed.
class BookingConfirmationAnimation extends StatefulWidget {
  final VoidCallback? onComplete;

  const BookingConfirmationAnimation({super.key, this.onComplete});

  @override
  State<BookingConfirmationAnimation> createState() =>
      _BookingConfirmationAnimationState();
}

class _BookingConfirmationAnimationState
    extends State<BookingConfirmationAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _checkController;
  late final AnimationController _fadeController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _checkAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOut,
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _runAnimation();
  }

  Future<void> _runAnimation() async {
    await _scaleController.forward();
    await _checkController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _fadeController.forward();
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: ScaleTransition(
              scale: _checkAnimation,
              child: const Icon(
                Icons.check_circle_rounded,
                size: 56,
                color: AppColors.success,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay widget that shows a booking confirmation animation.
/// Call [BookingAnimationOverlay.show] to display it.
class BookingAnimationOverlay {
  static Future<void> show(BuildContext context) async {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: BookingConfirmationAnimation(
              onComplete: () => entry.remove(),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    // Safety cleanup after 3 seconds
    await Future<void>.delayed(const Duration(seconds: 3));
    if (entry.mounted) entry.remove();
  }
}

/// Page route with fade transition instead of default slide.
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 200),
        );
}

/// Slide-up transition for bottom sheets and confirmation screens.
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}
