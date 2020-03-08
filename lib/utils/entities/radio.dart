import 'package:musiks/utils/entities/media.dart';

class Radio implements Media{
  int _id;
  String _title;
  String _logo;
  String _of;
  String _url;

  Radio({Map<String, dynamic> data}){
    if (data != null){
      this._id = data['id'];
      this._title = data['name'];
      this._logo = data['logo'];
      this._url = data['url'];
      this._of = data['of'];
    }
  }


  String get of => _of;

  set of(String value) {
    _of = value;
  }

  String get url => _url;

  set url(String value) {
    _url = value;
  }

  String get logo => _logo;

  set logo(String value) {
    _logo = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }


}