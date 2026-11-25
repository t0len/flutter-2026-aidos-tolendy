import 'package:flutter/material.dart';
import 'package:prac13/features/profile/profile_screen.dart';
import 'package:prac13/features/settings/settings_model.dart';
import 'package:prac13/features/settings/settings_screen.dart';
import 'package:prac13/features/users/new_user_page.dart';
import 'package:prac13/features/users/users_model.dart';
import 'package:prac13/features/users/widgets/user_list.dart';
import 'package:prac13/features/users/widgets/users_error_view.dart';
import 'package:prac13/features/users/widgets/users_header.dart';
import 'package:provider/provider.dart';

String? _city(BuildContext context) {
  try {
    return Provider.of<SettingsModel>(context).city;
  } on ProviderNotFoundException {
    return null;
  }
}

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final city = _city(context);
    return Scaffold(
      appBar: UsersHeader(
        onProfile: () => openUserPage(context, const ProfileScreen()),
        onSettings: () => openUserPage(context, const SettingsScreen()),
        onCreate: () => openUserPage(context, const NewUserPage()),
      ),
      body: Consumer<UsersModel>(
        builder: (context, model, _) {
          if (model.loading && model.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final error = model.error;
          if (error != null) {
            return UsersErrorView(error: error, onRetry: model.load);
          }
          final visible = [
            for (final user in model.items)
              if (city == null || user.address.city == city) user,
          ];
          return UserList(
            users: visible,
            fromCache: model.fromCache,
            onRefresh: model.load,
            onOpen: (user) => openDetail(context, user),
          );
        },
      ),
    );
  }
}
