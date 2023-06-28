import 'package:video_player/video_player.dart';
import 'dart:math' show min;

class ApiResponse<T> {
  late int code;
  late T data;
  late String msg;

  ApiResponse(this.code, this.data, this.msg);

  static fromMap<E>(Map map) {
    return ApiResponse<E>(map['code'], map['data'], map['msg']);
  }
}

class VideoData {
  late int tid;
  late String name;
  late String note;
  late String subname;
  late String pic;
  late String type;
  late dynamic year;
  late List<VideoSource> dataList;
  late String des;
  String? actor;
  String? area;
  String? director;
  String? lang;
  late String last;
  late dynamic state;
  VideoData(this.tid, this.name, this.note, this.subname, this.pic, this.type, this.year, this.dataList, this.des, this.last, this.state, {this.actor, this.area, this.director, this.lang});

  factory VideoData.fromMap(Map map) {
    return VideoData(
      map['tid'],
      map['name'],
      map['note'],
      map['subname'],
      map['pic'],
      map['type'],
      map['year'],
      (map['dataList'] as List).map((e) => VideoSource.fromMap(e)).toList(),
      map['des'],
      map['last'],
      map['state'],
      actor: map['actor'],
      area: map['area'],
      director: map['director'],
      lang: map['lang'],
    );
  }
}

class VideoSource {
  late String name;
  late List<VideoItem> urls;

  VideoSource(this.name, this.urls);

  factory VideoSource.fromMap(Map map) {
    return VideoSource(map['name'], (map['urls'] as List).map((e) => VideoItem.fromMap(e as Map)).toList());
  }
}

class VideoItem {
  late String label;
  late String url;
  VideoItem(this.label, this.url);

  factory VideoItem.fromMap(Map map) {
    return VideoItem(map['label'], map['url']);
  }
}

class PlayState {
  Duration duration = Duration.zero;
  double buffered = 0;
  double played = 0;

  PlayState(this.duration, this.buffered, this.played);

  PlayState.origin()
      : duration = Duration.zero,
        buffered = 0,
        played = 0;

  factory PlayState.fromVideoPlayerValue(VideoPlayerValue value) {
    double buffered = 0;
    double played = 0;
    int durationInMilliseconds = value.duration.inMilliseconds;
    if (value.isInitialized && durationInMilliseconds > 0) {
      if (value.buffered.isNotEmpty) {
        buffered = min(value.buffered.last.end.inMilliseconds / durationInMilliseconds, 1);
      }
      played = value.position.inMilliseconds / durationInMilliseconds;
    }
    return PlayState(value.duration, buffered, played);
  }
}
