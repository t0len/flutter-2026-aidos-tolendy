import 'package:flutter/material.dart';

enum Language {
  english('English', Icons.chat_outlined),
  spanish('Spanish', Icons.wb_sunny_outlined),
  german('German', Icons.account_balance_outlined),
  french('French', Icons.music_note_outlined),
  japanese('Japanese', Icons.spa_outlined);

  const Language(this.label, this.icon);

  final String label;
  final IconData icon;

  Color role(ColorScheme scheme) => switch (this) {
    Language.english => scheme.primary,
    Language.spanish => scheme.secondary,
    Language.german => scheme.tertiary,
    Language.french => scheme.error,
    Language.japanese => scheme.primaryContainer,
  };
}
