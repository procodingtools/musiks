import 'dart:convert';

import 'package:musiks/utils/entities/radio.dart';
import 'package:musiks/utils/web_service/nrj_service/radios_links.dart';
import 'package:dio/dio.dart';


class NRJRadioWebService{

  Future<List<Radio>> getRadios() async {
    List<Radio> radios = List();
    try{
      final result = await Dio().get(RadiosLinks.NRJ_LINK);
      if (result.statusCode == 200){
        Map<String, dynamic> response = json.decode(result.data);
        final logoUrl = response["radio_pics"] + "mobile_1/";
        for (Map<String, dynamic>radio in response["webradios"])
          radios.add(Radio(data: {
            "name": radio['name'],
            "id": radio['id'],
            "logo": logoUrl + radio['logo'],
            "url": radio['url_128k_mp3'],
            "of": "nrj"
          }));
        return radios;
      }
      return null;
    }catch (e) {
      return null;
    }
  }
}