import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// Keyboard shortcuts handler - UI only
class KeyboardShortcuts extends StatefulWidget {
  final Widget child;
  final VoidCallback? onAddBill;
  final VoidCallback? onAddPayment;
  final VoidCallback? onSearch;

  const KeyboardShortcuts({
    super.key,
    required this.child,
    this.onAddBill,
    this.onAddPayment,
    this.onSearch,
  });

  @override
  State<KeyboardShortcuts> createState() => _KeyboardShortcutsState();
}

class _KeyboardShortcutsState extends State<KeyboardShortcuts> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;

    if (isCtrlPressed) {
      // Ctrl+N - Add Bill
      if (event.logicalKey == LogicalKeyboardKey.keyN &&
          widget.onAddBill != null) {
        widget.onAddBill!();
        return KeyEventResult.handled;
      }
      // Ctrl+P - Add Payment
      if (event.logicalKey == LogicalKeyboardKey.keyP &&
          widget.onAddPayment != null) {
        widget.onAddPayment!();
        return KeyEventResult.handled;
      }
      // Ctrl+F - Search
      if (event.logicalKey == LogicalKeyboardKey.keyF &&
          widget.onSearch != null) {
        widget.onSearch!();
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}
