import 'dart:io' as IO;
import 'dart:ui';

import 'package:date_format/date_format.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:musiks/ui/custom_widgets/player_bottom_sheet.dart';
import 'package:musiks/ui/custom_widgets/scrollable_text.dart';
import 'package:musiks/utils/blocs/player_bloc/player_bloc.dart';
import 'package:musiks/utils/blocs/player_bloc/player_event.dart';
import 'package:musiks/utils/res/app_colors.dart';
import 'package:musiks/utils/res/dimens.dart';
import 'package:musiks/utils/utils.dart';

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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _playerBloc = widget.bloc;

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
    }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
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
          PlayerBottomSheet(tickerProvider: this, bloc: _playerBloc,),
        ],
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
                setState(() {
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
}
