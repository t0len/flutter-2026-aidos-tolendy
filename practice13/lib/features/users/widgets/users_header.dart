import 'dart:async';

import 'package:flutter/material.dart';

class UsersHeader extends StatelessWidget implements PreferredSizeWidget {
  const UsersHeader({
    super.key,
    required this.onProfile,
    required this.onSettings,
    required this.onCreate,
  });

  final VoidCallback onProfile;
  final VoidCallback onSettings;
  final VoidCallback onCreate;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Users'),
      actions: [
        IconButton(
          tooltip: 'Profile',
          onPressed: onProfile,
          icon: const Icon(Icons.person),
        ),
        IconButton(
          tooltip: 'Settings',
          onPressed: onSettings,
          icon: const Icon(Icons.settings),
        ),
        IconButton(
          tooltip: 'New user',
          onPressed: onCreate,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

void openUserPage(BuildContext context, Widget page) {
  unawaited(
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page)),
  );
}
