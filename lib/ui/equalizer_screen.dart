import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:musiks/utils/res/dimens.dart';
import 'package:musiks/utils/utils.dart';

class EqualizerScreen extends StatefulWidget {
  createState() => _EqualizerState();
}

class _EqualizerState extends State<EqualizerScreen> {
  Map<int, String> _presets;
  Map<int, int> _bands;
  bool _isEqEnabled;
  List<int> _bandsLevels;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isEqEnabled = false;
    _bandsLevels = List();
    _bands = Map();
    _presets = Map();

    Utils.audioPlayer.setOnBandsListener((bands) {
      setState(() {
        print("bands:  $_bands");
        for (int i = 0; i < bands.length; i++) {
          _bandsLevels.add(bands[i]);
        }
        print("size is   ${_bands.length}");
      });
    });

    Utils.audioPlayer.setOnPresetsListener((presets) {
      print("presets:   $presets");
      setState(() {
        _presets.addAll(presets);
      });
    });

    Utils.audioPlayer.setOnEqEnabledListener((isEnabled) {
      print("is eq enabled:   $isEnabled");
      _isEqEnabled = isEnabled;
    });

    Utils.audioPlayer.getEqStatus();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.purple,
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: Dimens.height*.8,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Transform.rotate(
                    alignment: FractionalOffset.center,
                    // Rotate sliders by 90 degrees
                    angle: -1.57079633,
                    child: Container(
                      child: Slider(
                        value: _bandsLevels[index] + .0,
                        onChanged: (val) {
                          setState(() {
                            _bandsLevels[index] = val.round();
                          });
                        },
                        max: 1000.0,
                        min: 0.0,
                      ),
                    ),
                  );
                },
                itemCount: _bandsLevels.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
