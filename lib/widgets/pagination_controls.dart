import 'package:fluent_ui/fluent_ui.dart';

/// Pagination controls for chunking already-loaded data
/// NO database queries - visual pagination only
class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int itemsPerPage;
  final Function(int page) onPageChanged;
  final Function(int itemsPerPage)? onItemsPerPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    this.onItemsPerPageChanged,
  });

  int get totalPages => (totalItems / itemsPerPage).ceil();
  int get startItem =>
      totalItems == 0 ? 0 : (currentPage - 1) * itemsPerPage + 1;
  int get endItem => (currentPage * itemsPerPage).clamp(0, totalItems);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[40])),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Items per page selector
          if (onItemsPerPageChanged != null)
            Row(
              children: [
                const Text('Rows per page:', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: ComboBox<int>(
                    value: itemsPerPage,
                    items: const [
                      ComboBoxItem(value: 10, child: Text('10')),
                      ComboBoxItem(value: 25, child: Text('25')),
                      ComboBoxItem(value: 50, child: Text('50')),
                      ComboBoxItem(value: 100, child: Text('100')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onItemsPerPageChanged!(value);
                      }
                    },
                  ),
                ),
              ],
            )
          else
            const SizedBox(),

          // Page info
          Text(
            '$startItem-$endItem of $totalItems',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),

          // Navigation buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(FluentIcons.chevron_left, size: 16),
                onPressed:
                    currentPage > 1
                        ? () => onPageChanged(currentPage - 1)
                        : null,
              ),
              const SizedBox(width: 4),
              ...List.generate(_getPageNumbers().length, (index) {
                final pageNum = _getPageNumbers()[index];
                if (pageNum == -1) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('...', style: TextStyle(fontSize: 13)),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Button(
                    onPressed: () => onPageChanged(pageNum),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        if (pageNum == currentPage) {
                          return const Color(0xFF2563EB);
                        }
                        return Colors.grey[20];
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((
                        states,
                      ) {
                        if (pageNum == currentPage) {
                          return Colors.white;
                        }
                        return Colors.black;
                      }),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ),
                    child: Text(
                      pageNum.toString(),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(FluentIcons.chevron_right, size: 16),
                onPressed:
                    currentPage < totalPages
                        ? () => onPageChanged(currentPage + 1)
                        : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Get smart page numbers with ellipsis
  List<int> _getPageNumbers() {
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i + 1);
    }

    if (currentPage <= 4) {
      return [1, 2, 3, 4, 5, -1, totalPages];
    }

    if (currentPage >= totalPages - 3) {
      return [
        1,
        -1,
        totalPages - 4,
        totalPages - 3,
        totalPages - 2,
        totalPages - 1,
        totalPages,
      ];
    }

    return [
      1,
      -1,
      currentPage - 1,
      currentPage,
      currentPage + 1,
      -1,
      totalPages,
    ];
  }
}

/// Helper class to manage pagination state
class PaginationState {
  final int currentPage;
  final int itemsPerPage;

  const PaginationState({this.currentPage = 1, this.itemsPerPage = 25});

  PaginationState copyWith({int? currentPage, int? itemsPerPage}) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }

  /// Get paginated subset of items
  List<T> getPage<T>(List<T> allItems) {
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, allItems.length);
    return allItems.sublist(start, end);
  }
}
