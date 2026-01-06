import 'package:fluent_ui/fluent_ui.dart';

/// Sticky action header for bills and TN pages - UI only
class StickyActionHeader extends StatelessWidget {
  final String title;
  final List<ActionButton> actions;

  const StickyActionHeader({
    super.key,
    required this.title,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[40], width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          Row(
            children:
                actions.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilledButton(
                      onPressed: action.onPressed,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(action.icon, size: 16),
                          const SizedBox(width: 8),
                          Text(action.label),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class ActionButton {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
}
