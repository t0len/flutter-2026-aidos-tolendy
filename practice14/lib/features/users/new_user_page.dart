import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prac14/core/api/api_exception.dart';
import 'package:prac14/features/users/user.dart';
import 'package:prac14/features/users/users_model.dart';
import 'package:prac14/features/users/widgets/users_error_view.dart';
import 'package:provider/provider.dart';

class NewUserPage extends StatefulWidget {
  const NewUserPage({super.key});

  @override
  State<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
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
          .showSnackBar(SnackBar(content: Text(messageFor(e))));
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
            _Field(
              controller: _name,
              label: 'Name',
              error: 'Name is too short',
            ),
            _Field(
              controller: _username,
              label: 'Username',
              error: 'Username is too short',
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
              validator: _emailError,
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.error,
  });

  final TextEditingController controller;
  final String label;
  final String error;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label),
      validator: (value) => (value ?? '').trim().length >= 2 ? null : error,
    );
  }
}

String? _emailError(String? value) {
  final text = (value ?? '').trim();
  final at = text.indexOf('@');
  final afterAt = at < 0 ? '' : text.substring(at + 1);
  if (at < 0 || !afterAt.contains('.')) return 'Email looks wrong';
  return null;
}
