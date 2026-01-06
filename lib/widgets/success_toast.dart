import 'package:fluent_ui/fluent_ui.dart';

/// Success toast notification widget
/// Shows temporary success messages without blocking UI
class SuccessToast {
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    IconData icon = FluentIcons.check_mark,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: 80,
            right: 20,
            child: _ToastContent(
              message: message,
              icon: icon,
              onDismiss: () => overlayEntry.remove(),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      duration: duration,
      icon: FluentIcons.error_badge,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message: message, duration: duration, icon: FluentIcons.info);
  }
}

class _ToastContent extends StatefulWidget {
  final String message;
  final IconData icon;
  final VoidCallback onDismiss;

  const _ToastContent({
    required this.message,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_ToastContent> createState() => _ToastContentState();
}

class _ToastContentState extends State<_ToastContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 400),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  FluentIcons.chrome_close,
                  size: 14,
                  color: Colors.white,
                ),
                onPressed: widget.onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Info bar banner for persistent notifications at top of screen
class InfoBanner extends StatelessWidget {
  final String message;
  final InfoBarSeverity severity;
  final VoidCallback? onClose;

  const InfoBanner({
    super.key,
    required this.message,
    this.severity = InfoBarSeverity.info,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return InfoBar(title: Text(message), severity: severity, onClose: onClose);
  }
}
