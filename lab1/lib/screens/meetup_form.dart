import 'package:flutter/material.dart';

import '../models/language.dart';
import '../models/meetup.dart';
import '../utils/format.dart';

class MeetupForm extends StatefulWidget {
  const MeetupForm({super.key, this.meetup});

  final Meetup? meetup;

  @override
  State<MeetupForm> createState() => _MeetupFormState();
}

class _MeetupFormState extends State<MeetupForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleFocus = FocusNode();
  final _dateFocus = FocusNode();
  final _timeFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _noteFocus = FocusNode();

  late final Meetup _baseline;
  late final bool _isNew;
  late final TextEditingController _titleController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _placeController;
  late final TextEditingController _limitController;
  late final TextEditingController _noteController;
  late DateTime _date;
  late TimeOfDay _clock;
  late Language _language;
  late bool _online;
  var _saving = false;
  var _discarding = false;

  @override
  void initState() {
    super.initState();
    _isNew = widget.meetup == null;
    _baseline = widget.meetup ?? Meetup.empty();
    _language = _baseline.language;
    _online = _baseline.online;
    _date = DateTime(
      _baseline.starts.year,
      _baseline.starts.month,
      _baseline.starts.day,
    );
    _clock = TimeOfDay.fromDateTime(_baseline.starts);
    _titleController = TextEditingController(text: _baseline.title);
    _dateController = TextEditingController(text: formatDate(_date));
    _timeController = TextEditingController(
      text: formatClock(_clock.hour, _clock.minute),
    );
    _placeController = TextEditingController(text: _baseline.place);
    _limitController = TextEditingController(text: '${_baseline.seats}');
    _noteController = TextEditingController(text: _baseline.note ?? '');
    _titleController.addListener(_markDirty);
    _dateController.addListener(_markDirty);
    _timeController.addListener(_markDirty);
    _placeController.addListener(_markDirty);
    _limitController.addListener(_markDirty);
    _noteController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _titleController.removeListener(_markDirty);
    _dateController.removeListener(_markDirty);
    _timeController.removeListener(_markDirty);
    _placeController.removeListener(_markDirty);
    _limitController.removeListener(_markDirty);
    _noteController.removeListener(_markDirty);
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _placeController.dispose();
    _limitController.dispose();
    _noteController.dispose();
    _titleFocus.dispose();
    _dateFocus.dispose();
    _timeFocus.dispose();
    _placeFocus.dispose();
    _limitFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  void _markDirty() => setState(() {});

  bool get _dirty {
    final openedTime = TimeOfDay.fromDateTime(_baseline.starts);
    return _titleController.text.trim() != _baseline.title ||
        _language != _baseline.language ||
        _date.year != _baseline.starts.year ||
        _date.month != _baseline.starts.month ||
        _date.day != _baseline.starts.day ||
        _clock.hour != openedTime.hour ||
        _clock.minute != openedTime.minute ||
        _online != _baseline.online ||
        _placeController.text.trim() != _baseline.place ||
        _limitController.text.trim() != '${_baseline.seats}' ||
        _noteController.text.trim() != (_baseline.note ?? '');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2036),
    );
    if (picked == null || !mounted) return;
    _date = DateTime(picked.year, picked.month, picked.day);
    _dateController.text = formatDate(_date);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _clock);
    if (picked == null || !mounted) return;
    _clock = picked;
    _timeController.text = formatClock(_clock.hour, _clock.minute);
  }

  Future<void> _askToDiscard() async {
    if (_discarding) return;
    _discarding = true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Discard changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep editing'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Discard'),
            ),
          ],
        );
      },
    );
    _discarding = false;
    if (discard == true && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final seats = int.tryParse(_limitController.text.trim());
    if (seats == null) return;
    final meetup = _built(seats);
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context, meetup);
  }

  Meetup _built(int seats) {
    final trimmedNote = _noteController.text.trim();
    return Meetup(
      id: _isNew
          ? 'meetup-${DateTime.now().microsecondsSinceEpoch}'
          : _baseline.id,
      title: _titleController.text.trim(),
      language: _language,
      starts: DateTime(
        _date.year,
        _date.month,
        _date.day,
        _clock.hour,
        _clock.minute,
      ),
      place: _placeController.text.trim(),
      seats: seats,
      participants: List<String>.unmodifiable(_baseline.participants),
      online: _online,
      note: trimmedNote.isEmpty ? null : trimmedNote,
      favourite: _baseline.favourite,
    );
  }

  String? _validateTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < 3 || text.length > 60) return 'Use 3 to 60 characters';
    return null;
  }

  String? _validatePlace(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return _online ? 'Enter a link' : 'Enter a place';
    if (_online && !text.contains('://')) return 'A link must contain ://';
    return null;
  }

  String? _validateLimit(String? value) {
    final parsed = int.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 1 || parsed > 500) {
      return 'Enter a whole number from 1 to 500';
    }
    if (!_isNew && parsed < _baseline.count) {
      return 'At least ${_baseline.count} already joined';
    }
    return null;
  }

  String? _validateDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Choose a date';
    return _validateFuture();
  }

  String? _validateTime(String? value) {
    if (value == null || value.trim().isEmpty) return 'Choose a time';
    return _validateFuture();
  }

  String? _validateFuture() {
    if (!_isNew) return null;
    final combined = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _clock.hour,
      _clock.minute,
    );
    if (!combined.isAfter(DateTime.now())) {
      return 'Choose a future date and time';
    }
    return null;
  }

  String? _validateNote(String? value) => null;

  void _dismiss() => FocusManager.instance.primaryFocus?.unfocus();

  @override
  Widget build(BuildContext context) {
    return PopScope<Meetup>(
      canPop: !_dirty && !_saving,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _saving) return;
        _askToDiscard();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: Text(_isNew ? 'New meetup' : 'Edit meetup')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  validator: _validateTitle,
                  maxLength: 60,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(labelText: 'Title'),
                  onFieldSubmitted: (_) => _dateFocus.requestFocus(),
                  onTapOutside: (_) => _dismiss(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Language>(
                  initialValue: _language,
                  decoration: const InputDecoration(labelText: 'Language'),
                  items: Language.values.map((language) {
                    return DropdownMenuItem(
                      value: language,
                      child: Text(language.label),
                    );
                  }).toList(),
                  validator: (value) =>
                      value == null ? 'Choose a language' : null,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _language = value);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dateController,
                  focusNode: _dateFocus,
                  validator: _validateDate,
                  readOnly: true,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.none,
                  decoration: const InputDecoration(labelText: 'Date'),
                  onTap: _pickDate,
                  onFieldSubmitted: (_) => _timeFocus.requestFocus(),
                  onTapOutside: (_) => _dismiss(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _timeController,
                  focusNode: _timeFocus,
                  validator: _validateTime,
                  readOnly: true,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.none,
                  decoration: const InputDecoration(labelText: 'Time'),
                  onTap: _pickTime,
                  onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                  onTapOutside: (_) => _dismiss(),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Online'),
                  subtitle: const Text('Place is a link and must contain ://'),
                  value: _online,
                  onChanged: (value) => setState(() => _online = value),
                ),
                TextFormField(
                  controller: _placeController,
                  focusNode: _placeFocus,
                  validator: _validatePlace,
                  textInputAction: TextInputAction.next,
                  keyboardType: _online
                      ? TextInputType.url
                      : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: _online ? 'Link' : 'Place',
                  ),
                  onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                  onTapOutside: (_) => _dismiss(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _limitController,
                  focusNode: _limitFocus,
                  validator: _validateLimit,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Limit',
                    helperText: 'From 1 to 500',
                  ),
                  onFieldSubmitted: (_) => _noteFocus.requestFocus(),
                  onTapOutside: (_) => _dismiss(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  focusNode: _noteFocus,
                  validator: _validateNote,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(labelText: 'Note'),
                  onFieldSubmitted: (_) => _dismiss(),
                  onTapOutside: (_) => _dismiss(),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ),
      ),
    );
  }
}
