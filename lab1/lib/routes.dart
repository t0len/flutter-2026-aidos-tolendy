import 'package:flutter/material.dart';

import 'models/meetup.dart';
import 'models/profile.dart';
import 'screens/detail_screen.dart';
import 'screens/meetup_form.dart';

class Routes {
  static const shell = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class DetailArgs {
  const DetailArgs({
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
}

class FormArgs {
  const FormArgs(this.meetup);

  final Meetup? meetup;
}

Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case Routes.detail:
      final args = settings.arguments;
      if (args is DetailArgs) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (context) => DetailScreen(
            meetup: args.meetup,
            profile: args.profile,
            onChanged: args.onChanged,
            onDeleted: args.onDeleted,
            onOpenProfile: args.onOpenProfile,
          ),
        );
      }
      return unknownRoute(settings);
    case Routes.form:
      final args = settings.arguments;
      if (args is FormArgs) {
        return MaterialPageRoute<Meetup>(
          settings: settings,
          builder: (context) => MeetupForm(meetup: args.meetup),
        );
      }
      return unknownRoute(settings);
    default:
      return null;
  }
}

Route<dynamic> unknownRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (context) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    ),
  );
}
