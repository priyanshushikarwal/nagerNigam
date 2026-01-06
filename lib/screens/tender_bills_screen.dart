import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';

import '../core/premium_theme.dart';
import '../models/tender.dart';
import '../services/tender_service.dart';

class TenderBillsScreen extends StatefulWidget {
  final int tenderId;

  const TenderBillsScreen({super.key, required this.tenderId});

  @override
  State<TenderBillsScreen> createState() => _TenderBillsScreenState();
}

class _TenderBillsScreenState extends State<TenderBillsScreen> {
  final TenderService _tenderService = TenderService();
  Tender? _tender;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTender();
  }

  Future<void> _loadTender() async {
    setState(() => _isLoading = true);
    try {
      final tender = await _tenderService.getTenderById(widget.tenderId);
      if (mounted) {
        setState(() {
          _tender = tender;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        displayInfoBar(
          context,
          builder:
              (context, close) => InfoBar(
                title: const Text('Error'),
                content: Text('Failed to load tender: $e'),
                severity: InfoBarSeverity.error,
              ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final typography = FluentTheme.of(context).typography;

    if (_isLoading) {
      return const ScaffoldPage(content: Center(child: ProgressRing()));
    }

    if (_tender == null) {
      return const ScaffoldPage(
        content: Center(child: Text('Tender not found')),
      );
    }

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(PremiumTheme.spacingL),
            decoration: const BoxDecoration(
              color: PremiumTheme.pureWhite,
              border: Border(
                bottom: BorderSide(color: PremiumTheme.borderColor, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(FluentIcons.back, size: 20),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/tenders');
                        }
                      },
                    ),
                    const SizedBox(width: PremiumTheme.spacingM),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TN: ${_tender!.tnNumber}',
                          style: typography.title,
                        ),
                        const SizedBox(height: PremiumTheme.spacingXS),
                        Text(
                          'PO: ${_tender!.poNumber ?? 'N/A'}',
                          style: typography.body?.copyWith(
                            color: PremiumTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_tender!.workDescription != null) ...[
                  const SizedBox(height: PremiumTheme.spacingM),
                  Text(
                    _tender!.workDescription!,
                    style: typography.body?.copyWith(
                      color: PremiumTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Content - Bills list will go here
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    FluentIcons.document,
                    size: 48,
                    color: PremiumTheme.textSecondary,
                  ),
                  const SizedBox(height: PremiumTheme.spacingM),
                  Text(
                    'Bills list will be shown here',
                    style: typography.subtitle,
                  ),
                  const SizedBox(height: PremiumTheme.spacingS),
                  Text(
                    'Coming soon...',
                    style: typography.body?.copyWith(
                      color: PremiumTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
