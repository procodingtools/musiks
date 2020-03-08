class Media {
  int _id;
  String _title;
  String _logo;
  String _url;
  String _of;


  String get url => _url;

  set url(String value) {
    _url = value;
  }


  String get of => _of;

  set of(String value) {
    _of = value;
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