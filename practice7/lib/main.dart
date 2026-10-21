import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthDate = TextEditingController();
  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthDate]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _signUp() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Account created')));
    setState(() => _done = true);
  }

  void _startOver() {
    setState(() {
      _name.clear();
      _email.clear();
      _password.clear();
      _confirm.clear();
      _birthDate.clear();
      _group = null;
      _birth = null;
      _agreed = false;
      _done = false;
    });
  }

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? now,
      firstDate: DateTime(1950),
      lastDate: now,
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _birth = picked;
      _birthDate.text =
          '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: _done ? _summary() : _form(),
  );

  Widget _summary() => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SummaryCard(
          name: _name.text,
          email: _email.text,
          group: _group ?? '',
          birthDate: _birthDate.text,
        ),
        TextButton(onPressed: _startOver, child: const Text('Start over')),
      ],
    ),
  );

  Widget _form() => Form(
    key: _formKey,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Name'),
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) =>
                (v ?? '').trim().length >= 2 ? null : 'Name is too short',
          ),
          TextFormField(
            controller: _email,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'name@kbtu.kz',
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) {
              final value = (v ?? '').trim();
              final at = value.indexOf('@');
              final afterAt = at < 0 ? '' : value.substring(at + 1);
              if (at < 0 || !afterAt.contains('.')) return 'Email looks wrong';
              return null;
            },
          ),
          TextFormField(
            controller: _password,
            obscureText: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Password',
              helperText: 'At least 8 characters',
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) =>
                (v ?? '').length >= 8 ? null : 'Password is too short',
          ),
          TextFormField(
            controller: _confirm,
            obscureText: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: 'Confirm password'),
            onFieldSubmitted: (_) => _signUp(),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) =>
                (v ?? '') == _password.text ? null : 'Passwords do not match',
          ),
          DropdownButtonFormField<String>(
            initialValue: _group,
            decoration: const InputDecoration(labelText: 'Group'),
            items: [
              for (final g in groups)
                DropdownMenuItem(value: g, child: Text(g)),
            ],
            onChanged: (value) => setState(() => _group = value),
            validator: (g) => g == null ? 'Choose a group' : null,
          ),
          TextFormField(
            controller: _birthDate,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Date of birth',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: _pickBirth,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (_) => _birth == null ? 'Choose a date' : null,
          ),
          CheckboxListTile(
            title: const Text('I agree to the rules'),
            value: _agreed,
            onChanged: (value) => setState(() => _agreed = value ?? false),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _agreed ? _signUp : null,
            child: const Text('Sign up'),
          ),
        ],
      ),
    ),
  );
}
