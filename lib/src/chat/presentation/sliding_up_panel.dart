import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ChatPanel extends StatelessWidget {
  const ChatPanel({
    super.key,
    required PanelController pc,
  }) : _pc = pc;

  final PanelController _pc;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            _pc.close();
          },
          child: const Row(
            children: [
              Icon(Icons.voice_chat),
              SizedBox(
                width: 10,
              ),
              Text(
                'Play with voice',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        const Row(
          children: [
            Icon(Icons.copy),
            SizedBox(
              width: 10,
            ),
            Text(
              'Copy message',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        const Row(
          children: [
            Icon(Icons.share),
            SizedBox(
              width: 10,
            ),
            Text(
              'Share answer',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
