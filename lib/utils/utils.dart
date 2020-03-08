import 'package:flute_music_player/flute_music_player.dart';
import 'package:media_notification/media_notification.dart';
import 'package:musiks/utils/entities/media.dart';
import 'package:musiks/utils/entities/radio_station.dart';



class Utils{
  static MusicFinder audioPlayer;
  static List<Song> songs;
  static List<RadioStation> radios = List();

  static Future<void> hideNotif() async {
    try {
      await MediaNotification.hide();
    } catch (e) {

    }
  }

  static Future<void> showNotif(String title, String author, bool isPlaying) async {
    try {
      await MediaNotification.show(title: title, author: author, play: isPlaying);
    } catch (e) {

    }
  }

}

class Songs{
  static List<String> albums = List(), artists = List(), dirs = List();
  static Map<String, String> albumArts, artistsArt = Map(), radioPhotos = Map();
}