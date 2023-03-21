import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.brightness_4),
                const Text('Dark Mode'),
                Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ],
            ),
            // change language
            const Row(children: [
              Icon(Icons.language),
              Text('Change Language'),
            ])
          ],
        ),
      ),
    );
  }
}
