import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.name,
    required this.email,
    required this.group,
    required this.birthDate,
  });

  final String name;
  final String email;
  final String group;
  final String birthDate;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ListTile(title: const Text('Name'), subtitle: Text(name)),
      ListTile(title: const Text('Email'), subtitle: Text(email)),
      ListTile(title: const Text('Group'), subtitle: Text(group)),
      ListTile(title: const Text('Birth date'), subtitle: Text(birthDate)),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 4,
            children: tiles,
          );
        }
        return Column(mainAxisSize: MainAxisSize.min, children: tiles);
      },
    );
  }
}
