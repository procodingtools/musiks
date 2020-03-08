import 'dart:io' as IO;
import 'dart:math';
import 'dart:ui';

import 'package:date_format/date_format.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:media_notification/media_notification.dart';
import 'package:musiks/ui/custom_widgets/scrollable_text.dart';
import 'package:musiks/utils/blocs/player_bloc/player_bloc.dart';
import 'package:musiks/utils/blocs/player_bloc/player_event.dart';
import 'package:musiks/utils/blocs/player_bloc/player_state.dart';
import 'package:musiks/utils/res/app_colors.dart';
import 'package:musiks/utils/res/dimens.dart';
import 'package:musiks/utils/utils.dart';
import 'package:rubber/rubber.dart';
import 'package:musiks/utils/entities/media.dart' as R;
import 'package:flutter_advanced_networkimage/provider.dart';

class PlayerBottomSheet extends StatefulWidget {
  final TickerProvider vsync;
  final PlayerBloc bloc;
  final bool overrideBackBtn;

  const PlayerBottomSheet({
    Key key,
    @required this.vsync,
    @required this.bloc,
    this.overrideBackBtn: false,
  }) : super(key: key);

  createState() => _PlayerBottomSheetState();
}

class _PlayerBottomSheetState extends State<PlayerBottomSheet> {
  RubberAnimationController _rubberController;
  AnimationController _vinylRotationController;

  double _sliderValue = .0;
  final _audioPlayer = Utils.audioPlayer;
  Animation _vinylRotationAnim;
  PlayerBloc _playerBloc;
  final _moveTaskToBackChannel = MethodChannel("android_app_retain");

  @override
  void dispose() {
    // TODO: implement dispose
    //_rubberController.dispose();
    _vinylRotationController.dispose();
    //_playerBloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //init bloc
    _playerBloc = widget.bloc;

    _rubberController = RubberAnimationController(
      vsync: widget.vsync,
      lowerBoundValue: AnimationControllerValue(percentage: 0.13),
      //upperBoundValue: AnimationControllerValue(pixel: 100),
      upperBoundValue: AnimationControllerValue(percentage: 1),
      duration: Duration(milliseconds: 100),
    );

    //init vinyl animation
    _vinylRotationController = AnimationController(
        vsync: widget.vsync, duration: Duration(seconds: 11));

    _rubberController.addListener(() {
      setState(() {
        if (_rubberController.value > .2)
          _playerBloc.add(ExpandBottomSheet(true));
        else
          _playerBloc.add(ExpandBottomSheet(false));
      });
    });

    _vinylRotationAnim =
        Tween(begin: .0, end: 6.28319).animate(_vinylRotationController);

    _setMediaNotificationsListeners();

    Utils.audioPlayer.setOnHeadsetButtonClick((action) {
      if (action == 1)
        _playPause(_playerBloc.state);
      else if (action == 2)
        _nextSong(_playerBloc.state);
      else if (action == 3) _previousSong(_playerBloc.state);
    });

    Utils.audioPlayer.setOnHeadsetPlugListener((status){
      if (!status && _playerBloc.state.isPlaying)
        _playPause(_playerBloc.state);
        //_playerBloc.add(SetIsPlaying(!status));
    });
  }

  void _setAudioPlayerListeners(PlayerState state) {
    Utils.audioPlayer.setPositionHandler((duration) {
      setState(() {
        _sliderValue = duration.inMilliseconds + .0;
      });
    });

    Utils.audioPlayer.setCompletionHandler(() {
      setState(() {
        if (state.repeatType == 1)
          _playAt(state.songs.indexOf(state.currentSong), state);
        else if (!state.shuffle)
          _nextSong(state, block: true);
        else
          _playAt(Random().nextInt(state.songs.length), state);
      });
    });
  }

  _setMediaNotificationsListeners() {
    MediaNotification.setListener('pause', () {
      print("pause");
      setState(() {
        _playerBloc.add(SetIsPlaying(false));
      });
      Utils.audioPlayer.pause();
    });

    MediaNotification.setListener('play', () {
      setState(() {
        _playerBloc.add(SetIsPlaying(true));
      });
      if (_playerBloc.state.currentSong is Song)
        Utils.audioPlayer.play(
          _playerBloc.state.currentSong.uri,
        );
      else if (_playerBloc.state.currentSong is R.Media)
        Utils.audioPlayer
            .play(_playerBloc.state.currentSong.url, isLocal: false);
    });

    MediaNotification.setListener('next', () {
      print('next');
      _nextSong(_playerBloc.state);
    });

    MediaNotification.setListener('prev', () {
      _previousSong(_playerBloc.state);
    });

    MediaNotification.setListener('select', () {});
  }

  void _nextSong(PlayerState state, {bool block: false}) {
    int index = state.songs.indexOf(state.currentSong);

    if (block) {
      if (index + 1 == state.songs.length) {
        if (state.repeatType == 2) {
          Utils.audioPlayer.stop();
          Utils.hideNotif();
          setState(() {
            _playerBloc.add(SetIsPlaying(false));
          });
          return;
        } else if (state.repeatType == 0) index = 0;
      } else if (state.repeatType != 1) index++;
    } else {
      if (index + 1 == state.songs.length)
        index = 0;
      else
        index++;
    }

    Utils.audioPlayer.stop();
    state.currentSong = state.songs[index];
    Utils.audioPlayer.play(state.currentSong.uri);
    MediaNotification.show(
        title: state.currentSong.title, author: state.currentSong.album);
  }

  void _playAt(int index, PlayerState state) {
    Utils.audioPlayer.stop();
    state.currentSong = state.songs[index];
    Utils.audioPlayer.play(state.currentSong.uri);
    MediaNotification.show(
        title: state.currentSong.title, author: state.currentSong.album);
  }

  void _previousSong(PlayerState state) {
    int index = state.songs.indexOf(state.currentSong);
    if (index == 0)
      index = state.songs.length - 1;
    else
      index--;

    Utils.audioPlayer.stop();
    state.currentSong = state.songs[index];
    Utils.audioPlayer.play(state.currentSong.uri);
    MediaNotification.show(
        title: state.currentSong.title, author: state.currentSong.album);
  }

  @override
  Widget build(BuildContext context) {
    _setAudioPlayerListeners(_playerBloc.state);
    if (_playerBloc.state.isPlaying)
      _vinylRotationController.repeat();
    else
      _vinylRotationController.stop();

    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        if (_rubberController.value > .19)
          _rubberController.collapse();
        else {
          if (!widget.overrideBackBtn) Navigator.pop(context);
          else {
            _moveTaskToBackChannel.invokeMethod("sendToBackground");
            return Future.value(false);
          }
        }
      },
      child: RubberBottomSheet(
        animationController: _rubberController,
        lowerLayer: Container(),
        //header: Container(color: Colors.green,),
        upperLayer: _renderBottomSheet(_playerBloc.state),
      ),
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
                _rubberController.value > 0.15 ? .0 : 8.0,
              ),
              child: IndexedStack(
                index: _rubberController.value > 0.15 ? 1 : 0,
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
    return InkWell(
      onTap: () {
          _rubberController.expand();
          _playerBloc.add(ExpandBottomSheet(true));
      },
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              width: 50.0,
              height: 50.0,
              child: CircleAvatar(
                backgroundColor: AppColors.purple,
                backgroundImage: state.currentSong != null
                    ? state.currentSong is Song
                        ? state.currentSong?.albumArt != null
                            ? FileImage(IO.File(state.currentSong.albumArt))
                            : AssetImage("assets/musiks_disk_sticker.png")
                        : AdvancedNetworkImage(
                            state.currentSong?.logo,
                            useDiskCache: true,
                          )
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
      ),
    );
  }

  Widget _renderBottomSheetContent(PlayerState state) {
    return Container(
      //width: double.infinity,
      height: MediaQuery.of(context).size.height * _rubberController.value,
      decoration: BoxDecoration(
        color: AppColors.purple,
        image: DecorationImage(
            image: state.currentSong != null
                ? state.currentSong is Song
                    ? state.currentSong?.albumArt != null
                        ? FileImage(IO.File(state.currentSong.albumArt))
                        : AssetImage("assets/musiks_disk_sticker.png")
                    : AdvancedNetworkImage(
                        state.currentSong?.logo,
                        useDiskCache: true,
                      )
                : AssetImage("assets/musiks_disk_sticker.png"),
            fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(color: Colors.black26, ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaY: _rubberController.value * 20.0, sigmaX: _rubberController.value * 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
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
                            max: state.currentSong != null
                                ? state.currentSong is R.Media
                                    ? 1.0
                                    : double.parse(
                                        '${state.currentSong?.duration}')
                                : 1.0,
                            activeColor: AppColors.white,
                            inactiveColor: AppColors.white,
                            value: state.currentSong is R.Media ? .0 : _sliderValue,
                            onChanged: (v) {
                              if (state.currentSong != null)
                                if (state.currentSong is Song)
                                setState(() {
                                  _sliderValue = v;
                                  Utils.audioPlayer.seek(v / 1000);
                                });
                            }),
                      ),
                      SizedBox(
                        child: _renderDuration(state),
                        width: Dimens.width * .09,
                      )
                    ],
                  ),
                ),
                _renderBottomSheetButtons(state),
                Expanded(child: Container()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderRotatedVinyl(PlayerState state) {
    return Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
        ),
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
                          backgroundColor: AppColors.purple,
                          backgroundImage: state.currentSong != null
                              ? state.currentSong is Song
                              ? state.currentSong?.albumArt != null
                              ? FileImage(IO.File(state.currentSong.albumArt))
                              : AssetImage("assets/musiks_disk_sticker.png")
                              : AdvancedNetworkImage(
                            state.currentSong?.logo,
                            useDiskCache: true,
                          )
                              : AssetImage("assets/musiks_disk_sticker.png"),
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
              if (! (state.currentSong is R.Media)) {
                int repeatType = state.repeatType;
                if (repeatType == 2)
                  repeatType = 0;
                else
                  repeatType++;
                setState(() {
                  _playerBloc.add(SetRepeatType(repeatType));
                });
              }
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
                color: state.currentSong is R.Media ? Colors.black38 : null,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () => _previousSong(state),
                child: Image.asset(
                  "assets/previews.png",
                  width: 40,
                  fit: BoxFit.fill,
                  color: state.currentSong is R.Media ? Colors.black38 : null,
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
                onTap: () => _nextSong(state),
                child: Image.asset(
                  "assets/next.png",
                  width: 40,
                  fit: BoxFit.fill,
                  color: state.currentSong is R.Media ? Colors.black38 : null,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              if (state.currentSong is Song)
              setState(() {
                _playerBloc.add(ToggleShuffle());
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                state.shuffle ? "assets/random.png" : "assets/equal.png",
                width: 20,
                fit: BoxFit.fill,
                color: state.currentSong is R.Media ? Colors.black38 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderDuration(PlayerState state) {
    DateTime date;
    if (state.currentSong != null)
      date = DateTime(
        0,
        0,
        0,
        0,
        0,
        0,
      ).add(Duration(milliseconds: state.currentSong is Song ? state.currentSong.duration : 0));
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
        _playerBloc.add(SetIsPlaying(true));
        Utils.showNotif(state.currentSong.title, state.currentSong is Song ? state.currentSong.album : state.currentSong.of, true);
        _audioPlayer.play( state.currentSong is Song ? state.currentSong.uri : state.currentSong.url);
        _vinylRotationController.repeat();
      } else if (state.isPlaying) {
        _playerBloc.add(SetIsPlaying(false));
        Utils.showNotif(
            state.currentSong.title, state.currentSong is Song ? state.currentSong.album : state.currentSong.of, false);
        _audioPlayer.pause();
        _vinylRotationController.stop();
      }
    });
  }
}
