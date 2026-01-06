import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';

/// Breadcrumb navigation widget - UI only, no backend changes
class AppBreadcrumbs extends StatelessWidget {
  final List<AppBreadcrumbItem> items;

  const AppBreadcrumbs({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border(bottom: BorderSide(color: Colors.grey[40], width: 1)),
      ),
      child: Row(
        children: [
          Icon(FluentIcons.home, size: 14, color: Colors.grey[100]),
          const SizedBox(width: 8),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index > 0) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      FluentIcons.chevron_right,
                      size: 12,
                      color: Colors.grey[80],
                    ),
                  ),
                ],
                if (isLast)
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                  )
                else
                  HyperlinkButton(
                    onPressed: () {
                      if (item.route != null) {
                        context.go(item.route!);
                      }
                    },
                    child: Text(
                      item.label,
                      style: TextStyle(fontSize: 13, color: Colors.grey[100]),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class AppBreadcrumbItem {
  final String label;
  final String? route;

  AppBreadcrumbItem({required this.label, this.route});
}
