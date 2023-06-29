import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:html';
import 'dart:math' show min;
import './widget/player.dart';
import './widget/toggle_button.dart';
import './tool/theme.dart';
import './tool/api.dart';

enum ToastType { msg, success, error }

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web Pages',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Page(),
      builder: FToastBuilder(),
      navigatorKey: navigatorKey,
    );
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _Page();
}

class _Page extends State<Page> {
  VideoData? videoData;
  bool loading = true;

  int activeEpisode = 0;

  FToast? toast;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    toast = FToast();
    toast!.init(context);

    getVideoData();
  }

  void showToast(String text, {ToastType type = ToastType.msg}) {
    Color toastColor = Colors.black54;

    if (type == ToastType.success) {
      toastColor = Colors.green;
    } else if (type == ToastType.error) {
      toastColor = Colors.red;
    }

    toast!.showToast(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
            color: toastColor, borderRadius: AppTheme.borderRadius),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
      gravity: ToastGravity.BOTTOM,
    );
  }

  void getVideoData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    Location location = window.location;
    try {
      if (location.search != null && location.search!.isNotEmpty) {
        Uri uri = Uri(query: location.search?.substring(1));
        String? id = uri.queryParameters['id'];
        if (id != null) {
          VideoData? data = await Http.getVideoData(id);
          if (data != null) {
            videoData = data;
          }
          loading = false;
          setState(() {});
        } else {
          throw 'invalid video id';
        }
      } else {
        throw 'params error';
      }
    } catch (err) {
      showToast('$err', type: ToastType.error);
    }
  }

  VideoSource get activeSource => videoData!.dataList.first;

  Widget get loadingOverlay {
    return Center(
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.borderRadius,
            boxShadow: AppTheme.boxShadow),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            Text('加载中...', style: TextStyle(fontSize: AppTheme.fontSize))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    document.title = videoData?.name ?? '数据加载中';

    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent])),
        child: loading
            ? loadingOverlay
            : LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                double width = min(constraints.maxWidth, 1200);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: width,
                      decoration: BoxDecoration(
                          color: Colors.white, boxShadow: AppTheme.boxShadow),
                      child: ListView(
                        children: [
                          SizedBox(
                            height: width > 600
                                ? min(width * 9 / 16, 600)
                                : constraints.maxHeight * .45,
                            child: NetworkVideoPlayer(
                              url: activeSource.urls[activeEpisode].url,
                              onEnd: () {
                                if (activeEpisode <
                                    activeSource.urls.length - 1) {
                                  setState(() {
                                    activeEpisode += 1;
                                  });
                                }
                              },
                            ),
                          ),
                          Offstage(
                              offstage: activeSource.urls.length <= 1,
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                alignment: Alignment.center,
                                child: Text(
                                    '${videoData!.name} - ${activeSource.urls[activeEpisode].label}',
                                    style: const TextStyle(fontSize: 18)),
                              )),
                          DefaultTabController(
                              length: 2,
                              child: Column(
                                children: [
                                  TabBar.secondary(
                                      labelColor:
                                          Theme.of(context).primaryColor,
                                      tabs: const [
                                        Tab(
                                          text: '简介',
                                        ),
                                        Tab(
                                          text: '选集',
                                        )
                                      ]),
                                  SizedBox(
                                    height: 400,
                                    child: TabBarView(children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: min(
                                                  150,
                                                  width > 600
                                                      ? width / 5
                                                      : width * .4),
                                              child: Image.network(
                                                videoData!.pic,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(videoData!.name,
                                                          style: const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(bottom: 8),
                                                        child: Text(
                                                            videoData!.note,
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black54)),
                                                      ),
                                                      Offstage(
                                                        offstage: videoData!
                                                            .subname.isEmpty,
                                                        child: Text(
                                                            '又名: ${videoData!.subname}',
                                                            style: AppTheme
                                                                .textStyle),
                                                      ),
                                                      Text(
                                                          '类别: ${videoData!.type}',
                                                          style: AppTheme
                                                              .textStyle),
                                                      Text(
                                                          '年份: ${videoData!.year}',
                                                          style: AppTheme
                                                              .textStyle),
                                                      Offstage(
                                                          offstage:
                                                              videoData!.area ==
                                                                  null,
                                                          child: Text(
                                                              '地区: ${videoData!.area}',
                                                              style: AppTheme
                                                                  .textStyle)),
                                                      Offstage(
                                                        offstage: videoData!
                                                                .director ==
                                                            null,
                                                        child: Text(
                                                            '导演: ${videoData!.director}',
                                                            style: AppTheme
                                                                .textStyle),
                                                      ),
                                                      Offstage(
                                                        offstage:
                                                            videoData!.actor ==
                                                                null,
                                                        child: Text(
                                                            '演员: ${videoData!.actor}',
                                                            style: AppTheme
                                                                .textStyle),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 8),
                                                        child: Text(
                                                            videoData!.des,
                                                            style: AppTheme
                                                                .textStyle,
                                                            softWrap: true),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: LayoutBuilder(
                                          builder: (BuildContext context,
                                              BoxConstraints constraints) {
                                            return Wrap(
                                              children: activeSource.urls
                                                  .asMap()
                                                  .keys
                                                  .map((int index) => Container(
                                                      width: constraints
                                                              .maxWidth /
                                                          (constraints.maxWidth /
                                                                  120)
                                                              .floor(),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: ToggleButton(
                                                        active: activeEpisode ==
                                                            index,
                                                        text: activeSource
                                                            .urls[index].label,
                                                        onPressed: () {
                                                          setState(() {
                                                            activeEpisode =
                                                                index;
                                                          });
                                                        },
                                                      )))
                                                  .toList(),
                                            );
                                          },
                                        ),
                                      )
                                    ]),
                                  )
                                ],
                              ))
                        ],
                      ),
                    )
                  ],
                );
              }),
      ),
    );
  }
}
