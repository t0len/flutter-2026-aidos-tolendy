import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

enum _CountdownMode { streamBuilder, listen }

class _CountdownScreenState extends State<CountdownScreen> {
  _CountdownMode _mode = _CountdownMode.streamBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<_CountdownMode>(
              segments: const [
                ButtonSegment(
                  value: _CountdownMode.streamBuilder,
                  label: Text('StreamBuilder'),
                ),
                ButtonSegment(
                  value: _CountdownMode.listen,
                  label: Text('Listen'),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) {
                setState(() => _mode = selection.first);
              },
            ),
          ),
          Expanded(
            child: _mode == _CountdownMode.streamBuilder
                ? const _StreamCountdown()
                : const _ListenCountdown(),
          ),
        ],
      ),
    );
  }
}

class _StreamCountdown extends StatefulWidget {
  const _StreamCountdown();

  @override
  State<_StreamCountdown> createState() => _StreamCountdownState();
}

class _StreamCountdownState extends State<_StreamCountdown> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _stream,
      builder: (context, snapshot) {
        final value = snapshot.data ?? 10;
        return Center(
          child: Text(
            '$value',
            style: Theme.of(context).textTheme.displayLarge,
          ),
        );
      },
    );
  }
}

class _ListenCountdown extends StatefulWidget {
  const _ListenCountdown();

  @override
  State<_ListenCountdown> createState() => _ListenCountdownState();
}

class _ListenCountdownState extends State<_ListenCountdown> {
  int _left = 10;
  late StreamSubscription<int> _sub;

  @override
  void initState() {
    super.initState();
    _sub = countdown(10).listen((i) => setState(() => _left = i));
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('$_left', style: Theme.of(context).textTheme.displayLarge),
    );
  }
}
