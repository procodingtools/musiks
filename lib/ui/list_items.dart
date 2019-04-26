import 'dart:math';
import 'dart:ui';

import 'package:date_format/date_format.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:media_notification/media_notification.dart';
import 'package:musiks/ui/custom_widgets/scrollable_text.dart';
import 'package:musiks/utils/blocs/player_bloc/player_bloc.dart';
import 'package:musiks/utils/blocs/player_bloc/player_event.dart';
import 'package:musiks/utils/blocs/player_bloc/player_state.dart';
import 'package:musiks/utils/res/app_colors.dart';
import 'package:musiks/utils/res/dimens.dart';
import 'package:musiks/utils/utils.dart';
import 'dart:io' as IO;

import 'package:rubber/rubber.dart';

class ListItems extends StatefulWidget {
  final String item;
  final String from;
  final PlayerBloc bloc;
  final Widget player;

  const ListItems({Key key, this.item, this.from, this.bloc, this.player})
      : super(key: key);

  createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> with TickerProviderStateMixin{
  final _width = Dimens.width, _height = Dimens.height;

  List<Song> _songs = List();
  String _cover = '';
  PlayerBloc _playerBloc;


  double _sliderValue = .0;
  final _audioPlayer = Utils.audioPlayer;
  PlayerState _playerState;
  Song _currentSong;
  Animation _vinylRotationAnim;
  bool _isPlaying;


  RubberAnimationController _rubberController;
  AnimationController _vinylRotationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _playerBloc = widget.bloc;
    _playerState = _playerBloc.currentState;

    if (widget.from == "My albums")
      _cover = Songs.albumArts[widget.item];
    else if (widget.from == 'artists') _cover = Songs.artistsArt[widget.item];

    Utils.songs.forEach((song) {
      if (widget.from == "My albums" && song.album == widget.item)
        _songs.add(song);
      else if (widget.from == "artists" && song.artist == widget.item) {
        _songs.add(song);
      }
    });


    _playerState = _playerBloc.currentState;
    _rubberController = RubberAnimationController(
      vsync: this,
      lowerBoundValue: AnimationControllerValue(percentage: 0.13),
      upperBoundValue: AnimationControllerValue(percentage: 1.0),
      duration: Duration(milliseconds: 100),
    );

    //init vinyl animation
    _vinylRotationController =
        AnimationController(vsync: this, duration: Duration(seconds: 11));

    _rubberController.addListener(() {
      setState(() {
        if (_rubberController.value > .13)
          _playerBloc.dispatch(ExpandBottomSheet(true));
        else
          _playerBloc.dispatch(ExpandBottomSheet(false));
      });
    });

    _vinylRotationAnim =
        Tween(begin: .0, end: 6.28319).animate(_vinylRotationController);

    if (_playerState.isPlaying)
      _vinylRotationController.repeat();

    _isPlaying = false;
    }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        if (_rubberController.value > .13)
          setState(() {
            _playerBloc.dispatch(ExpandBottomSheet(false));
            _rubberController.collapse();
          });
        else
          Navigator.pop(context);
        setState(() {});
      },
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/background.png'))),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: _height * .07, bottom: Dimens.height * .13),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _albumCover(),
                      _renderSongsList(),
                    ],
                  ),
                ),
              ),
            ),
            _bottomSheet(_playerState)
          ],
        ),
      ),
    );
  }

  Widget _albumCover() {
    return SizedBox(
      height: _height * .2,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: AppColors.yellow),
            padding: EdgeInsets.all(2.0),
            child: Hero(
                tag: widget.item,
                child: _cover != null
                    ? Image.file(
                        IO.File(_cover),
                        fit: BoxFit.fill,
                      )
                    : Image.asset(
                        'assets/musiks_disk_sticker.png',
                        fit: BoxFit.contain,
                      )),
          ),
          widget.from == "My albums"
              ? Stack(
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.only(top: 0.0, right: 0.0, bottom: 0.0),
                      child: Center(
                        child: Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(color: AppColors.yellow)),
                      ),
                    ),
                    Image.asset("assets/half_vinyl.png"),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _renderSongsList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0),
        child: ListView.builder(
          itemBuilder: (context, index) {
            final song = _songs[index];
            final duration = DateTime(0, 0, 0, 0, 0, 0, 0)
                .add(Duration(milliseconds: song.duration));
            return InkWell(
              onTap: () {
                _playerBloc.dispatch(SetCurrentSong(song));
                _playerBloc.dispatch(SetIsPlaying(true));
                _playerBloc.dispatch(SetSongsList(_songs));
                Utils.audioPlayer.stop();
                Utils.audioPlayer.play(song.uri);
                Utils.showNotif(song.title, song.album, true);
                _vinylRotationController.repeat();
                setState(() {
                  _currentSong = song;
                  _isPlaying = true;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                margin: EdgeInsets.only(bottom: 5.0),
                color: AppColors.purple,
                height: 80.0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.white),
                      child: CircleAvatar(
                        backgroundImage: song.albumArt != null
                            ? FileImage(IO.File(song.albumArt))
                            : AssetImage("assets/musiks_disk_sticker.png"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: SizedBox(
                          width: _width * .65,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ScrollableText(
                                  child: Text(
                                song.title,
                                style: TextStyle(
                                    color: AppColors.white,
                                    fontFamily: "montserrat",
                                    fontSize: 15.0),
                              )),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  formatDate(duration, [nn, ':', ss]),
                                  style: TextStyle(
                                      color: AppColors.white,
                                      fontFamily: "montserrat",
                                      fontSize: 10.0),
                                ),
                              )
                            ],
                          )),
                    )
                  ],
                ),
              ),
            );
          },
          itemCount: _songs.length,
        ),
      ),
    );
  }




  @override
  void dispose() {
    // TODO: implement dispose
    _rubberController.dispose();
    _vinylRotationController.dispose();
    super.dispose();
  }



  void _setAudioPlayerListeners() {
    Utils.audioPlayer.setPositionHandler((duration) {
      setState(() {
        _sliderValue = duration.inMilliseconds + .0;
      });
    });

    Utils.audioPlayer.setCompletionHandler(() {
      setState(() {
        if (_playerState.repeatType == 1)
          _playAt(_playerState.songs.indexOf(_playerState.currentSong));
        else if (!_playerState.shuffle)
          _nextSong(block: true);
        else
          _playAt(Random().nextInt(_playerState.songs.length));
      });
    });
  }

  void _nextSong({bool block: false}) {
    int index = _playerState.songs.indexOf(_playerState.currentSong);

    if (block) {
      if (index + 1 == _playerState.songs.length) {
        if (_playerState.repeatType == 2) {
          Utils.audioPlayer.stop();
          Utils.hideNotif();
          setState(() {
            _playerBloc.dispatch(SetIsPlaying(false));
          });
          return;
        } else if (_playerState.repeatType == 0) index = 0;
      } else if (_playerState.repeatType != 1) index++;
    } else {
      if (index + 1 == _playerState.songs.length)
        index = 0;
      else
        index++;
    }

    Utils.audioPlayer.stop();
    _playerState.currentSong = _playerState.songs[index];
    Utils.audioPlayer.play(_playerState.currentSong.uri);
    MediaNotification.show(
        title: _playerState.currentSong.title,
        author: _playerState.currentSong.album);
  }

  void _playAt(int index) {
    Utils.audioPlayer.stop();
    _playerState.currentSong = _playerState.songs[index];
    Utils.audioPlayer.play(_playerState.currentSong.uri);
    MediaNotification.show(
        title: _playerState.currentSong.title,
        author: _playerState.currentSong.album);
  }

  void _previousSong() {
    int index = _playerState.songs.indexOf(_playerState.currentSong);
    if (index == 0)
      index = _playerState.songs.length - 1;
    else
      index--;

    Utils.audioPlayer.stop();
    _playerState.currentSong = _playerState.songs[index];
    Utils.audioPlayer.play(_playerState.currentSong.uri);
    MediaNotification.show(
        title: _playerState.currentSong.title,
        author: _playerState.currentSong.album);
  }

  Widget _bottomSheet(PlayerState state) {
    _setAudioPlayerListeners();
    // TODO: implement build
    return RubberBottomSheet(
      animationController: _rubberController,
      lowerLayer: Container(),
      //header: Container(color: Colors.green,),
      upperLayer: _renderBottomSheet(state),
    );
  }

  Widget _renderBottomSheet(PlayerState state) {
    return AnimatedBuilder(
        animation: _rubberController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.purple,
            ),
            child: Padding(
              padding: EdgeInsets.all(
                _rubberController.value > 0.17 ? .0 : 8.0,
              ),
              child: IndexedStack(
                index: _rubberController.value > 0.17 ? 1 : 0,
                children: <Widget>[
                  _renderBottomSheetHeader(state),
                  _renderBottomSheetContent(state),
                ],
              ),
            ),
          );
        });
  }

  Widget _renderBottomSheetHeader(PlayerState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            width: 50.0,
            height: 50.0,
            child: CircleAvatar(
              backgroundImage: state.currentSong?.albumArt != null
                  ? FileImage(IO.File(state.currentSong.albumArt))
                  : AssetImage("assets/musiks_disk_sticker.png"),
            ),
          ),
          SizedBox(
            width: 200.0,
            child: ScrollableText(
                direction: Axis.horizontal,
                animationDuration: Duration(seconds: 10),
                backDuration: Duration(seconds: 8),
                pauseDuration: Duration(seconds: 2),
                child: Text(
                  state.currentSong?.title ?? 'No media',
                  style: TextStyle(
                    color: AppColors.white,
                    fontFamily: 'montserrat',
                  ),
                  maxLines: 1,
                )),
          ),
          InkWell(
            onTap: () {
              _playPause(state);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                state.isPlaying
                    ? FontAwesomeIcons.pauseCircle
                    : FontAwesomeIcons.playCircle,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderBottomSheetContent(PlayerState state) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
            image:
            state.currentSong != null && state.currentSong.albumArt != null
                ? FileImage(IO.File(state.currentSong.albumArt))
                : AssetImage("assets/musiks_disk_sticker.png"),
            fit: BoxFit.cover),
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.black26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 20.0, sigmaX: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 1.0,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(" "),
                    Text(" "),
                  ],
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              _renderRotatedVinyl(state),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  state.currentSong?.title ?? 'No media',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "montserrat",
                      fontSize: 20.0,
                      color: AppColors.white),
                ),
              ),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      child: _renderPositionTime(),
                      width: Dimens.width * .09,
                    ),
                    Expanded(
                      child: Slider(
                          min: .0,
                          max: double.parse(
                              '${state.currentSong?.duration ?? 1.0}'),
                          activeColor: AppColors.white,
                          inactiveColor: AppColors.white,
                          value: _sliderValue,
                          onChanged: (v) {
                            if (state.currentSong != null)
                              setState(() {
                                _sliderValue = v;
                                Utils.audioPlayer.seek(v / 1000);
                              });
                          }),
                    ),
                    SizedBox(
                      child: _renderDuration(),
                      width: Dimens.width * .09,
                    )
                  ],
                ),
              ),
              _renderBottomSheetButtons(state),
              Expanded(child: Container()),
              Text(
                " ",
                style: TextStyle(fontSize: 0.1),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderRotatedVinyl(PlayerState state) {
    return Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.yellow, width: 3.0)),
        height: Dimens.width * .65,
        width: Dimens.width * .65,
        child: AnimatedBuilder(
            animation: _vinylRotationController,
            builder: (context, child) {
              return SizedBox(
                height: Dimens.width * .65,
                width: Dimens.width * .65,
                child: Transform.rotate(
                  angle: _vinylRotationAnim.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/vinyl.png',
                        fit: BoxFit.fill,
                      ),
                      SizedBox(
                        width: Dimens.width * .23,
                        height: Dimens.width * .23,
                        child: CircleAvatar(
                          backgroundImage: state.currentSong != null &&
                              state.currentSong.albumArt != null
                              ? FileImage(IO.File(state.currentSong.albumArt))
                              : AssetImage(
                            "assets/musiks_disk_sticker.png",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  Widget _renderBottomSheetButtons(PlayerState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.width * .05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () {
              int repeatType = state.repeatType;
              if (repeatType == 2)
                repeatType = 0;
              else
                repeatType++;
              setState(() {
                _playerBloc.dispatch(SetRepeatType(repeatType));
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                state.repeatType == 0
                    ? "assets/repeat_all.png"
                    : state.repeatType == 1
                    ? "assets/repeat_one.png"
                    : "assets/no_repeat.png",
                width: 20,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () => _previousSong(),
                child: Image.asset(
                  "assets/previews.png",
                  width: 40,
                  fit: BoxFit.fill,
                ),
              ),
              InkWell(
                onTap: () {
                  _playPause(state);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Image.asset(
                    state.isPlaying ? "assets/pause.png" : "assets/play.png",
                    width: 60,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _nextSong(),
                child: Image.asset(
                  "assets/next.png",
                  width: 40,
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              setState(() {
                _playerBloc.dispatch(ToggleShuffle());
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                state.shuffle ? "assets/random.png" : "assets/equal.png",
                width: 20,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderDuration() {
    DateTime date;
    if (_playerState.currentSong != null)
      date = DateTime(
        0,
        0,
        0,
        0,
        0,
        0,
      ).add(Duration(milliseconds: _playerState.currentSong.duration));
    else
      date = DateTime(
        0,
        0,
        0,
        0,
        0,
        0,
      );

    return Text(
      formatDate(date, [nn, ':', ss]),
      style: TextStyle(
          fontFamily: 'montserrat', color: AppColors.white, fontSize: 10.0),
    );
  }

  Widget _renderPositionTime() {
    DateTime date;
    if (_sliderValue != null)
      date = DateTime(
        0,
        0,
        0,
        0,
        0,
        0,
      ).add(Duration(milliseconds: _sliderValue.truncate()));
    else
      date = DateTime(
        0,
        0,
        0,
        0,
        0,
        0,
      );

    return Text(
      formatDate(date, [nn, ':', ss]),
      style: TextStyle(
          fontFamily: 'montserrat', color: AppColors.white, fontSize: 10.0),
    );
  }

  void _playPause(PlayerState state) {
    setState(() {
      if (!state.isPlaying && state.currentSong != null) {
        _playerBloc.dispatch(SetIsPlaying(true));
        Utils.showNotif(state.currentSong.title, state.currentSong.album, true);
        _audioPlayer.play(state.currentSong.uri);
        _vinylRotationController.repeat();
      } else if (state.isPlaying) {
        _playerBloc.dispatch(SetIsPlaying(false));
        Utils.showNotif(
            state.currentSong.title, state.currentSong.album, false);
        _audioPlayer.pause();
        _vinylRotationController.stop();
      }
    });
  }
}
