import 'package:flute_music_player/flute_music_player.dart';

class PlayerState {
  bool isPlaying;
  Song currentSong;
  List<Song> songs;
  int repeatType;
  bool shuffle, bottomSheetExpanded;


  PlayerState._();

  factory PlayerState.init() {
    return PlayerState._()
      ..isPlaying = false
      ..currentSong = null
      ..songs = List()
      ..repeatType = 0
      ..bottomSheetExpanded = false
      ..shuffle = false;
  }
}
