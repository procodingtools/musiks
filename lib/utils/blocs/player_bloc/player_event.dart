import 'package:flute_music_player/flute_music_player.dart';

class PlayerEvent{}


class SetIsPlaying extends PlayerEvent{
  final bool isPlaying;

  SetIsPlaying(this.isPlaying);
}

class SetCurrentSong extends PlayerEvent{
  final Song song;

  SetCurrentSong(this.song);
}

class SetSongsList extends PlayerEvent{
  final List<Song> songs;

  SetSongsList(this.songs);
}

class ToggleShuffle extends PlayerEvent{}

class SetRepeatType extends PlayerEvent{
  final int repeat;

  SetRepeatType(this.repeat);

}

class ExpandBottomSheet extends PlayerEvent{
  final bool expand;

  ExpandBottomSheet(this.expand);
}

