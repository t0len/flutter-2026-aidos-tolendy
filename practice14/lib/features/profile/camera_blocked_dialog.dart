import 'package:flutter/material.dart';

class CameraBlockedDialog extends StatelessWidget {
  const CameraBlockedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Camera is blocked'),
      content: const Text(
        'The system will not ask again. Open settings and allow the camera.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Open settings'),
        ),
      ],
    );
  }
}
