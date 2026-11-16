import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prac12/features/auth/auth_model.dart';
import 'package:prac12/features/users/user.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final website = user.website;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Email'),
            subtitle: Text(user.email),
            onTap: () => unawaited(
              _open(context, Uri(scheme: 'mailto', path: user.email)),
            ),
          ),
          ListTile(
            title: const Text('Phone'),
            subtitle: Text(user.phoneDigits),
            onTap: () => unawaited(
              _open(context, Uri(scheme: 'tel', path: user.phoneDigits)),
            ),
          ),
          if (website != null && website.isNotEmpty)
            ListTile(
              title: const Text('Website'),
              subtitle: Text(website),
              onTap: () =>
                  unawaited(_open(context, Uri.parse('https://$website'))),
            ),
          ListTile(
            title: const Text('City'),
            subtitle: Text(user.address.city),
          ),
          ListTile(
            title: Text(user.company.name),
            subtitle: Text(user.company.catchPhrase),
          ),
          if (kDebugMode)
            ListTile(
              title: const Text('Copy token to clipboard'),
              onTap: () => unawaited(_copyToken(context)),
            ),
        ],
      ),
    );
  }
}

Future<void> _open(BuildContext context, Uri uri) async {
  final opened = await launchUrl(uri);
  if (!context.mounted) return;
  if (!opened) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('No app can open this')));
  }
}

Future<void> _copyToken(BuildContext context) async {
  final token = await context.read<AuthModel>().readToken();
  if (!context.mounted || token == null) return;
  await Clipboard.setData(ClipboardData(text: token));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Token copied')));
}
