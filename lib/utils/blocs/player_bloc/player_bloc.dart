import 'package:bloc/bloc.dart';
import 'package:musiks/utils/blocs/player_bloc/player_event.dart';
import 'package:musiks/utils/blocs/player_bloc/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState>{

  @override
  // TODO: implement initialState
  PlayerState get initialState => PlayerState.init();

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async*{
    print("event trying to yield:    " + event.toString());
    if (event is SetIsPlaying)
      yield state..isPlaying = event.isPlaying;
    else if (event is SetCurrentSong) {
      print("setted current song is:   " + event.song.toString());
      yield state..currentSong = event.song;
    }
    else if (event is SetSongsList)
      yield state..songs = event.songs;
    else if(event is ToggleShuffle)
      state..shuffle = !state.shuffle;
    else if (event is SetRepeatType)
      yield state..repeatType = event.repeat;
    else if (event is ExpandBottomSheet)
      yield state..bottomSheetExpanded = event.expand;
  }

}