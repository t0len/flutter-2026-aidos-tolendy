import 'dart:async';

import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students;
  Object? _error;
  final _api = FakeApi();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final list = await _api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('By hand'),
        actions: [
          IconButton(
            tooltip: 'Retry',
            onPressed: () => unawaited(_load()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: _students == null
          ? null
          : FloatingActionButton(
              onPressed: _saving
                  ? null
                  : () async {
                      if (_saving || _students == null) return;
                      final n = _students!.length;
                      setState(() => _saving = true);
                      try {
                        await _api.save(n);
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      } on StateError catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(e.message)));
                      } finally {
                        if (context.mounted) {
                          setState(() => _saving = false);
                        }
                      }
                    },
              child: _saving
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    )
                  : const Icon(Icons.save),
            ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_error != null) {
      return ErrorView(onRetry: _load);
    }
    if (_students == null) {
      return const LoadingView();
    }
    if (_students!.isEmpty) {
      return const EmptyView('No students yet');
    }
    return StudentList(_students!);
  }
}
