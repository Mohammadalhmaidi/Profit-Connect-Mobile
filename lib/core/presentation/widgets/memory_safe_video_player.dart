import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MemorySafeVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double? height;
  final bool autoPlay;

  const MemorySafeVideoPlayer({
    required this.videoUrl,
    super.key,
    this.height,
    this.autoPlay = true,
  });

  @override
  State<MemorySafeVideoPlayer> createState() => _MemorySafeVideoPlayerState();
}

class _MemorySafeVideoPlayerState extends State<MemorySafeVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isVisible = true;
  bool _initStarted = false;

  /// تهيئة كسولة: لا ننشئ وحدة الفيديو حتى يصبح المكون ظاهراً على الشاشة،
  /// لتفادي تحميل كل الفيديوهات في الخلاصة دفعة واحدة (مشاكل ذاكرة/بيانات).
  Future<void> _initPlayer() async {
    if (_initStarted) return;
    _initStarted = true;
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      _controller!.addListener(_updateState);
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
        if (widget.autoPlay && _isVisible) {
          _controller!.play();
        }
      }
    } catch (e) {
      debugPrint('VideoPlayer init error: $e');
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final isVisible = info.visibleFraction > 0.3;
    if (isVisible && !_initStarted) {
      _initPlayer();
      return;
    }
    if (isVisible != _isVisible) {
      _isVisible = isVisible;
      if (_isVisible && widget.autoPlay) {
        _controller?.play();
      } else {
        _controller?.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_updateState);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(MemorySafeVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.removeListener(_updateState);
      _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      _hasError = false;
      _initStarted = false;
      _initPlayer();
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: widget.height ?? 200,
        color: Colors.black26,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off, color: Colors.white54, size: 40),
              SizedBox(height: 8),
              Text(
                'Video unavailable',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return VisibilityDetector(
        key: Key('video_lazy_${widget.videoUrl.hashCode}'),
        onVisibilityChanged: _onVisibilityChanged,
        child: Container(
          height: widget.height ?? 200,
          color: Colors.black12,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return VisibilityDetector(
      key: Key('video_${widget.videoUrl.hashCode}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
            if (!_controller!.value.isPlaying)
              const ColoredBox(
                color: Colors.black26,
                child: Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
