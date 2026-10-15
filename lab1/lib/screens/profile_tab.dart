import 'package:flutter/material.dart';

import '../models/meetup.dart';
import '../models/profile.dart';

final _groupPattern = RegExp(r'^[A-Za-z]{2,8}-\d{2}$');

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.meetups,
    required this.themeMode,
    required this.onThemeMode,
    required this.onChanged,
  });

  final Profile profile;
  final List<Meetup> meetups;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeMode;
  final ValueChanged<Profile> onChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _group;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _group = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile.name != oldWidget.profile.name &&
        widget.profile.name != _name.text) {
      _name.text = widget.profile.name;
    }
    if (widget.profile.group != oldWidget.profile.group &&
        widget.profile.group != _group.text) {
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  void _submit(String _) {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    widget.onChanged(
      Profile(name: _name.text.trim(), group: _group.text.trim()),
    );
  }

  String? _validateGroup(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!_groupPattern.hasMatch(text)) return 'Use a code like CS-24';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.profile.name;
    final total = widget.meetups.fold<int>(0, (sum, meetup) {
      if (name.isNotEmpty && meetup.contains(name)) return sum + 1;
      return sum;
    });
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('You are on $total lists', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(labelText: 'Name'),
                onFieldSubmitted: _submit,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _group,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  helperText: 'Like CS-24',
                ),
                validator: _validateGroup,
                onFieldSubmitted: _submit,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Theme', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('System'),
              selected: widget.themeMode == ThemeMode.system,
              onSelected: (_) => widget.onThemeMode(ThemeMode.system),
            ),
            ChoiceChip(
              label: const Text('Light'),
              selected: widget.themeMode == ThemeMode.light,
              onSelected: (_) => widget.onThemeMode(ThemeMode.light),
            ),
            ChoiceChip(
              label: const Text('Dark'),
              selected: widget.themeMode == ThemeMode.dark,
              onSelected: (_) => widget.onThemeMode(ThemeMode.dark),
            ),
          ],
        ),
      ],
    );
  }
}
