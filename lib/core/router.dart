import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/login_screen.dart';
import '../screens/discom_selection_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/bills_screen.dart';
import '../screens/main_layout.dart';
import '../services/auth_service.dart';
import '../models/tender.dart';
import '../screens/tn_dashboard_screen.dart';
import '../screens/bill_list_screen.dart';
import '../screens/bill_details_screen.dart';
import '../screens/backup_screen.dart';
import '../screens/payments_screen.dart';
import '../features/client_firms/client_firm_management_screen.dart';
import '../state/firm_providers.dart';
import '../screens/settings_screen.dart';
import '../screens/stress_test_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// Router provider that watches auth state
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final selectedFirm = ref.watch(selectedFirmProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final hasSelectedFirm = selectedFirm != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSelectingDiscom = state.matchedLocation == '/discom-selection';

      // Not authenticated and not on login page
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // Authenticated but no firm selected and not on selection page
      if (isAuthenticated && !hasSelectedFirm && !isSelectingDiscom) {
        return '/discom-selection';
      }

      // Authenticated with firm but trying to access login/selection pages
      if (isAuthenticated &&
          hasSelectedFirm &&
          (isLoggingIn || isSelectingDiscom)) {
        return '/dashboard';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/discom-selection',
        builder: (context, state) => const DiscomSelectionScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/bills',
            builder: (context, state) => const BillsScreen(),
          ),
          GoRoute(
            path: '/payments',
            builder: (context, state) => const PaymentsScreen(),
          ),
          GoRoute(
            path: '/backup',
            builder: (context, state) => const BackupScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/client-firms',
            builder: (context, state) => const ClientFirmManagementScreen(),
          ),
          GoRoute(
            path: '/tenders',
            builder: (context, state) => const TnDashboardScreen(),
          ),
          GoRoute(
            path: '/tenders/:tenderId/bills',
            builder: (context, state) {
              final tenderId = int.parse(state.pathParameters['tenderId']!);
              final tender =
                  state.extra is Tender ? state.extra as Tender : null;
              return BillListScreen(tenderId: tenderId, tender: tender);
            },
          ),
          GoRoute(
            path: '/bills/:billId',
            builder: (context, state) {
              final billId = int.parse(state.pathParameters['billId']!);
              return BillDetailsScreen(billId: billId);
            },
          ),
          GoRoute(
            path: '/stress-test',
            builder: (context, state) => const StressTestScreen(),
          ),
        ],
      ),
    ],
  );
});
