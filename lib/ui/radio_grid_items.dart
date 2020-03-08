import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:musiks/ui/custom_widgets/player_bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:musiks/utils/blocs/player_bloc/player_bloc.dart';
import 'package:musiks/utils/blocs/player_bloc/player_event.dart';
import 'package:musiks/utils/res/app_colors.dart';
import 'package:musiks/utils/res/dimens.dart';
import 'package:musiks/utils/entities/media.dart' as R;
import 'package:musiks/utils/utils.dart';
import 'package:musiks/utils/web_service/nrj_service/nrj_radio_webservice.dart';
import 'package:musiks/utils/web_service/nrj_service/radio_tunis_webservice.dart';

class RadioGridItems extends StatefulWidget{
  final String radioName;
  final PlayerBloc bloc;
  const RadioGridItems({Key key, this.radioName, this.bloc}) : super(key: key);

  createState() => _RadioGridItemsState();
}

class _RadioGridItemsState extends State<RadioGridItems> with TickerProviderStateMixin{

  PlayerBloc _playerBloc;
  List<R.Media> _radios;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _playerBloc = widget.bloc;
    _radios = List();

    if (widget.radioName == "NRJ")
      NRJRadioWebService().getRadios().then((radios){
        if (radios != null){
          setState(() {
            _radios.addAll(radios);
          });
        }
      });
    else
      RadioTunisWebService().getRadios().then((radios) {
        setState(() {
          _radios.addAll(radios);
        });
      });
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
                                widget.radioName,
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
                              children: List.generate(_radios.length, (index) {
                                return Card(
                                  color: Colors.grey,
                                  elevation: 5.0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)),
                                  clipBehavior: Clip.antiAlias,
                                  child: InkWell(
                                    onTap: () {
                                      //TODO: play selected radio

                                      _playerBloc.dispatch(SetCurrentSong(_radios[index]));
                                      _playerBloc.dispatch(SetIsPlaying(true));
                                      _playerBloc.dispatch(SetSongsList(null));
                                      Utils.audioPlayer.stop();
                                      Utils.audioPlayer.play(_radios[index].url, isLocal: false);
                                      Utils.showNotif(
                                          _radios[index].title, _radios[index].of, true);
                                      setState(() {});
                                    },
                                    child: Material(
                                      child: Stack(
                                        children: <Widget>[
                                          Center(
                                            child: CachedNetworkImage(
                                              imageUrl: _radios[index].logo,
                                              fit: BoxFit.cover,
                                              height: Dimens.height * .3,
                                              width: Dimens.height * .3,
                                            )
                                          ),
                                          DecoratedBox(
                                              child: Padding(
                                                padding:
                                                EdgeInsets.only(bottom: 20.0),
                                                child: Align(
                                                  alignment:
                                                  Alignment.bottomCenter,
                                                  child: Text(
                                                    _radios[index].title,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: 'montserrat',
                                                      color: Colors.white,//AppColors.white,
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
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),

            PlayerBottomSheet(vsync: this, bloc: _playerBloc,),
          ],
        ));
  }

}