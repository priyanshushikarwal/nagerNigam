import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/tender.dart';
import '../state/firm_providers.dart';
import '../state/tender_providers.dart';
import '../state/client_firm_providers.dart';
import '../state/database_providers.dart';
import 'add_tn_dialog.dart';

class TnDashboardScreen extends ConsumerStatefulWidget {
  const TnDashboardScreen({super.key});

  @override
  ConsumerState<TnDashboardScreen> createState() => _TnDashboardScreenState();
}

class _TnDashboardScreenState extends ConsumerState<TnDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedClientFirmId;
  Set<int>? _filteredTenderIdsByClient;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddTnDialog(int firmId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddTnDialog(firmId: firmId),
    );

    if (result == true && mounted) {
      ref.invalidate(firmTendersProvider);
      displayInfoBar(
        context,
        builder:
            (context, close) => const InfoBar(
              title: Text('TN Added'),
              content: Text('The TN has been created successfully.'),
              severity: InfoBarSeverity.success,
            ),
      );
    }
  }

  Future<void> _updateClientFilter() async {
    if (_selectedClientFirmId == null) {
      setState(() => _filteredTenderIdsByClient = null);
      return;
    }

    final firm = ref.read(selectedFirmProvider);
    if (firm == null || firm.id == null) return;

    final billsDao = ref.read(billsDaoProvider);
    try {
      final allBills = await billsDao.getBillsByFirm(firm.id!);
      if (!mounted) return;

      final tenderIds =
          allBills
              .where((b) => b.clientFirmId == _selectedClientFirmId)
              .map((b) => b.tenderId)
              .whereType<int>()
              .toSet();

      setState(() {
        _filteredTenderIdsByClient = tenderIds;
      });
    } catch (e) {
      debugPrint('Error filtering tenders: $e');
    }
  }

  List<Tender> _filterTenders(List<Tender> tenders) {
    var result = tenders;

    // Apply Client Filter
    if (_selectedClientFirmId != null && _filteredTenderIdsByClient != null) {
      result =
          result
              .where((t) => _filteredTenderIdsByClient!.contains(t.id))
              .toList();
    }

    if (_searchQuery.isEmpty) {
      return result;
    }

    final query = _searchQuery.toLowerCase();
    return result.where((tender) {
      final tnMatches = tender.tnNumber.toLowerCase().contains(query);
      final poMatches = tender.poNumber?.toLowerCase().contains(query) ?? false;
      final descriptionMatches =
          tender.workDescription?.toLowerCase().contains(query) ?? false;
      return tnMatches || poMatches || descriptionMatches;
    }).toList();
  }

  void _navigateToBills(Tender tender) {
    if (tender.id == null) return;
    context.push('/tenders/${tender.id}/bills', extra: tender);
  }

  @override
  Widget build(BuildContext context) {
    final firm = ref.watch(selectedFirmProvider);
    if (firm == null || firm.id == null) {
      return const ScaffoldPage(
        content: Center(
          child: Text('Please select a DISCOM to view TN dashboard.'),
        ),
      );
    }

    final tendersAsync = ref.watch(firmTendersProvider);

    return ScaffoldPage.scrollable(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      header: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24),
              child: Row(
                children: [
                  Text(
                    'TN Dashboard',
                    style: FluentTheme.of(context).typography.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '|',
                    style: FluentTheme.of(
                      context,
                    ).typography.titleLarge?.copyWith(color: Colors.grey[100]),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Firm: ${firm.name}',
                    style: FluentTheme.of(context).typography.body?.copyWith(
                      color: Colors.grey[120],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => _openAddTnDialog(firm.id!),
                    child: const Text('Add TN'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search Bar & Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[60]),
                        ),
                        child: TextBox(
                          controller: _searchController,
                          placeholder:
                              'Search TN by number, PO or description...',
                          onChanged:
                              (value) => setState(() => _searchQuery = value),
                          style: const TextStyle(fontSize: 14),
                          suffix: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: IconButton(
                              icon: Icon(
                                FluentIcons.clear,
                                size: 14,
                                color: Colors.grey[120],
                              ),
                              onPressed: () {
                                if (_searchQuery.isEmpty) return;
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 250,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final clientFirmsAsync = ref.watch(
                            clientFirmsProvider,
                          );
                          return clientFirmsAsync.when(
                            data: (firms) {
                              return ComboBox<int?>(
                                value: _selectedClientFirmId,
                                isExpanded: true,
                                placeholder: const Text('All Client Firms'),
                                items: [
                                  const ComboBoxItem<int?>(
                                    value: null,
                                    child: Text('All Client Firms'),
                                  ),
                                  ...firms
                                      .where((f) => f.id != null)
                                      .map(
                                        (firm) => ComboBoxItem<int?>(
                                          value: firm.id,
                                          child: Text(firm.firmName),
                                        ),
                                      ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedClientFirmId = value;
                                  });
                                  _updateClientFilter();
                                },
                              );
                            },
                            loading: () => const ProgressRing(),
                            error:
                                (err, stack) =>
                                    const Text('Error loading firms'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      children: [
        tendersAsync.when(
          data: (tenders) {
            final filtered = _filterTenders(tenders);
            if (filtered.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(
                        FluentIcons.document_management,
                        size: 64,
                        color: Colors.grey[100],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No TN found',
                        style: FluentTheme.of(context).typography.subtitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start by adding your first TN.',
                        style: FluentTheme.of(
                          context,
                        ).typography.body?.copyWith(color: Colors.grey[120]),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children:
                  filtered
                      .map(
                        (tender) => TenderCard(
                          key: ValueKey(tender.id),
                          tender: tender,
                          onViewBills: () => _navigateToBills(tender),
                        ),
                      )
                      .toList(),
            );
          },
          loading: () => const Center(child: ProgressRing()),
          error:
              (error, _) => Center(
                child: InfoBar(
                  title: const Text('Failed to load TN list'),
                  content: Text('$error'),
                  severity: InfoBarSeverity.error,
                ),
              ),
        ),
      ],
    );
  }
}

// ============================================================================
// TenderCard Component - Reusable Modern Card Widget
// ============================================================================

class TenderCard extends ConsumerStatefulWidget {
  final Tender tender;
  final VoidCallback onViewBills;

  const TenderCard({
    super.key,
    required this.tender,
    required this.onViewBills,
  });

  @override
  ConsumerState<TenderCard> createState() => _TenderCardState();
}

class _TenderCardState extends ConsumerState<TenderCard> {
  bool _isHovered = false;

  Widget _buildStatusChip({
    required String label,
    required int value,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor.withValues(alpha: 0.7),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tender.id == null) {
      return const SizedBox.shrink();
    }

    final statsAsync = ref.watch(tenderStatsProvider(widget.tender.id!));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onViewBills,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.04),
                blurRadius: _isHovered ? 20 : 12,
                offset: Offset(0, _isHovered ? 6 : 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: TN Info + View Bills Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // TN Number
                          Text(
                            'TN ${widget.tender.tnNumber}',
                            style: FluentTheme.of(
                              context,
                            ).typography.subtitle?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // PO Number
                          if (widget.tender.poNumber != null &&
                              widget.tender.poNumber!.isNotEmpty)
                            Text(
                              'PO: ${widget.tender.poNumber}',
                              style: FluentTheme.of(
                                context,
                              ).typography.caption?.copyWith(
                                color: Colors.grey[130],
                                fontSize: 13,
                              ),
                            ),
                          // Work Description
                          if (widget.tender.workDescription != null &&
                              widget.tender.workDescription!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              widget.tender.workDescription!,
                              style: FluentTheme.of(
                                context,
                              ).typography.body?.copyWith(
                                color: Colors.grey[120],
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // View Bills Button
                    SizedBox(
                      width: 120,
                      child: FilledButton(
                        onPressed: widget.onViewBills,
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.black),
                          foregroundColor: WidgetStatePropertyAll(Colors.white),
                          padding: WidgetStatePropertyAll(
                            const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                        child: const Text(
                          'View Bills',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Status Row
                statsAsync.when(
                  data: (stats) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatusChip(
                          label: 'Total',
                          value: stats.totalBills,
                          backgroundColor: const Color(0xFFE5F0FF),
                          textColor: const Color(0xFF0066CC),
                        ),
                        _buildStatusChip(
                          label: 'Paid',
                          value: stats.paidBills,
                          backgroundColor: const Color(0xFFE5F9EF),
                          textColor: const Color(0xFF1C7A33),
                        ),
                        _buildStatusChip(
                          label: 'Partially Paid',
                          value: stats.partiallyPaidBills,
                          backgroundColor: const Color(0xFFFFF8E1),
                          textColor: const Color(0xFFFF8F00),
                        ),
                        _buildStatusChip(
                          label: 'Pending',
                          value: stats.pendingBills,
                          backgroundColor: const Color(0xFFFFF4E5),
                          textColor: const Color(0xFFCC6600),
                        ),
                        _buildStatusChip(
                          label: 'Overdue',
                          value: stats.overdueBills,
                          backgroundColor: const Color(0xFFFFEAE8),
                          textColor: const Color(0xFFB3261E),
                        ),
                        _buildStatusChip(
                          label: 'Due Soon',
                          value: stats.dueSoonBills,
                          backgroundColor: const Color(0xFFE9FAF7),
                          textColor: const Color(0xFF008B7A),
                        ),
                      ],
                    );
                  },
                  loading:
                      () => const SizedBox(
                        height: 32,
                        child: Center(child: ProgressRing()),
                      ),
                  error:
                      (error, _) => Text(
                        'Failed to load stats',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
