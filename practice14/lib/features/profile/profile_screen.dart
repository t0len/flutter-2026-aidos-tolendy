import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prac14/features/profile/camera_blocked_dialog.dart';
import 'package:prac14/features/settings/settings_model.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _path;

  @override
  void initState() {
    super.initState();
    _path = context.read<SettingsModel>().avatarPath;
  }

  Future<void> _take() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        await _pick(ImageSource.camera);
      case PermissionStatus.denied:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Camera permission was denied. You can allow it next time.',
            ),
          ),
        );
      case PermissionStatus.permanentlyDenied:
        await _showBlockedDialog();
      case PermissionStatus.restricted:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera access is restricted on this device.'),
          ),
        );
      case PermissionStatus.provisional:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is provisional.')),
        );
    }
  }

  Future<void> _showBlockedDialog() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (_) => const CameraBlockedDialog(),
    );
    if (open != true || !mounted) return;
    await openAppSettings();
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    if (!mounted) return;
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/avatar.jpg');
    try {
      await File(picked.path).copy(dest.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not save the photo')));
      return;
    }
    if (!mounted) return;
    setState(() => _path = dest.path);
    await context.read<SettingsModel>().setAvatar(dest.path);
  }

  @override
  Widget build(BuildContext context) {
    File? photo;
    final path = _path;
    if (path != null) {
      final file = File(path);
      if (file.existsSync()) photo = file;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 56,
              backgroundImage: photo == null ? null : FileImage(photo),
              child: photo == null ? const Text('U') : null,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => unawaited(_pick(ImageSource.gallery)),
            child: const Text('Choose photo'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => unawaited(_take()),
            child: const Text('Take photo'),
          ),
        ],
      ),
    );
  }
}
