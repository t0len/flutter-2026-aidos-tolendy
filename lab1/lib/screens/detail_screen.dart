import 'dart:async';

import 'package:flutter/material.dart';

import '../models/meetup.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.meetup,
    required this.profile,
    required this.onChanged,
    required this.onDeleted,
    required this.onOpenProfile,
  });

  final Meetup meetup;
  final Profile profile;
  final ValueChanged<Meetup> onChanged;
  final ValueChanged<String> onDeleted;
  final VoidCallback onOpenProfile;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Meetup _meetup;
  late DateTime _now;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _meetup = widget.meetup;
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _edit() async {
    final result = await Navigator.pushNamed<Meetup>(
      context,
      Routes.form,
      arguments: FormArgs(_meetup),
    );
    if (result == null || !mounted) return;
    setState(() => _meetup = result);
    widget.onChanged(result);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete this meetup?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    widget.onDeleted(_meetup.id);
    Navigator.pop(context);
  }

  Future<void> _onPrimary() async {
    final name = widget.profile.name.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name on the Profile tab'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: widget.onOpenProfile,
          ),
        ),
      );
      return;
    }
    if (_meetup.contains(name)) {
      final updated = _meetup.copyWith(
        participants: [
          for (final entry in _meetup.participants)
            if (entry != name) entry,
        ],
      );
      setState(() => _meetup = updated);
      widget.onChanged(updated);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Join this meetup?'),
          content: Text('Join as $name?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final updated = _meetup.copyWith(
      participants: [..._meetup.participants, name],
    );
    setState(() => _meetup = updated);
    widget.onChanged(updated);
  }

  void _onMenu(String value) {
    switch (value) {
      case 'edit':
        _edit();
      case 'delete':
        _delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.profile.name.trim();
    final joined = name.isNotEmpty && _meetup.contains(name);
    final canAct = joined || !_meetup.isFull;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _meetup.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: _onMenu,
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(meetup: _meetup, now: _now),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Names (${_meetup.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(children: [_about(context), _names(context)]),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: canAct ? _onPrimary : null,
            child: Text(joined ? 'Leave' : 'Join'),
          ),
        ),
      ),
    );
  }

  Widget _about(BuildContext context) {
    final theme = Theme.of(context);
    final (:taken, :free) = _meetup.places;
    final note = _meetup.note;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(formatWhen(_meetup.starts), style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(_meetup.place, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        Text('$taken taken, $free free', style: theme.textTheme.bodyLarge),
        if (note != null) ...[
          const SizedBox(height: 12),
          Text(note, style: theme.textTheme.bodyMedium),
        ],
      ],
    );
  }

  Widget _names(BuildContext context) {
    final people = _meetup.participants;
    if (people.isEmpty) {
      return const EmptyState(
        icon: Icons.groups_outlined,
        message: 'Nobody is on the list',
      );
    }
    final you = widget.profile.name.trim();
    final theme = Theme.of(context);
    return ListView(
      children: [
        for (final person in people)
          ListTile(
            title: Text(
              you.isNotEmpty && person == you ? 'You' : person,
              style: you.isNotEmpty && person == you
                  ? theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.meetup, required this.now});

  final Meetup meetup;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 2.4,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/header.png', fit: BoxFit.cover),
          ColoredBox(color: scheme.scrim.withValues(alpha: 0.25)),
          Positioned(
            left: 12,
            bottom: 12,
            child: _Chip(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    meetup.language.icon,
                    color: meetup.language.role(scheme),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    meetup.language.label,
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: _Chip(
              child: Text(
                formatCountdown(meetup.countdownAt(now)),
                style: theme.textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: child,
      ),
    );
  }
}
