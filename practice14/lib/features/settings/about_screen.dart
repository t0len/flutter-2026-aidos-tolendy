import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:prac14/core/env.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = kReleaseMode
        ? 'release'
        : kProfileMode
        ? 'profile'
        : 'debug';
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final info = snapshot.data;
          final version = info == null
              ? ''
              : 'Version ${info.version} (${info.buildNumber}) · ';
          return ListView(
            children: [
              ListTile(
                title: Text('$version$mode · ${Env.name} · ${Env.host}'),
              ),
              ListTile(
                title: const Text('Licences'),
                onTap: () => showLicensePage(context: context),
              ),
            ],
          );
        },
      ),
    );
  }
}
