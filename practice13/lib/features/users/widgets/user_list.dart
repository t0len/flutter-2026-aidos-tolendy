import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prac13/features/users/user.dart';
import 'package:prac13/features/users/user_detail_screen.dart';
import 'package:prac13/features/users/widgets/empty_users_view.dart';
import 'package:prac13/features/users/widgets/offline_banner.dart';
import 'package:prac13/features/users/widgets/user_tile.dart';
import 'package:prac13/features/users/widgets/users_header.dart';

class UserList extends StatelessWidget {
  const UserList({
    super.key,
    required this.users,
    required this.fromCache,
    required this.onRefresh,
    required this.onOpen,
  });

  final List<User> users;
  final bool fromCache;
  final Future<void> Function() onRefresh;
  final ValueChanged<User> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (fromCache) OfflineBanner(onRetry: onRefresh),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: users.isEmpty ? 1 : users.length,
              itemBuilder: (context, index) {
                if (users.isEmpty) return const EmptyUsersView();
                final user = users[index];
                return UserTile(user: user, onTap: () => onOpen(user));
              },
            ),
          ),
        ),
      ],
    );
  }
}

void openDetail(BuildContext context, User user) {
  openUserPage(context, UserDetailScreen(user: user));
}
