import 'package:flutter/material.dart';

import '../models/meetup.dart';
import 'meetup_card.dart';

const double _breakpoint = 600;
const double _cell = 360;

class MeetupBoard extends StatelessWidget {
  const MeetupBoard({
    super.key,
    required this.meetups,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Meetup> meetups;
  final ValueChanged<Meetup> onOpen;
  final ValueChanged<Meetup> onFavourite;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _breakpoint) {
          final columns = (constraints.maxWidth / _cell).ceil();
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: 156,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: meetups.length,
            itemBuilder: (context, index) {
              final meetup = meetups[index];
              return MeetupCard(
                meetup: meetup,
                onOpen: onOpen,
                onFavourite: onFavourite,
              );
            },
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
          itemCount: meetups.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final meetup = meetups[index];
            return MeetupCard(
              meetup: meetup,
              onOpen: onOpen,
              onFavourite: onFavourite,
            );
          },
        );
      },
    );
  }
}
