import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:html';
import 'dart:math' show min;
import './widget/player.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(color: toastColor, borderRadius: AppTheme.borderRadius),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
      gravity: ToastGravity.BOTTOM,
    );
  }

  void getVideoData() async {
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

  @override
  Widget build(BuildContext context) {
    document.title = videoData?.name ?? '数据加载中';

    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent])),
        child: loading
            ? Center(
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: AppTheme.borderRadius, boxShadow: AppTheme.boxShadow),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [CircularProgressIndicator(), Text('加载中..', style: TextStyle(fontSize: 16.0))],
                  ),
                ),
              )
            : LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                double width = min(constraints.maxWidth, 1200);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: width,
                      decoration: BoxDecoration(color: Colors.white, boxShadow: AppTheme.boxShadow),
                      child: ListView(
                        children: [
                          SizedBox(
                            height: width > 600 ? min(width * 9 / 16, 600) : constraints.maxHeight * .45,
                            child: NetworkVideoPlayer(
                              url: activeSource.urls[activeEpisode].url,
                              onEnd: () {
                                if (activeEpisode < activeSource.urls.length - 1) {
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
                                child: Text('${videoData!.name} - ${activeSource.urls[activeEpisode].label}', style: const TextStyle(fontSize: 18)),
                              )),
                          DefaultTabController(
                              length: 2,
                              child: Column(
                                children: [
                                  Container(
                                    width: width,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: Colors.black12))),
                                    child: TabBar(
                                        tabAlignment: TabAlignment.center,
                                        tabs: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            child: const Text('简介'),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            child: const Text('选集'),
                                          )
                                        ],
                                        dividerColor: Colors.transparent),
                                  ),
                                  SizedBox(
                                    height: 400,
                                    child: TabBarView(children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: min(150, width > 600 ? width / 5 : width * .4),
                                              child: Image.network(
                                                videoData!.pic,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(videoData!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                                                    Container(
                                                      margin: const EdgeInsets.only(bottom: 8),
                                                      child: Text(videoData!.note, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54)),
                                                    ),
                                                    Offstage(
                                                      offstage: videoData!.subname.isEmpty,
                                                      child: Text('又名: ${videoData!.subname}', style: const TextStyle(fontSize: 16)),
                                                    ),
                                                    Text('类别: ${videoData!.type}', style: const TextStyle(fontSize: 16)),
                                                    Text('年份: ${videoData!.year}', style: const TextStyle(fontSize: 16)),
                                                    Offstage(
                                                      offstage: videoData!.area == null,
                                                      child: Text('地区: ${videoData!.area}', style: const TextStyle(fontSize: 16)),
                                                    ),
                                                    Offstage(
                                                      offstage: videoData!.director == null,
                                                      child: Text('导演: ${videoData!.director}', style: const TextStyle(fontSize: 16)),
                                                    ),
                                                    Offstage(
                                                      offstage: videoData!.actor == null,
                                                      child: Text('演员: ${videoData!.actor}', style: const TextStyle(fontSize: 16)),
                                                    ),
                                                    Container(
                                                      margin: const EdgeInsets.only(top: 8),
                                                      child: Text(videoData!.des, style: const TextStyle(fontSize: 16), softWrap: true),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: LayoutBuilder(
                                          builder: (BuildContext context, BoxConstraints constraints) {
                                            return Wrap(
                                              children: activeSource.urls
                                                  .asMap()
                                                  .keys
                                                  .map((int index) => Container(
                                                        width: constraints.maxWidth / (constraints.maxWidth / 120).floor(),
                                                        padding: const EdgeInsets.all(5),
                                                        child: TextButton(
                                                          style: TextButton.styleFrom(backgroundColor: activeEpisode == index ? Theme.of(context).primaryColor : Colors.black12, foregroundColor: activeEpisode == index ? Colors.white : null),
                                                          onPressed: () {
                                                            setState(() {
                                                              activeEpisode = index;
                                                            });
                                                          },
                                                          child: Text(activeSource.urls[index].label),
                                                        ),
                                                      ))
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
