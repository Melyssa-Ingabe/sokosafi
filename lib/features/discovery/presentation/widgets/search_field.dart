import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/core/theme/app_colors.dart';

/// The search box. Stateful only to own its TextEditingController; what
/// is being searched lives in the SearchCubit. With [onBack] the search
/// icon becomes a back button, for the box that replaces the navigation.
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.onChanged,
    this.onBack,
    this.autofocus = false,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback? onBack;
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search food or shops',
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: widget.onBack == null
            ? const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedSearch01,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              )
            : IconButton(
                tooltip: 'Close search',
                onPressed: widget.onBack,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
              ),
        // Rebuilds only the clear button as the text changes.
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, child) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: _clear,
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius * 2),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius * 2),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
      ),
    );
  }
}
