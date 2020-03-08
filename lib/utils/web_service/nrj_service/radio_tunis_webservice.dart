import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:musiks/utils/entities/radio.dart';
import 'package:musiks/utils/web_service/nrj_service/radios_links.dart';

class RadioTunisWebService{

  Future<List<Radio>> getRadios() async {

      final response = await Dio().get(RadiosLinks.RADIO_TUNIS_LINKS);
      if (response.statusCode != 200)
        return null;

      List<Radio> radios = List();
      List<dynamic> data = response.data["tra_radio"];
      for (Map<String, dynamic> radio in data) {
        Radio r = Radio();
        r.of = "";
        r.logo = "";
        r.url = radio['url'];
        r.title = radio['libelle'];
        r.id = int.parse(radio['id']);

        radios.add(r);
      }
      return radios;
  }
}