import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Collapsible sidebar state provider
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);

/// Collapsible sidebar navigation with active state highlighting
class CollapsibleSidebar extends ConsumerWidget {
  final String currentRoute;

  const CollapsibleSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCollapsed = ref.watch(sidebarCollapsedProvider);
    final width = isCollapsed ? 60.0 : 240.0;

    final navItems = [
      _NavItem(icon: FluentIcons.home, label: 'Dashboard', route: '/dashboard'),
      _NavItem(
        icon: FluentIcons.completed_solid,
        label: 'Tenders (TN)',
        route: '/tenders',
      ),
      _NavItem(icon: FluentIcons.document, label: 'Bills', route: '/bills'),
      _NavItem(icon: FluentIcons.money, label: 'Payments', route: '/payments'),
      _NavItem(
        icon: FluentIcons.company_directory,
        label: 'Client Firms',
        route: '/client-firms',
      ),
      _NavItem(icon: FluentIcons.save, label: 'Backup', route: '/backup'),
      _NavItem(
        icon: FluentIcons.settings,
        label: 'Settings',
        route: '/settings',
      ),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with collapse toggle
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[40])),
            ),
            child: Row(
              mainAxisAlignment:
                  isCollapsed
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceBetween,
              children: [
                if (!isCollapsed) ...[
                  const Expanded(
                    child: Text(
                      'DISCOM Manager',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                IconButton(
                  icon: Icon(
                    isCollapsed
                        ? FluentIcons.double_chevron_right
                        : FluentIcons.double_chevron_left,
                    color: Colors.black,
                    size: 16,
                  ),
                  onPressed: () {
                    ref.read(sidebarCollapsedProvider.notifier).state =
                        !isCollapsed;
                  },
                ),
              ],
            ),
          ),

          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isActive = currentRoute.startsWith(item.route);

                return _SidebarNavItem(
                  item: item,
                  isActive: isActive,
                  isCollapsed: isCollapsed,
                  onTap: () => context.go(item.route),
                );
              },
            ),
          ),

          // Footer
          if (!isCollapsed)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[40])),
              ),
              child: FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.data?.version ?? '1.0.0';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Version $version',
                        style: TextStyle(color: Colors.grey[120], fontSize: 12),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  _NavItem({required this.icon, required this.label, required this.route});
}

class _SidebarNavItem extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.item,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        widget.isActive
            ? const Color(0xFF2563EB)
            : _isHovered
            ? Colors.grey[20]
            : Colors.transparent;

    final iconColor = widget.isActive ? Colors.white : Colors.black;
    final textColor = widget.isActive ? Colors.white : Colors.black;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isCollapsed ? 4 : 8,
        vertical: 2,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isCollapsed ? 12 : 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border:
                  widget.isActive
                      ? Border(
                        left: BorderSide(
                          color: const Color(0xFF2563EB),
                          width: 3,
                        ),
                      )
                      : null,
            ),
            child: Row(
              mainAxisAlignment:
                  widget.isCollapsed
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
              children: [
                Icon(widget.item.icon, color: iconColor, size: 18),
                if (!widget.isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight:
                            widget.isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
