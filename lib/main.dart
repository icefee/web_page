import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:html';
import 'dart:math' show min, pi;
import './widget/video_url_parser.dart';
import './widget/player.dart';
import './widget/profile.dart';
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
        decoration: BoxDecoration(color: toastColor, borderRadius: AppTheme.borderRadius),
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

  List<VideoItem> get urls => activeSource.urls;

  Widget get loadingOverlay {
    return Center(
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration:
            BoxDecoration(color: Colors.white, borderRadius: AppTheme.borderRadius, boxShadow: AppTheme.boxShadow),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            Text('加载中...', style: TextStyle(fontSize: AppTheme.fontSize))
          ],
        ),
      ),
    );
  }

  List<Tab> get tabs {
    return const [
      Tab(
        text: '简介',
      ),
      Tab(
        text: '选集',
      )
    ];
  }

  Widget get tabBar {
    return TabBar.secondary(
      labelColor: Theme.of(context).primaryColor,
      tabs: tabs,
      tabAlignment: TabAlignment.center,
      dividerColor: Colors.transparent,
    );
  }

  Widget container(Widget child, {required double width}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: width,
          decoration: BoxDecoration(color: Colors.white, boxShadow: AppTheme.boxShadow),
          child: child,
        )
      ],
    );
  }

  Widget get divider {
    return Divider(height: 1, color: Colors.grey.shade200);
  }

  Widget withTabView(Widget child) {
    return DefaultTabController(
        length: tabs.length,
        child: Column(
          children: <Widget>[tabBar, divider, child],
        ));
  }

  @override
  Widget build(BuildContext context) {
    document.title = videoData?.name ?? '数据加载中';

    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent], transform: GradientRotation(pi / 4))),
        child: loading
            ? loadingOverlay
            : LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                double width = min(constraints.maxWidth, 1024);
                Widget player = SizedBox(
                  height: width > 600 ? min(width * 10 / 16, 500) : constraints.maxHeight * .45,
                  child: VideoUrlParser(
                    url: urls[activeEpisode].url,
                    childBuilder: (String url) => NetworkVideoPlayer(
                      url: url,
                      onEnd: () {
                        if (activeEpisode < urls.length - 1) {
                          setState(() {
                            activeEpisode += 1;
                          });
                        }
                      },
                    ),
                  ),
                );
                Widget playStatus = Offstage(
                    offstage: urls.length <= 1,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      alignment: Alignment.center,
                      child: Text('${videoData!.name} - ${urls[activeEpisode].label}',
                          style: const TextStyle(fontSize: 18)),
                    ));
                Widget tabView = TabBarView(children: <Widget>[
                  Profile(video: videoData!),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) => SingleChildScrollView(
                              child: Wrap(
                                children: urls
                                    .asMap()
                                    .keys
                                    .map((int index) => Container(
                                        width: constraints.maxWidth / (constraints.maxWidth / 120).floor(),
                                        padding: const EdgeInsets.all(5),
                                        child: ToggleButton(
                                          active: activeEpisode == index,
                                          text: urls[index].label,
                                          onPressed: () {
                                            setState(() {
                                              activeEpisode = index;
                                            });
                                          },
                                        )))
                                    .toList(),
                              ),
                            )),
                  )
                ]);
                return container(
                    width > 600
                        ? ListView(
                            children: [player, playStatus, withTabView(SizedBox(height: 400, child: tabView))],
                          )
                        : Column(
                            children: [player, playStatus, Expanded(child: withTabView(Expanded(child: tabView)))],
                          ),
                    width: width);
              }),
      ),
    );
  }
}
