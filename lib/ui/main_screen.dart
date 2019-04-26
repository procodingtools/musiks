import 'dart:io' as IO;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musiks/ui/custom_widgets/player_bottom_sheet.dart';
import 'package:musiks/ui/grid_items.dart';
import 'package:musiks/ui/list_items.dart';
import 'package:musiks/utils/blocs/player_bloc/player_bloc.dart';
import 'package:musiks/utils/blocs/player_bloc/player_event.dart';
import 'package:musiks/utils/blocs/player_bloc/player_state.dart';
import 'package:musiks/utils/res/app_colors.dart';
import 'package:musiks/utils/res/dimens.dart';
import 'package:musiks/utils/utils.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _playerBloc = PlayerBloc();



    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));

    _dropdownAnim = Tween(begin: 1.0, end: .0).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(.0, .5, curve: Curves.easeOut)));

    _firstPagerAnim = Tween(begin: 1.0, end: .0).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(.1, .6, curve: Curves.easeOut)));

    _animationController.forward();
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

          return Scaffold(
              key: _scaffoldKey,
              body: Container(
                width: Dimens.width,
                height: Dimens.height,
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
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                      child: SafeArea(
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
                    ),
                    PlayerBottomSheet(tickerProvider: this, bloc: _playerBloc, overrideBackBtn: true,)
                  ],
                ),
              ));
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

}

