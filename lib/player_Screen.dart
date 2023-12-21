import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoPlayer extends StatefulWidget {
  final String videoUrl;

  VideoPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> with WidgetsBindingObserver {
  late BetterPlayerController _betterPlayerController;
 GlobalKey _betterPlayerKey = GlobalKey();
  @override
  void initState() {
    super.initState();
      WidgetsBinding.instance.addObserver(this);
    initVideoPlayer();
  }

 @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground
    } else if (state == AppLifecycleState.inactive) {
      // App is in transition (going to the background or coming from the background)
    } else if (state == AppLifecycleState.paused) {
      // App is in the background
      // Try to enter PiP mode when the app goes to the background
      _betterPlayerController.enablePictureInPicture(_betterPlayerKey);
    }
  }

  void initVideoPlayer() {
    _betterPlayerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        deviceOrientationsOnFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        fullScreenByDefault: true,
        autoDetectFullscreenDeviceOrientation: true,
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: false,
        allowedScreenSleep: false,
        autoDispose: true,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          playerTheme: BetterPlayerTheme.material,
          progressBarPlayedColor: Colors.red,
          showControlsOnInitialize: false,
          liveTextColor: Colors.red,
          enablePlaybackSpeed: true,
          enableProgressBarDrag: true,
          showControls: true,
          enableSkips: true,
          enablePip: true,
          enableOverflowMenu: true,
          enableFullscreen: true,
        ),
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      ),
      betterPlayerDataSource: BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.videoUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Check if the video is playing in fullscreen mode
        if (_betterPlayerController.isFullScreen) {
          // Exit fullscreen mode
          _betterPlayerController.exitFullScreen();

          // Prevent the app from being closed
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            Center(
              child: BetterPlayer(controller: _betterPlayerController,
              key: _betterPlayerKey,
              ),
            ),
            ElevatedButton(
            child: Text("Show PiP"),
            onPressed: () {
              _betterPlayerController.enablePictureInPicture(_betterPlayerKey);
            },
          ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }
}
