import 'package:bloc/bloc.dart';
import 'package:musiks/utils/blocs/player_bloc/player_event.dart';
import 'package:musiks/utils/blocs/player_bloc/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState>{

  @override
  // TODO: implement initialState
  PlayerState get initialState => PlayerState.init();

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async*{
    if (event is SetIsPlaying)
      yield currentState..isPlaying = event.isPlaying;
    else if (event is SetCurrentSong)
      yield currentState..currentSong = event.song;
    else if (event is SetSongsList)
      yield currentState..songs = event.songs;
    else if(event is ToggleShuffle)
      currentState..shuffle = !currentState.shuffle;
    else if (event is SetRepeatType)
      yield currentState..repeatType = event.repeat;
    else if (event is ExpandBottomSheet)
      yield currentState..bottomSheetExpanded = event.expand;
  }

}