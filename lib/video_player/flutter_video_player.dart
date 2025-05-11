import 'dart:io';

import 'package:countly_flutter/countly_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ws/database/database_manager.dart';
import 'package:flutter_ws/database/video_entity.dart';
import 'package:flutter_ws/database/video_progress_entity.dart';
import 'package:flutter_ws/global_state/list_state_container.dart';
import 'package:flutter_ws/model/video.dart';
import 'package:flutter_ws/video_player/custom_chewie_player.dart';
import 'package:flutter_ws/video_player/custom_video_controls.dart';
import 'package:logging/logging.dart';
import 'package:video_player/video_player.dart';

import 'TVPlayerController.dart';

class FlutterVideoPlayer extends StatefulWidget {

  Video video;
  VideoEntity? videoEntity;
  late CustomChewieController chewieController;
  DatabaseManager? databaseManager;
  VideoProgressEntity? progressEntity;
  late AppSharedState appSharedState;
  bool isAlreadyPlayingDifferentVideoOnTV = false;

  final Logger log = Logger('FlutterVideoPlayer');

  final Logger logger = Logger('FlutterVideoPlayer');

  FlutterVideoPlayer(BuildContext context, this.appSharedState,
      this.video, VideoEntity? entity, VideoProgressEntity? progress, {super.key}) {
    databaseManager = appSharedState.appState!.databaseManager;
    progressEntity = progress;
    videoEntity = entity;

    if (appSharedState.appState!.isCurrentlyPlayingOnTV &&
        videoId != appSharedState.appState!.tvCurrentlyPlayingVideo.id) {
      isAlreadyPlayingDifferentVideoOnTV = true;
    }
  }

  String? get videoId => video.id ?? videoEntity?.id;

  @override
  _FlutterVideoPlayerState createState() => _FlutterVideoPlayerState();
}

class _FlutterVideoPlayerState extends State<FlutterVideoPlayer> {
  String? videoUrl;
  // castNewVideoToTV indicates that the currently playing video on the TV
  // should be replaced
  bool castNewVideoToTV = false;
  static VideoPlayerController? videoController;
  static TvPlayerController? tvVideoController;

  @override
  Widget build(BuildContext context) {
    if (widget.isAlreadyPlayingDifferentVideoOnTV) {
      return _showDialog(context);
    }

    this.videoUrl = getVideoUrl(widget.video, widget.videoEntity);
    initVideoPlayerController(context);
    initTvVideoController();
    initChewieController();

    return Scaffold(
        backgroundColor: Colors.grey[800],
        body: Container(
          child: CustomChewie(
            controller: widget.chewieController,
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? getVideoUrl(Video video, VideoEntity? entity) {
    if (video != null) {
      if (video.url_video_hd != null && video.url_video_hd!.isNotEmpty) {
        return video.url_video_hd;
      } else {
        return video.url_video;
      }
    } else {
      if (entity!.url_video_hd != null && entity.url_video_hd!.isNotEmpty) {
        return entity.url_video_hd;
      } else {
        return entity.url_video;
      }
    }
  }

  void initTvVideoController() {
    tvVideoController = TvPlayerController(
      widget.appSharedState.appState!.availableTvs,
      widget.appSharedState.appState!.samsungTVCastManager,
      widget.appSharedState.appState!.databaseManager,
      videoUrl,
      widget.video != null
          ? widget.video
          : Video.fromMap(widget.videoEntity!.toMap()),
      widget.progressEntity != null
          ? Duration(milliseconds: widget.progressEntity!.progress!)
          : Duration(milliseconds: 0),
    );

    if (widget.appSharedState.appState!.targetPlatform ==
        TargetPlatform.android) {
      tvVideoController!.startTvDiscovery();
    }

    // replace the currently playing video on TV
    if (widget.appSharedState.appState!.isCurrentlyPlayingOnTV &&
        castNewVideoToTV) {
      widget.appSharedState.appState!.samsungTVCastManager.stop();
      tvVideoController!.initialize();
      tvVideoController!.startPlayingOnTV();
      return;
    }

    // case: do not replace the currently playing video on TV
    if (widget.appSharedState.appState!.isCurrentlyPlayingOnTV) {
      tvVideoController!.initialize();
    }
  }

  void initVideoPlayerController(BuildContext context) {
    if (videoController != null) {
      videoController!.dispose();
    }
    // always use network datasource if should be casted to TV
    // TV needs accessible video URL
    if (widget.videoEntity == null ||
        widget.appSharedState.appState!.isCurrentlyPlayingOnTV &&
            widget.video != null) {
      videoController = VideoPlayerController.network(
        videoUrl!,
      );

      Map<String, Object> event = {"key": "PLAY_VIDEO_NETWORK", "count": 1};
      Countly.recordEvent(event);

      return;
    }

    String path;
    if (widget.appSharedState.appState!.targetPlatform ==
        TargetPlatform.android) {
      path = "${widget.videoEntity!.filePath!}/${widget.videoEntity!.fileName!}";
    } else {
      path = "${widget.appSharedState.appState!.localDirectory!.path}/MediathekView/${widget.videoEntity!.fileName!}";
    }

    Uri videoUri = Uri.file(path);

    File file = File.fromUri(videoUri);
    file.exists().then(
      (exists) {
        if (!exists) {
          widget.log.severe(
              "Cannot play video from file. File does not exist: ${file.uri}");
          videoController = VideoPlayerController.networkUrl(
            Uri.parse(videoUrl!),
          );
        }
      },
    );

    Map<String, Object> event = {"key": "PLAY_VIDEO_DOWNLOADED", "count": 1};
    Countly.recordEvent(event);

    videoController = VideoPlayerController.file(file);
  }

  void initChewieController() {
    widget.chewieController = CustomChewieController(
        context: context,
        videoPlayerController: videoController!,
        tvPlayerController: tvVideoController,
        looping: false,
        startAt: tvVideoController!.startAt,
        customControls: CustomVideoControls(
            backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
            iconColor: Color(0xffffbf00)),
        fullScreenByDefault: false,
        allowedScreenSleep: false,
        isCurrentlyPlayingOnTV:
            widget.appSharedState.appState!.isCurrentlyPlayingOnTV,
        video: widget.video != null
            ? widget.video
            : Video.fromMap(widget.videoEntity!.toMap()));
  }

  AlertDialog _showDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[800],
      title: Text('Fernseher Verbunden',
          style: TextStyle(color: Colors.white, fontSize: 18.0)),
      content: Text('Soll die aktuelle TV Wiedergabe unterbrochen werden?',
          style: TextStyle(color: Colors.white, fontSize: 16.0)),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Nein'),
          onPressed: () async {
            widget.isAlreadyPlayingDifferentVideoOnTV = false;
            // replace widget.video with the currently playing video
            // to not interrupt the video playback
            widget.video =
                widget.appSharedState.appState!.tvCurrentlyPlayingVideo;

            // get the video entity
            widget.videoEntity = await widget
                .appSharedState.appState!.databaseManager
                .getDownloadedVideo(widget.videoId);

            // get the video progress
            widget.progressEntity = await widget
                .appSharedState.appState!.databaseManager
                .getVideoProgressEntity(widget.video.id);

            // start initializing players with the video playing on the TV
            setState(() {});
          },
        ),
        ElevatedButton(
          child: const Text('Ja'),
          onPressed: () {
            widget.appSharedState.appState!.samsungTVCastManager.stop();

            setState(() {
              widget.isAlreadyPlayingDifferentVideoOnTV = false;
              castNewVideoToTV = true;
            });
          },
        )
      ],
    );
  }
}
