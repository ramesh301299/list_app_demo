import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:list_app/api_providers.dart';

class SearchableDropdown extends ConsumerWidget {
  const SearchableDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(basicInfoProvider);
    final notifier = ref.read(basicInfoProvider.notifier);

    return DropdownButton<InfoType>(
      isExpanded: true,
      hint: const Text('Select Type'),
      value: state.selectedType,
      items: InfoType.values.map((InfoType type) {
        return DropdownMenuItem<InfoType>(
          value: type,
          child: Text(_formatTypeName(type.name)),
        );
      }).toList(),
      onChanged: (InfoType? newValue) {
        if (newValue != null) {
          notifier.setTypeAndFetch(newValue);
        }
      },
    );
  }

  String _formatTypeName(String name) {
    return name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    ).trim();
  }
}