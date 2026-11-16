import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prac11/core/api/api_exception.dart';
import 'package:prac11/features/users/user.dart';
import 'package:prac11/features/users/users_model.dart';
import 'package:provider/provider.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            tooltip: 'New user',
            onPressed: () => unawaited(
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const _NewUserPage()),
              ),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<UsersModel>(
        builder: (context, model, _) {
          if (model.loading && model.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final error = model.error;
          if (error != null) {
            return _ErrorView(error: error, onRetry: model.load);
          }
          return RefreshIndicator(
            onRefresh: model.load,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: model.items.length,
              itemBuilder: (context, index) {
                final user = model.items[index];
                final caption = user.phoneDigits.isEmpty
                    ? user.email
                    : '${user.email}\n${user.phoneDigits}';
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(caption),
                  isThreeLine: user.phoneDigits.isNotEmpty,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final ApiException error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: onRetry,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      error is NoConnectionException
                          ? Icons.wifi_off
                          : Icons.error_outline,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _errorText(error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => unawaited(onRetry()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NewUserPage extends StatefulWidget {
  const _NewUserPage();

  @override
  State<_NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<_NewUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save(UsersModel model) async {
    if (model.saving) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final draft = User(
      id: 0,
      name: _name.text.trim(),
      username: _username.text.trim(),
      email: _email.text.trim(),
      phone: '',
      website: null,
      address: const Address(
        street: '',
        suite: '',
        city: '',
        zipcode: '',
        geo: Geo(lat: 0, lng: 0),
      ),
      company: (name: '', catchPhrase: ''),
    );
    try {
      await model.create(draft);
      if (!mounted) return;
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_errorText(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New user')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) =>
                  (v ?? '').trim().length >= 2 ? null : 'Name is too short',
            ),
            TextFormField(
              controller: _username,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (v) =>
                  (v ?? '').trim().length >= 2 ? null : 'Username is too short',
            ),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'name@kbtu.kz',
              ),
              validator: (v) {
                final value = (v ?? '').trim();
                final at = value.indexOf('@');
                final afterAt = at < 0 ? '' : value.substring(at + 1);
                if (at < 0 || !afterAt.contains('.')) {
                  return 'Email looks wrong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Consumer<UsersModel>(
              builder: (context, model, _) {
                return FilledButton(
                  onPressed: model.saving
                      ? null
                      : () => unawaited(_save(model)),
                  child: model.saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

String _errorText(ApiException error) {
  return switch (error) {
    NoConnectionException() => 'Offline',
    UnauthorizedException() => 'Unauthorized',
    NotFoundException() => 'Not found',
    ServerException(:final status) => 'Server error ($status)',
    BadResponseException(:final detail) =>
      (detail == null || detail.isEmpty) ? 'Bad response' : detail,
  };
}
