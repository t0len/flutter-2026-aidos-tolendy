import 'package:flutter/material.dart';

import '../models/meetup.dart';
import '../widgets/empty_state.dart';
import '../widgets/meetup_board.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
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
    final favourites = sortedCopy([
      for (final meetup in meetups)
        if (meetup.favourite) meetup,
    ]);
    if (favourites.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_outline,
        message: 'No favourites yet',
      );
    }
    return MeetupBoard(
      meetups: favourites,
      onOpen: onOpen,
      onFavourite: onFavourite,
    );
  }
}
