import 'package:fluent_ui/fluent_ui.dart';

/// Interactive data table with sorting and hover actions - UI only
class InteractiveDataTable<T> extends StatefulWidget {
  final List<DataColumn> columns;
  final List<T> data;
  final List<DataCell> Function(T item) cellBuilder;
  final void Function(T item)? onRowTap;
  final List<RowAction<T>>? rowActions;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex, bool ascending)? onSort;

  const InteractiveDataTable({
    super.key,
    required this.columns,
    required this.data,
    required this.cellBuilder,
    this.onRowTap,
    this.rowActions,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
  });

  @override
  State<InteractiveDataTable<T>> createState() =>
      _InteractiveDataTableState<T>();
}

class _InteractiveDataTableState<T> extends State<InteractiveDataTable<T>> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[40]),
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                ...widget.columns.asMap().entries.map((entry) {
                  final index = entry.key;
                  final column = entry.value;
                  final isSorted = widget.sortColumnIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (widget.onSort != null) {
                          widget.onSort!(
                            index,
                            isSorted ? !widget.sortAscending : true,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              column.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            if (isSorted) ...[
                              const SizedBox(width: 4),
                              Icon(
                                widget.sortAscending
                                    ? FluentIcons.chevron_up
                                    : FluentIcons.chevron_down,
                                size: 12,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                if (widget.rowActions != null && widget.rowActions!.isNotEmpty)
                  const SizedBox(width: 100), // Actions column
              ],
            ),
          ),
          // Rows
          Expanded(
            child: ListView.builder(
              itemCount: widget.data.length,
              itemBuilder: (context, index) {
                final item = widget.data[index];
                final isHovered = _hoveredIndex == index;

                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: GestureDetector(
                    onTap: () => widget.onRowTap?.call(item),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isHovered ? const Color(0xFFF5F5F5) : Colors.white,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[40]),
                        ),
                      ),
                      child: Row(
                        children: [
                          ...widget.cellBuilder(item).map((cell) {
                            return Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: cell.child,
                              ),
                            );
                          }),
                          if (widget.rowActions != null &&
                              widget.rowActions!.isNotEmpty)
                            SizedBox(
                              width: 100,
                              child:
                                  isHovered
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children:
                                            widget.rowActions!.map((action) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 4,
                                                ),
                                                child: IconButton(
                                                  icon: Icon(
                                                    action.icon,
                                                    size: 16,
                                                  ),
                                                  onPressed:
                                                      () => action.onPressed(
                                                        item,
                                                      ),
                                                ),
                                              );
                                            }).toList(),
                                      )
                                      : const SizedBox(),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DataColumn {
  final String label;
  final bool sortable;

  DataColumn({required this.label, this.sortable = true});
}

class DataCell {
  final Widget child;

  DataCell({required this.child});
}

class RowAction<T> {
  final IconData icon;
  final void Function(T item) onPressed;
  final String? tooltip;

  RowAction({required this.icon, required this.onPressed, this.tooltip});
}
