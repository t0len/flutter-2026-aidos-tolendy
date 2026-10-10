import 'countdown.dart';
import 'language.dart';

class Meetup {
  static const Object _keep = Object();

  const Meetup({
    required this.id,
    required this.title,
    required this.language,
    required this.starts,
    required this.place,
    required this.seats,
    required this.participants,
    required this.online,
    required this.note,
    required this.favourite,
  });

  Meetup.empty()
    : this(
        id: '',
        title: '',
        language: Language.english,
        starts: _defaultStart(),
        place: '',
        seats: 10,
        participants: const [],
        online: false,
        note: null,
        favourite: false,
      );

  final String id;
  final String title;
  final Language language;
  final DateTime starts;
  final String place;
  final int seats;
  final List<String> participants;
  final bool online;
  final String? note;
  final bool favourite;

  int get count => participants.length;

  int get freePlaces => seats - count;

  bool get isFull => count >= seats;

  bool get isPast => starts.isBefore(DateTime.now());

  bool contains(String name) => participants.any((entry) => entry == name);

  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Countdown countdownAt(DateTime now) {
    if (now.isBefore(starts)) {
      return Upcoming(starts.difference(now));
    }
    final elapsed = now.difference(starts);
    if (elapsed < const Duration(hours: 1)) {
      return Started(elapsed);
    }
    return const Ended();
  }

  Meetup copyWith({
    String? title,
    Language? language,
    DateTime? starts,
    String? place,
    int? seats,
    List<String>? participants,
    bool? online,
    Object? note = _keep,
    bool? favourite,
  }) {
    final String? nextNote;
    if (identical(note, _keep)) {
      nextNote = this.note;
    } else if (note is String) {
      nextNote = note;
    } else {
      nextNote = null;
    }
    return Meetup(
      id: id,
      title: title ?? this.title,
      language: language ?? this.language,
      starts: starts ?? this.starts,
      place: place ?? this.place,
      seats: seats ?? this.seats,
      participants: List<String>.unmodifiable(
        participants ?? this.participants,
      ),
      online: online ?? this.online,
      note: nextNote,
      favourite: favourite ?? this.favourite,
    );
  }

  static DateTime _defaultStart() {
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day + 1, 18, 0);
  }
}

List<Meetup> sortedCopy(List<Meetup> source) {
  final copy = [...source];
  copy.sort((a, b) {
    if (a.isPast != b.isPast) {
      return a.isPast ? 1 : -1;
    }
    return a.starts.compareTo(b.starts);
  });
  return copy;
}
