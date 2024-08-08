import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({super.key, required this.url});
  final String url;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoAppPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    _videoAppPlayerController = VideoPlayerController.network(
      widget.url,
    );

    _videoAppPlayerController
        .initialize()
        .then((_) => setState(() => _chewieController = ChewieController(
              autoInitialize: true,
              videoPlayerController: _videoAppPlayerController,
              aspectRatio: _videoAppPlayerController.value.aspectRatio,
              autoPlay: true,
              showControls: false,
            )));
    super.initState();
  }

  @override
  void dispose() {
    _videoAppPlayerController.dispose();
    if (_chewieController != null) {
      _chewieController!.dispose();
      _chewieController = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: _videoAppPlayerController.value.isInitialized
              ? GestureDetector(
                  onTapDown: (details) => _chewieController!.pause(),
                  onTapUp: (details) => _chewieController!.play(),
                  child: Chewie(controller: _chewieController!),
                )
              : const CircularProgressIndicator.adaptive(strokeWidth: 1.5)),
    );
  }
}
