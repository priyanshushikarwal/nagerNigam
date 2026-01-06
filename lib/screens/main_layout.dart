import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../state/firm_providers.dart';
import '../widgets/widgets.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    await ref.read(authProvider.notifier).logout();
    await ref.read(selectedFirmProvider.notifier).setFirm(null);
    if (mounted) {
      context.go('/login');
    }
  }

  Future<void> _changeDISCOM() async {
    await ref.read(selectedFirmProvider.notifier).setFirm(null);
    context.go('/discom-selection');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final selectedFirm = ref.watch(selectedFirmProvider);
    final currentRoute = GoRouterState.of(context).uri.toString();

    return KeyboardShortcuts(
      onAddBill: () {
        // Navigate to add bill - for now go to bills screen
        context.go('/bills');
      },
      onAddPayment: () {
        // Navigate to add payment - for now go to payments screen
        context.go('/payments');
      },
      onSearch: () => _searchFocusNode.requestFocus(),
      child: OnboardingWalkthrough(
        child: Container(
          color: const Color.fromARGB(255, 224, 30, 30),
          child: Row(
            children: [
              // Collapsible Sidebar
              CollapsibleSidebar(currentRoute: currentRoute),

              // Main content area
              Expanded(
                child: Column(
                  children: [
                    // Top bar with search
                    Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            // Search bar
                            Flexible(
                              flex: 2,
                              child: GlobalSearchBar(
                                focusNode: _searchFocusNode,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Selected Firm badge
                            if (selectedFirm != null) ...[
                              GestureDetector(
                                onTap: () {
                                  // Make firm info clickable too
                                  _changeDISCOM();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: FluentTheme.of(
                                      context,
                                    ).accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        FluentIcons.org,
                                        size: 14,
                                        color:
                                            FluentTheme.of(context).accentColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        selectedFirm.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color:
                                              FluentTheme.of(
                                                context,
                                              ).accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 32,
                                child: Button(
                                  onPressed: _changeDISCOM,
                                  style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                      const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Change',
                                      style: TextStyle(fontSize: 13),

                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(width: 8),

                            // User info
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[20],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(FluentIcons.contact, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    authState.username ?? 'User',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  if (authState.isAdmin) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: const Text(
                                        'ADMIN',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Logout button
                            IconButton(
                              icon: const Icon(FluentIcons.sign_out),
                              onPressed: _handleLogout,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Main content with child
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
