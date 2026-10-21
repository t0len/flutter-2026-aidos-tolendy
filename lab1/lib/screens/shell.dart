import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/meetup.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import 'favourites_tab.dart';
import 'meetup_list.dart';
import 'profile_tab.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<Meetup> _meetups = seedMeetups();
  Profile _profile = const Profile.empty();
  var _index = 0;

  void _showTab(int index) {
    setState(() => _index = index);
  }

  void _setProfile(Profile profile) {
    setState(() => _profile = profile);
  }

  void _replace(Meetup meetup) {
    setState(() {
      _meetups = [
        for (final item in _meetups)
          if (item.id == meetup.id) meetup else item,
      ];
    });
  }

  void _remove(String id) {
    setState(() {
      _meetups = [
        for (final item in _meetups)
          if (item.id != id) item,
      ];
    });
  }

  void _toggleFavourite(Meetup meetup) {
    setState(() {
      _meetups = [
        for (final item in _meetups)
          if (item.id == meetup.id)
            item.copyWith(favourite: !item.favourite)
          else
            item,
      ];
    });
  }

  void _showProfileTab() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _index = 2);
  }

  Future<void> _openDetail(Meetup meetup) async {
    await Navigator.pushNamed<void>(
      context,
      Routes.detail,
      arguments: DetailArgs(
        meetup: meetup,
        profile: _profile,
        onChanged: _replace,
        onDeleted: _remove,
        onOpenProfile: _showProfileTab,
      ),
    );
  }

  Future<void> _openCreate() async {
    final created = await Navigator.pushNamed<Meetup>(
      context,
      Routes.form,
      arguments: const FormArgs(null),
    );
    if (created == null || !mounted) return;
    setState(() => _meetups = [..._meetups, created]);
  }

  Future<void> _reset() async {
    Navigator.pop(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset data?'),
          content: const Text(
            'This restores the original meetups and clears your profile.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (confirmed == true && mounted) {
      setState(() {
        _meetups = seedMeetups();
        _profile = const Profile.empty();
      });
    }
  }

  void _about() {
    Navigator.pop(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('About'),
          content: const Text(
            'Exchange lists language meetups. Join with the name from your profile. Seats, favourites, and your profile stay in memory on this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeScope.of(context);
    final body = switch (_index) {
      0 => MeetupList(
        meetups: _meetups,
        onOpen: _openDetail,
        onFavourite: _toggleFavourite,
      ),
      1 => FavouritesTab(
        meetups: _meetups,
        onOpen: _openDetail,
        onFavourite: _toggleFavourite,
      ),
      _ => ProfileTab(
        profile: _profile,
        meetups: _meetups,
        themeMode: theme.themeMode,
        onThemeMode: theme.onThemeMode,
        onChanged: _setProfile,
      ),
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Exchange')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Exchange',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            ListTile(title: const Text('About'), onTap: _about),
            ListTile(title: const Text('Reset data'), onTap: _reset),
          ],
        ),
      ),
      body: body,
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: _openCreate,
              tooltip: 'New meetup',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _showTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            label: 'Meetups',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
