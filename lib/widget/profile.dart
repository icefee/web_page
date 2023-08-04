import 'dart:math' show min;
import 'package:flutter/material.dart';
import '../tool/api.dart';
import '../tool/theme.dart';

class Profile extends StatelessWidget {
  const Profile({super.key, required this.video});

  final VideoData video;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double width = constraints.maxWidth;
        return Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: min(150, width > 600 ? width / 5 : width * .45),
                child: Image.network(
                  video.pic,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.only(left: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(video.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400)),
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Text(video.note,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey.shade700)),
                        ),
                        Offstage(
                          offstage: video.subname.isEmpty,
                          child: Text('又名: ${video.subname}', style: AppTheme.textStyle),
                        ),
                        Text('类别: ${video.type}', style: AppTheme.textStyle),
                        Text('年份: ${video.year}', style: AppTheme.textStyle),
                        Offstage(
                            offstage: video.area == null, child: Text('地区: ${video.area}', style: AppTheme.textStyle)),
                        Offstage(
                          offstage: video.director == null,
                          child: Text('导演: ${video.director}', style: AppTheme.textStyle),
                        ),
                        Offstage(
                          offstage: video.actor == null,
                          child: Text('演员: ${video.actor}', style: AppTheme.textStyle),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: Text(video.des, style: AppTheme.textStyle, softWrap: true),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
