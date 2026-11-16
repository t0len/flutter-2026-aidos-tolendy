import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prac12/features/auth/auth_model.dart';
import 'package:prac12/features/settings/settings_model.dart';
import 'package:prac12/features/users/users_model.dart';
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
          Padding(
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
              onChanged: (value) => unawaited(settings.setCity(value)),
            ),
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
