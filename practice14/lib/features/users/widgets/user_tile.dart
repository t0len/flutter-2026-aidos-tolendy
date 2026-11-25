import 'package:flutter/material.dart';
import 'package:prac14/features/users/user.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user, required this.onTap});

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final digits = user.phoneDigits;
    final caption = digits.isEmpty ? user.email : '${user.email}\n$digits';
    return ListTile(
      title: Text(user.name),
      subtitle: Text(caption),
      isThreeLine: digits.isNotEmpty,
      onTap: onTap,
    );
  }
}
