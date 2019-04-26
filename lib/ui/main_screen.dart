import 'dart:math';
import 'dart:ui';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:musiks/ui/grid_items.dart';
import 'package:musiks/ui/list_items.dart';
import 'package:musiks/ui/custom_widgets/scrollable_text.dart';
import 'package:musiks/utils/blocs/player_bloc/player_bloc.dart';
import 'package:musiks/utils/blocs/player_bloc/player_event.dart';
import 'package:musiks/utils/blocs/player_bloc/player_state.dart';
import 'package:musiks/utils/res/app_colors.dart';
import 'package:rubber/rubber.dart';
import 'package:musiks/utils/res/dimens.dart';
import 'package:musiks/utils/utils.dart';
import 'dart:io' as IO;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:media_notification/media_notification.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  final PlayerBloc playerBloc;

  const MainScreen({Key key, this.playerBloc}) : super(key: key);

  createState() => _MainState();
}

class _MainState extends State<MainScreen> with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation _dropdownAnim, _firstPagerAnim;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PlayerBloc _playerBloc;
  RubberAnimationController _rubberController;
  AnimationController _vinylRotationController;

  double _sliderValue = .0;
  final _audioPlayer = Utils.audioPlayer;
  PlayerState _playerState;
  Animation _vinylRotationAnim;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _playerBloc = PlayerBloc();
    _playerState = _playerBloc.currentState;

    _rubberController = RubberAnimationController(
      vsync: this,
      lowerBoundValue: AnimationControllerValue(percentage: 0.13),
      //upperBoundValue: AnimationControllerValue(pixel: 100),
      upperBoundValue: AnimationControllerValue(percentage: 1.0),
      duration: Duration(milliseconds: 100),
    );

    //init vinyl animation
    _vinylRotationController =
        AnimationController(vsync: this, duration: Duration(seconds: 11));

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));

    _dropdownAnim = Tween(begin: 1.0, end: .0).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(.0, .5, curve: Curves.easeOut)));

    _firstPagerAnim = Tween(begin: 1.0, end: .0).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(.1, .6, curve: Curves.easeOut)));

    _animationController.forward();


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

    _setMediaNotificationsListeners();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    _playerBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocBuilder<PlayerEvent, PlayerState>(
        bloc: _playerBloc,
        builder: (context, state) {

          if (state.isPlaying)
            _vinylRotationController.repeat();
          else
            _vinylRotationController.stop();

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
                  key: _scaffoldKey,
                  body: Container(
                    width: Dimens.width,
                    height: Dimens.height,
                    padding: EdgeInsets.only(top: 20.0),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage(
                        'assets/background.png',
                      ),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    )),
                    child: Stack(
                      children: <Widget>[
                        SafeArea(
                          child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Transform(
                                        transform: Matrix4.translationValues(
                                            .0, -30 * _dropdownAnim.value, .0),
                                        child: Opacity(
                                          opacity:
                                              (1 - _dropdownAnim.value).abs(),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  "My albums",
                                                  style: TextStyle(
                                                      color: AppColors.white,
                                                      fontFamily: 'montserrat',
                                                      fontSize: 30.0),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    GridItems(
                                                                      from:
                                                                          "My albums",
                                                                      bloc:
                                                                          _playerBloc,
                                                                      player: _bottomSheet(state),
                                                                      items: Songs
                                                                          .albums,
                                                                      photos: Songs
                                                                          .albumArts,
                                                                    )));
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Icon(
                                                      FontAwesomeIcons.thLarge,
                                                      size: 20.0,
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Transform(
                                        transform: Matrix4.translationValues(
                                            100 * _firstPagerAnim.value,
                                            .0,
                                            .0),
                                        child: Opacity(
                                          opacity:
                                              (1 - _firstPagerAnim.value).abs(),
                                          child: _buildList(
                                              from: "My albums",
                                              itemsList: Songs.albums,
                                              photos: Songs.albumArts),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: Dimens.height * .05),
                                        child: Transform(
                                          transform: Matrix4.translationValues(
                                              .0,
                                              -30 * _dropdownAnim.value,
                                              .0),
                                          child: Opacity(
                                            opacity:
                                                (1 - _dropdownAnim.value).abs(),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.max,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    'Artists',
                                                    style: TextStyle(
                                                        color: AppColors.white,
                                                        fontFamily:
                                                            'montserrat',
                                                        fontSize: 30.0),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      GridItems(
                                                                        from:
                                                                            'artists',
                                                                        items: Songs
                                                                            .artists,
                                                                        player: _bottomSheet(state),
                                                                        bloc:
                                                                            _playerBloc,
                                                                        photos:
                                                                            Songs.artistsArt,
                                                                      )));
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: Icon(
                                                        FontAwesomeIcons
                                                            .thLarge,
                                                        size: 20.0,
                                                        color: AppColors.white,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Transform(
                                        transform: Matrix4.translationValues(
                                            100 * _firstPagerAnim.value,
                                            .0,
                                            .0),
                                        child: Opacity(
                                          opacity:
                                              (1 - _firstPagerAnim.value).abs(),
                                          child: _buildList(
                                              from: 'artists',
                                              itemsList: Songs.artists,
                                              photos: Songs.artistsArt),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ),
                        _bottomSheet(state)
                      ],
                    ),
                  )));
        });
  }

  Widget _buildList(
      {List<String> itemsList, Map<String, String> photos, String from}) {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      height: Dimens.height * .3,
      padding: EdgeInsets.only(top: 8.0),
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        controller: PageController(initialPage: 0, viewportFraction: .55),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: (() => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ListItems(
                      item: itemsList[index],
                      player: _bottomSheet(_playerState),
                      from: from,
                      bloc: _playerBloc,
                    )))),
            child: Container(
              margin: EdgeInsets.only(right: 10.0),
              child: Hero(
                tag: from + index.toString(),
                child: Card(
                  color: Colors.grey,
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  clipBehavior: Clip.antiAlias,
                  child: Material(
                    child: Stack(
                      children: <Widget>[
                        Hero(
                            tag: itemsList[index],
                            child: Center(
                              child: photos[itemsList[index]] != null
                                  ? Image.file(
                                      IO.File(photos[itemsList[index]]),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/musiks_disk_sticker.png',
                                      fit: BoxFit.contain,
                                    ),
                            )),
                        DecoratedBox(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 20.0),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  itemsList[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'montserrat',
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [Colors.black, Colors.transparent],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: itemsList.length,
      ),
    );
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

  _setMediaNotificationsListeners() {
    MediaNotification.setListener('pause', () {
      setState(() {
        _playerBloc.dispatch(SetIsPlaying(false));
      });
      Utils.audioPlayer.pause();
    });

    MediaNotification.setListener('play', () {
      setState(() {
        _playerBloc.dispatch(SetIsPlaying(true));
      });
      Utils.audioPlayer.play(_playerBloc.currentState.currentSong.uri);
    });

    MediaNotification.setListener('next', () {});

    MediaNotification.setListener('prev', () {});

    MediaNotification.setListener('select', () {});
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

