import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/bill.dart';
import '../services/database_service.dart';
import '../state/firm_providers.dart';

class DiscomSelectionScreen extends ConsumerStatefulWidget {
  const DiscomSelectionScreen({super.key});

  @override
  ConsumerState<DiscomSelectionScreen> createState() =>
      _DiscomSelectionScreenState();
}

class _DiscomSelectionScreenState extends ConsumerState<DiscomSelectionScreen> {
  final DatabaseService _db = DatabaseService.instance;
  List<Firm> _firms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFirms();
  }

  Future<void> _loadFirms() async {
    try {
      final db = await _db.database;
      final firmsData = await db.query('firms', orderBy: 'name ASC');
      setState(() {
        _firms = firmsData.map((e) => Firm.fromMap(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectFirm(Firm firm) async {
    await ref.read(selectedFirmProvider.notifier).setFirm(firm);
    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Icon(
                FluentIcons.org,
                size: 64,
                color: FluentTheme.of(context).accentColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Select DISCOM',
                style: FluentTheme.of(context).typography.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the power distribution company to manage',
                style: FluentTheme.of(context).typography.caption,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Loading or firms list
              if (_isLoading)
                const Center(child: ProgressRing())
              else
                ..._firms.map(
                  (firm) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        title: Text(
                          firm.name,
                          style: FluentTheme.of(context).typography.bodyLarge,
                        ),
                        subtitle: Text(
                          firm.description ?? firm.code,
                          style: FluentTheme.of(context).typography.caption,
                        ),
                        trailing: FilledButton(
                          onPressed: () => _selectFirm(firm),
                          child: const Text('Select'),
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Back button
              Button(
                onPressed: () => context.go('/login'),
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
