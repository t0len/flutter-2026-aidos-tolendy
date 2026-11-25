import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prac14/core/env.dart';
import 'package:prac14/features/auth/auth_model.dart';
import 'package:prac14/features/settings/about_screen.dart';
import 'package:prac14/features/settings/settings_model.dart';
import 'package:prac14/features/users/users_model.dart';
import 'package:prac14/features/users/widgets/city_filter_row.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsModel>();
    final users = context.watch<UsersModel>();
    final selected = settings.city;
    final cities = <String>{
      for (final user in users.items) user.address.city,
    }.toList()..sort();
    if (selected != null && !cities.contains(selected)) {
      cities.add(selected);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: settings.dark,
            onChanged: (value) => unawaited(settings.setDark(value)),
          ),
          CityFilterRow(
            cities: cities,
            selected: selected,
            onChanged: (value) => unawaited(settings.setCity(value)),
          ),
          if (kDebugMode)
            ListTile(
              title: const Text('Developer: API host'),
              subtitle: Text(settings.apiHost ?? Env.host),
              onTap: () => unawaited(_pickHost(context)),
            ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              unawaited(
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Sign out'),
            onTap: () {
              final auth = context.read<AuthModel>();
              Navigator.pop(context);
              unawaited(auth.logout());
            },
          ),
        ],
      ),
    );
  }
}

Future<void> _pickHost(BuildContext context) async {
  final settings = context.read<SettingsModel>();
  final value = await showDialog<String>(
    context: context,
    builder: (context) => _HostDialog(initial: settings.apiHost ?? Env.host),
  );
  if (value == null || !context.mounted) return;
  await settings.setApiHost(value.isEmpty ? null : value);
  if (!context.mounted) return;
  await context.read<UsersModel>().load();
}

class _HostDialog extends StatefulWidget {
  const _HostDialog({required this.initial});

  final String initial;

  @override
  State<_HostDialog> createState() => _HostDialogState();
}

class _HostDialogState extends State<_HostDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Developer: API host'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Host'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, ''),
          child: const Text('Reset'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
