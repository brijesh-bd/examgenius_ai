import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Filter UI shared by the practice-set and study-notes libraries.

/// Bottom sheet with "All" + options. Returns `(value,)` when something was
/// picked (`(null,)` for All), or `null` when dismissed.
Future<(T?,)?> showFilterPicker<T>(
  BuildContext context, {
  required String title,
  required String anyLabel,
  required T? selected,
  required List<(T, String)> options,
  required void Function(T?) onPick,
}) async {
  final picked = await showModalBottomSheet<(T?,)>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (c) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(c).height * 0.7,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(title, style: Theme.of(c).textTheme.titleMedium),
            ),
            _OptionTile(
              label: anyLabel,
              selected: selected == null,
              onTap: () => Navigator.pop(c, (null,)),
            ),
            for (final o in options)
              _OptionTile(
                label: o.$2,
                selected: selected == o.$1,
                onTap: () => Navigator.pop(c, (o.$1,)),
              ),
          ],
        ),
      ),
    ),
  );
  if (picked != null) onPick(picked.$1);
  return picked;
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(label),
    trailing: selected
        ? const Icon(Icons.check_rounded, color: AppColors.primary)
        : null,
    selected: selected,
    onTap: onTap,
  );
}

class FilterPickerChip extends StatelessWidget {
  const FilterPickerChip({
    super.key,
    required this.label,
    required this.onTap,
    this.value,
    this.icon,
  });

  final String label;

  /// Selected option; `null` = not filtered.
  final String? value;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = value != null;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: active,
        showCheckmark: false,
        avatar: icon == null ? null : Icon(icon, size: 18),
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  value ?? label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon == null) const Icon(Icons.arrow_drop_down_rounded),
            ],
          ),
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
