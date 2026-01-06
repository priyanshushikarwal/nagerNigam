import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global search bar with debounce - UI only, uses existing providers
class GlobalSearchBar extends ConsumerStatefulWidget {
  final FocusNode? focusNode;

  const GlobalSearchBar({super.key, this.focusNode});

  @override
  ConsumerState<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends ConsumerState<GlobalSearchBar> {
  final TextEditingController _controller = TextEditingController();
  late final FocusNode _focusNode;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 36,
      child: TextBox(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: 'Search bills, payments, TNs... (Ctrl+F)',
        style: const TextStyle(fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(FluentIcons.search, size: 14, color: Colors.grey[100]),
        ),
        suffix:
            _controller.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(FluentIcons.clear, size: 12),
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
                : null,
        onChanged: _onSearchChanged,
      ),
    );
  }
}

/// Provider for search state - UI only
final searchQueryProvider = StateProvider<String>((ref) => '');
