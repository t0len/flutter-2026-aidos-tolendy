import 'package:flutter/material.dart';

class CityFilterRow extends StatelessWidget {
  const CityFilterRow({
    super.key,
    required this.cities,
    required this.selected,
    required this.onChanged,
  });

  final List<String> cities;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String?>(
        key: ValueKey(selected),
        initialValue: selected,
        decoration: const InputDecoration(labelText: 'City'),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('All cities'),
          ),
          for (final city in cities)
            DropdownMenuItem<String?>(value: city, child: Text(city)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
