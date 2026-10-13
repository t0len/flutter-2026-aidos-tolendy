import 'package:flutter/material.dart';

import '../models/meetup.dart';
import '../utils/format.dart';

class MeetupCard extends StatelessWidget {
  const MeetupCard({
    super.key,
    required this.meetup,
    required this.onOpen,
    required this.onFavourite,
  });

  final Meetup meetup;
  final ValueChanged<Meetup> onOpen;
  final ValueChanged<Meetup> onFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => onOpen(meetup),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              _Avatar(meetup: meetup),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      meetup.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatWhen(meetup.starts)} · ${meetup.place}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: meetup.favourite ? 'Remove favourite' : 'Favourite',
                onPressed: () => onFavourite(meetup),
                icon: Icon(
                  meetup.favourite ? Icons.favorite : Icons.favorite_border,
                  color: meetup.favourite ? theme.colorScheme.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.meetup});

  final Meetup meetup;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final free = meetup.places.free;
    final full = meetup.isFull;
    final badgeColor = full ? scheme.error : scheme.tertiary;
    final badgeOn = full ? scheme.onError : scheme.onTertiary;
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: meetup.language.role(scheme),
            child: Icon(meetup.language.icon, color: scheme.surface),
          ),
          if (full || free <= 5)
            Positioned(
              right: -6,
              bottom: -4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  child: Text(
                    full ? 'FULL' : '$free left',
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: badgeOn),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
