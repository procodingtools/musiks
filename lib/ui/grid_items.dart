import 'dart:io' as IO;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musiks/ui/custom_widgets/player_bottom_sheet.dart';
import 'package:musiks/ui/list_items.dart';
import 'package:musiks/utils/blocs/player_bloc/player_bloc.dart';
import 'package:musiks/utils/res/app_colors.dart';
import 'package:musiks/utils/res/dimens.dart';


class GridItems extends StatefulWidget {
  final List<dynamic> items;
  final Map<String, String> photos;
  final String from;
  final Widget player;
  final bloc;

  const GridItems({Key key, this.items, this.photos, this.from, this.bloc, this.player})
      : super(key: key);

  createState() => _GridItemsState();
}

class _GridItemsState extends State<GridItems> with TickerProviderStateMixin{
  PlayerBloc _playerBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _playerBloc = widget.bloc;

  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Stack(
          children: <Widget>[
            Container(
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
              child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: Dimens.height*.13),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                widget.from == "My albums"
                                    ? "My albums"
                                    : "Artists",
                                style: TextStyle(
                                    color: AppColors.white,
                                    fontFamily: 'montserrat',
                                    fontSize: 30.0),
                              ),
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Icon(
                                    FontAwesomeIcons.longArrowAltLeft,
                                    size: 25.0,
                                    color: AppColors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.0),
                            child: GridView.count(
                              crossAxisCount: 2,
                              children: List.generate(widget.items.length, (index) {
                                return Hero(
                                  tag: widget.from + index.toString(),
                                  child: Card(
                                    color: Colors.grey,
                                    elevation: 5.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0)),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ListItems(
                                                  bloc: _playerBloc,
                                                  player: widget.player,
                                                  item: widget.items[index],
                                                  from: widget.from))),
                                      child: Material(
                                        child: Stack(
                                          children: <Widget>[
                                            Hero(
                                                tag: widget.items[index],
                                                child: Center(
                                                  child: widget.photos[widget
                                                      .items[index]] !=
                                                      null
                                                      ? Image.file(
                                                    IO.File(widget.photos[
                                                    widget.items[index]]),
                                                    fit: BoxFit.cover,
                                                  )
                                                      : Image.asset(
                                                    'assets/musiks_disk_sticker.png',
                                                    fit: BoxFit.contain,
                                                  ),
                                                )),
                                            DecoratedBox(
                                                child: Padding(
                                                  padding:
                                                  EdgeInsets.only(bottom: 20.0),
                                                  child: Align(
                                                    alignment:
                                                    Alignment.bottomCenter,
                                                    child: Text(
                                                      widget.items[index],
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
                                                        colors: [
                                                          Colors.black,
                                                          Colors.transparent
                                                        ],
                                                        begin:
                                                        Alignment.bottomCenter,
                                                        end: Alignment.topCenter))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),

            PlayerBottomSheet(tickerProvider: this, bloc: _playerBloc,),
          ],
        ));
  }
}
