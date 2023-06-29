import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:web_page/tool/theme.dart';
import 'dart:math' show min, max;
import '../tool/parser.dart';
import '../tool/type.dart';

class NetworkVideoPlayer extends StatefulWidget {
  final String url;
  final Color themeColor;
  final VoidCallback? onEnd;

  const NetworkVideoPlayer({Key? key, required this.url, this.themeColor = Colors.blue, this.onEnd}) : super(key: key);

  @override
  State<NetworkVideoPlayer> createState() => _NetworkVideoPlayer();
}

class _NetworkVideoPlayer extends State<NetworkVideoPlayer> {
  late VideoPlayerController _controller;
  PlayState playState = PlayState.origin();
  bool pending = false;
  bool seeking = false;
  bool failed = false;

  @override
  void initState() {
    super.initState();

    _initPlayer();
  }

  void videoPlayerControllerListener() {
    if (_controller.value.isInitialized) {
      if (_controller.value.isPlaying && _controller.value.position.inSeconds == _controller.value.duration.inSeconds) {
        widget.onEnd?.call();
      }
      if (!seeking) {
        playState = PlayState.fromVideoPlayerValue(_controller.value);
      }
      setState(() {});
    }
  }

  void _initPlayer({bool autoplay = false}) async {
    _controller = VideoPlayerController.network(widget.url);

    _controller.addListener(videoPlayerControllerListener);

    setState(() {
      failed = false;
      pending = true;
    });
    // await _controller.setLooping(true);
    try {
      await _controller.initialize();
      if (autoplay) {
        await _controller.play();
      }
    } catch (err) {
      failed = true;
    }
    pending = false;
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant NetworkVideoPlayer oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url) {
      _disposePlayer().then((value) => _initPlayer(autoplay: true));
    }
  }

  Future<void> _disposePlayer() async {
    _controller.removeListener(videoPlayerControllerListener);
    await _controller.dispose();
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      constraints: const BoxConstraints.expand(),
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          Offstage(
            offstage: !(pending || _controller.value.isBuffering),
            child: Container(
              constraints: const BoxConstraints.expand(),
              child: const Center(
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ),
          Offstage(
            offstage: failed,
            child: ControlsOverlay(
              controller: _controller,
              playState: playState,
              onSeeking: (double value) {
                playState.played = value;
                seeking = true;
                setState(() {});
              },
              onSeekEnd: (double value) {
                _controller.seekTo(Duration(milliseconds: (value * _controller.value.duration.inMilliseconds).round())).then((value) {
                  seeking = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final PlayState playState;
  final ValueChanged<double> onSeeking;
  final ValueChanged<double> onSeekEnd;

  const ControlsOverlay({Key? key, required this.controller, required this.playState, required this.onSeeking, required this.onSeekEnd}) : super(key: key);

  @override
  State<ControlsOverlay> createState() => _ControlsOverlay();
}

class _ControlsOverlay extends State<ControlsOverlay> {
  bool controlsVisible = true;
  double originOffset = 0;

  Future<void> _togglePlay() async {
    if (widget.controller.value.isInitialized) {
      if (widget.controller.value.isPlaying) {
        await widget.controller.pause();
        _toggleControlsVisible(true);
      } else {
        await widget.controller.play();
      }
    }
  }

  void _toggleControlsVisible(bool visible) {
    setState(() {
      controlsVisible = visible;
    });
  }

  String get playedTime {
    return [widget.playState.duration * widget.playState.played, widget.playState.duration].map(DateTimeParser.parseDuration).join(' / ');
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        _toggleControlsVisible(true);
      },
      onExit: (event) {
        _toggleControlsVisible(false);
      },
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _toggleControlsVisible(!controlsVisible);
            },
            onDoubleTap: _togglePlay,
            onHorizontalDragStart: (DragStartDetails details) {
              originOffset = details.globalPosition.dx;
              _toggleControlsVisible(true);
            },
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              if (widget.controller.value.isInitialized) {
                int seconds = widget.controller.value.position.inSeconds;
                int totalSeconds = widget.controller.value.duration.inSeconds;
                double screenWidth = MediaQuery.of(context).size.width;
                seconds = max(0, min(seconds + (details.globalPosition.dx - originOffset) * totalSeconds ~/ screenWidth, totalSeconds));
                widget.controller.seekTo(Duration(seconds: seconds));
                originOffset = details.globalPosition.dx;
              }
            },
            child: AnimatedContainer(
              constraints: const BoxConstraints.expand(),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [controlsVisible ? Colors.black54 : Colors.transparent, Colors.transparent],
                stops: const [.2, .75],
              )),
              duration: const Duration(milliseconds: 200),
            ),
          ),
          AnimatedOpacity(
            opacity: controlsVisible ? 1 : 0,
            duration: AppTheme.transitionDuration,
            curve: Curves.easeInOut,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Slider.adaptive(
                  value: widget.playState.played,
                  secondaryTrackValue: widget.playState.buffered,
                  onChanged: widget.onSeeking,
                  onChangeEnd: widget.onSeekEnd,
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          InkWell(
                            onTap: _togglePlay,
                            child: Icon(
                              widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 5.0),
                            child: Text(playedTime, style: const TextStyle(color: Colors.white, fontSize: 16.0)),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          AnimatedOpacity(
            opacity: controlsVisible ? 1 : 0,
            duration: AppTheme.transitionDuration,
            child: Align(
              alignment: Alignment.center,
              child: IconButton(
                  onPressed: _togglePlay,
                  icon: Icon(
                    widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 56,
                  )),
            ),
          )
        ],
      ),
    );
  }
}
