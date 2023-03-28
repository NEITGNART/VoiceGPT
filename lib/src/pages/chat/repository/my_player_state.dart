import 'package:audioplayers/audioplayers.dart';

void myPlayerListener(PlayerState s) {
  if (s == PlayerState.stopped || s == PlayerState.completed) {
    // do something
  }
}
