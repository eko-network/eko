import 'package:flutter/material.dart';

class FeedOption<T> {
  final String label;
  final T value;
  const FeedOption({required this.label, required this.value});
}

class FeedOptionsButton<T> extends StatelessWidget {
  final List<FeedOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;
  final double? height;

  const FeedOptionsButton({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.height,
  });

  String get _selectedLabel {
    final index = options.indexWhere((o) => o.value == selectedValue);
    return index >= 0 ? options[index].label : '';
  }

  void _showOptionsSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ...options.map(
                (option) => _OptionTile(
                  label: option.label,
                  isSelected: option.value == selectedValue,
                  onTap: () {
                    onChanged(option.value);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _showOptionsSheet(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: height ?? 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 20, color: colorScheme.onSurface),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check, size: 20, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
