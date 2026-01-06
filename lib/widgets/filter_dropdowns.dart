import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Filter dropdown components for Client Firm and DISCOM filtering
/// Uses existing providers - NO backend changes

// State providers for current filter selections
final selectedClientFirmFilterProvider = StateProvider<int?>((ref) => null);
final selectedDiscomFilterProvider = StateProvider<String?>((ref) => null);

class ClientFirmFilterDropdown extends ConsumerWidget {
  final List<ClientFirmOption> clientFirms;
  final String? label;

  const ClientFirmFilterDropdown({
    super.key,
    required this.clientFirms,
    this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedClientFirmFilterProvider);

    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
          ],
          ComboBox<int?>(
            value: selectedId,
            items: [
              const ComboBoxItem<int?>(
                value: null,
                child: Text('All Client Firms'),
              ),
              ...clientFirms.map(
                (firm) =>
                    ComboBoxItem<int?>(value: firm.id, child: Text(firm.name)),
              ),
            ],
            onChanged: (value) {
              ref.read(selectedClientFirmFilterProvider.notifier).state = value;
            },
            placeholder: const Text(' Filter by Client Firm'),
          ),
        ],
      ),
    );
  }
}

class DiscomFilterDropdown extends ConsumerWidget {
  final List<String> discoms;
  final String? label;

  const DiscomFilterDropdown({super.key, required this.discoms, this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDiscom = ref.watch(selectedDiscomFilterProvider);

    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
          ],
          ComboBox<String?>(
            value: selectedDiscom,
            items: [
              const ComboBoxItem<String?>(
                value: null,
                child: Text('All DISCOMs'),
              ),
              ...discoms.map(
                (discom) =>
                    ComboBoxItem<String?>(value: discom, child: Text(discom)),
              ),
            ],
            onChanged: (value) {
              ref.read(selectedDiscomFilterProvider.notifier).state = value;
            },
            placeholder: const Text('Filter by DISCOM'),
          ),
        ],
      ),
    );
  }
}

/// Helper class for client firm options
class ClientFirmOption {
  final int id;
  final String name;

  ClientFirmOption({required this.id, required this.name});
}

/// Combined filter bar with both dropdowns side-by-side
class FilterBar extends StatelessWidget {
  final List<ClientFirmOption> clientFirms;
  final List<String> discoms;

  const FilterBar({
    super.key,
    required this.clientFirms,
    required this.discoms,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[40])),
      ),
      child: Row(
        children: [
          const Icon(FluentIcons.filter, size: 16),
          const SizedBox(width: 8),
          const Text(
            'Filters:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(width: 16),
          ClientFirmFilterDropdown(clientFirms: clientFirms),
          const SizedBox(width: 12),
          DiscomFilterDropdown(discoms: discoms),
        ],
      ),
    );
  }
}
