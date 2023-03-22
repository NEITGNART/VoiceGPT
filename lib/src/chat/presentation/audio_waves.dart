import 'package:audio_wave/audio_wave.dart';
import 'package:flutter/material.dart';

class MyAudioWave extends StatelessWidget {
  const MyAudioWave({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return AudioWave(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.5,
      spacing: 2,
      bars: [
        AudioWaveBar(heightFactor: 1, color: Colors.lightBlueAccent),
        AudioWaveBar(heightFactor: 0.9, color: Colors.blue),
        AudioWaveBar(heightFactor: 0.8, color: Colors.black),
        AudioWaveBar(heightFactor: 0.7),
        AudioWaveBar(heightFactor: 0.6, color: Colors.orange),
        AudioWaveBar(heightFactor: 0.5, color: Colors.lightBlueAccent),
        AudioWaveBar(heightFactor: 0.4, color: Colors.blue),
        AudioWaveBar(heightFactor: 0.3, color: Colors.black),
        AudioWaveBar(heightFactor: 0.2),
        AudioWaveBar(heightFactor: 0.1, color: Colors.orange),
        AudioWaveBar(heightFactor: 1, color: Colors.lightBlueAccent),
        AudioWaveBar(heightFactor: 0.1, color: Colors.blue),
        AudioWaveBar(heightFactor: 0.2, color: Colors.black),
        AudioWaveBar(heightFactor: 0.3),
        AudioWaveBar(heightFactor: 0.4, color: Colors.orange),
        AudioWaveBar(heightFactor: 0.5, color: Colors.lightBlueAccent),
        AudioWaveBar(heightFactor: 0.6, color: Colors.blue),
        AudioWaveBar(heightFactor: 0.7, color: Colors.black),
        AudioWaveBar(heightFactor: 0.8),
        AudioWaveBar(heightFactor: 0.9, color: Colors.orange),
      ],
    );
  }
}
