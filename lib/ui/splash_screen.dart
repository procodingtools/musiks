import 'dart:ui';

import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musiks/ui/main_screen.dart';
import 'package:musiks/utils/blocs/player_bloc/player_bloc.dart';
import 'package:musiks/utils/blocs/player_bloc/player_event.dart';
import 'package:musiks/utils/res/dimens.dart';
import 'package:musiks/utils/utils.dart';
import 'package:simple_permissions/simple_permissions.dart' as Perm;
import 'package:image/image.dart' as ImConvert;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io' as IO;
import 'package:media_notification/media_notification.dart';

class SplashScreen extends StatefulWidget {
  createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation _rightPartAnim, _leftPartAnim, _noteAnim, _textAnim;
  double _width, _height;
  Set<String> _albums = Set(), _artists = Set(), _dirs = Set();
  Map<String, String> _albumArts = Map();

  List<Perm.Permission> permissions = [
    Perm.Permission.RecordAudio,
    Perm.Permission.Camera,
    Perm.Permission.ReadExternalStorage,
    Perm.Permission.WriteExternalStorage,
  ];

  bool _soundsCompleted = false;
  final _playerBloc = PlayerBloc();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    _leftPartAnim = Tween(begin: .0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(.0, .3, curve: Curves.easeOutBack)));

    _rightPartAnim = Tween(begin: .0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(.15, .6, curve: Curves.easeOutBack)));

    _noteAnim = Tween(begin: .0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(.2, 0.7, curve: Curves.easeOutBack)));

    _textAnim = Tween(begin: .0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(.5, 1.0, curve: Curves.easeOutBack)));

    Future.delayed(Duration(seconds: 1)).then((_) => _controller.forward());

    Utils.audioPlayer = MusicFinder();

    _getSongs();

    Future.delayed(Duration(seconds: 6)).then((_) {
      if (_soundsCompleted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    Dimens.width = _width;
    Dimens.height = _height;

    return Scaffold(
      body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return DecoratedBox(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                "assets/background.png",
              ), fit: BoxFit.cover,        alignment: Alignment.topCenter,
                  )),
              child: _animatedLogo(),
            );
          }),
    );
  }

  _resizePhoto(String path) async {
    if (path != null) {
      final image = ImConvert.decodeImage(new IO.File(path).readAsBytesSync());
      final thumbnail = ImConvert.copyResize(image, 300, 300);
      new IO.File(path)..writeAsBytesSync(ImConvert.encodePng(thumbnail));
    }
  }

  Widget _animatedLogo() {
    return Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Transform.scale(
                        scale: _leftPartAnim.value,
                        child: Image.asset(
                          "assets/left_part.png",
                          width: _width * .15,
                        )),
                    Transform.scale(
                      scale: _rightPartAnim.value,
                      child: Image.asset(
                        "assets/right_part.png",
                        width: _width * .15,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: Transform.scale(
                    scale: _noteAnim.value,
                    child: Image.asset(
                      "assets/note.png",
                      width: _width * .15,
                    ),
                  ),
                )
              ],
            ),
            Transform(
                transform: Matrix4.translationValues(
                    .0, 10 - (10 * _textAnim.value), .0),
                child: Opacity(
                  opacity: _textAnim.value > 1 ? 1 : _textAnim.value,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text(
                      "Listen to the beauty",
                      style: TextStyle(
                          color: Colors.grey, fontFamily: "montserrat"),
                    ),
                  ),
                ))
          ],
        )));
  }

  requestPermission() async {
    final res =
        await Perm.SimplePermissions.requestPermission(Perm.Permission.Camera);
  }

  checkPermission() async {
    bool res =
        await Perm.SimplePermissions.checkPermission(Perm.Permission.Camera);
  }

  _getSongs() {
    MusicFinder.allSongs().then((songs) {
      Utils.songs = songs;
      for (Song song in songs) {
        //_resizePhoto(song.albumArt);
        _albums.add(song.album);
        _artists.add(song.artist);
        _dirs.add(song.uri.substring(0, song.uri.lastIndexOf('/')));
        if (song.albumArt != null) {
          _albumArts[song.album] = song.albumArt;
          if (!Songs.artistsArt.containsKey(song.albumArt))
            Songs.artistsArt[song.artist] = song.albumArt;
        }
      }

      _albums.forEach((str) => Songs.albums.add(str));
      _artists.forEach((str) => Songs.artists.add(str));
      _dirs.forEach((str) => Songs.dirs.add(str));
      Songs.albumArts = _albumArts;

      setState(() {
        _soundsCompleted = true;
      });
      if (_controller.status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainScreen(playerBloc: _playerBloc)));
      }
    });
  }
}
