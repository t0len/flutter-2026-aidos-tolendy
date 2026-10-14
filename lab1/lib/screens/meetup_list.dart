import 'package:flutter/material.dart';

import '../models/language.dart';
import '../models/meetup.dart';
import '../widgets/empty_state.dart';
import '../widgets/meetup_board.dart';

class MeetupList extends StatefulWidget {
  const MeetupList({
    super.key,
    required this.meetups,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Meetup> meetups;
  final ValueChanged<Meetup> onOpen;
  final ValueChanged<Meetup> onFavourite;

  @override
  State<MeetupList> createState() => _MeetupListState();
}

class _MeetupListState extends State<MeetupList> {
  final _search = TextEditingController();
  Language? _language;
  var _past = false;

  @override
  void initState() {
    super.initState();
    _search.addListener(_onSearch);
  }

  @override
  void dispose() {
    _search.removeListener(_onSearch);
    _search.dispose();
    super.dispose();
  }

  void _onSearch() => setState(() {});

  bool _matches(Meetup meetup) {
    final query = _search.text.trim().toLowerCase();
    final matchesQuery =
        query.isEmpty || meetup.title.toLowerCase().contains(query);
    final matchesLanguage = _language == null || meetup.language == _language;
    final matchesPast = _past ? meetup.isPast : !meetup.isPast;
    return matchesQuery && matchesLanguage && matchesPast;
  }

  @override
  Widget build(BuildContext context) {
    final visible = sortedCopy(widget.meetups.where(_matches).toList());
    final query = _search.text.trim();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      onPressed: _search.clear,
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _language == null,
                onSelected: (_) => setState(() => _language = null),
              ),
              for (final language in Language.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(language.label),
                  selected: _language == language,
                  onSelected: (_) => setState(() => _language = language),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              label: const Text('Past'),
              selected: _past,
              onSelected: (value) => setState(() => _past = value),
            ),
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No meetups match',
                  actionLabel: query.isEmpty ? null : 'Clear',
                  onAction: query.isEmpty ? null : _search.clear,
                )
              : MeetupBoard(
                  meetups: visible,
                  onOpen: widget.onOpen,
                  onFavourite: widget.onFavourite,
                ),
        ),
      ],
    );
  }
}
