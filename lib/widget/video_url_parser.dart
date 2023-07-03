import 'package:flutter/material.dart';
import '../tool/theme.dart';
import '../tool/api.dart';

class VideoUrlParser extends StatefulWidget {
  const VideoUrlParser({super.key, required this.url, required this.childBuilder});

  final String url;
  final Widget Function(String url) childBuilder;

  @override
  State<StatefulWidget> createState() => _VideoUrlParser();
}

class _VideoUrlParser extends State<VideoUrlParser> {
  bool get isVideoUrl {
    return widget.url.contains(RegExp(r'.(mp4|ogg|webm|m3u8)$'));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (isVideoUrl) {
      return widget.childBuilder(widget.url);
    }
    return FutureBuilder(
        future: Http.parseVideoUrl(widget.url),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              constraints: const BoxConstraints.expand(),
              color: Colors.black,
              child: Center(
                child: Text('播放地址解析中..', style: TextStyle(color: Colors.white, fontSize: AppTheme.fontSize)),
              ),
            );
          }
          return widget.childBuilder(snapshot.data ?? widget.url);
        });
  }
}
