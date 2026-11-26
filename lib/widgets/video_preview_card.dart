import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../services/ambux_videos_service.dart';
import '../theme/auvix_theme.dart';

class VideoPreviewCard extends StatefulWidget {
  const VideoPreviewCard({
    super.key,
    required this.onTap,
    required this.isActive,
  });

  final VoidCallback onTap;
  final bool isActive;

  @override
  State<VideoPreviewCard> createState() => _VideoPreviewCardState();
}

class _VideoPreviewCardState extends State<VideoPreviewCard> {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _playerSubscription;

  String _title = 'AMBUX VÍDEOS';
  bool _loading = true;
  bool _restarting = false;
  bool _hasVideo = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
      final videos = await AmbuxVideosService.loadPublishedVideos();

      if (!mounted) return;

      if (videos.isEmpty) {
        setState(() {
          _loading = false;
          _hasVideo = false;
        });
        return;
      }

      final video = videos.first;
      final videoId = video['youtube_id']?.toString() ?? '';
      final title = video['title']?.toString().trim() ?? '';

      if (videoId.isEmpty) {
        setState(() {
          _loading = false;
          _hasVideo = false;
        });
        return;
      }

      final controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: widget.isActive,
        params: const YoutubePlayerParams(
          showControls: false,
          showFullscreenButton: false,
          mute: true,
          loop: true,
          playsInline: true,
          privacyEnhancedMode: true,
          pointerEvents: PointerEvents.none,
        ),
      );

      _playerSubscription = controller.listen((value) {
        if (value.playerState == PlayerState.ended && widget.isActive) {
          _restartVideo();
        }
      });

      setState(() {
        _controller = controller;
        _title = title.isEmpty ? 'Novo vídeo' : title;
        _loading = false;
        _hasVideo = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasVideo = false;
      });
    }
  }

  Future<void> _restartVideo() async {
    final controller = _controller;
    if (_restarting || !mounted || !widget.isActive || controller == null) {
      return;
    }

    _restarting = true;
    try {
      await controller.seekTo(seconds: 0, allowSeekAhead: true);

      if (mounted && widget.isActive) {
        await controller.playVideo();
      }
    } catch (_) {
      // Evita interromper a tela se o player estiver indisponível.
    } finally {
      _restarting = false;
    }
  }

  @override
  void didUpdateWidget(covariant VideoPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive) {
      final controller = _controller;
      if (controller != null) {
        if (widget.isActive) {
          controller.playVideo();
        } else {
          controller.pauseVideo();
        }
      }
    }
  }

  @override
  void dispose() {
    unawaited(_playerSubscription?.cancel());
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AuvixTheme.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: SizedBox(
          height: 174,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_controller != null)
                YoutubePlayer(
                  controller: _controller!,
                  aspectRatio: 16 / 9,
                  controlsBuilder: (playerContext, isFullscreen) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onTap,
                      child: const SizedBox.expand(),
                    );
                  },
                )
              else
                Container(
                  color: const Color(0xFF101B19),
                  alignment: Alignment.center,
                  child: Icon(
                    _loading
                        ? Icons.play_circle_outline_rounded
                        : Icons.video_library_outlined,
                    color: AuvixTheme.accent,
                    size: 46,
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 15,
                right: 15,
                bottom: 13,
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AuvixTheme.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFF00140F),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'AMBUX VÍDEOS',
                            style: TextStyle(
                              color: AuvixTheme.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _loading
                                ? 'Carregando vídeo...'
                                : _hasVideo
                                ? _title
                                : 'Nenhum vídeo publicado',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            _hasVideo
                                ? 'Toque para assistir agora'
                                : 'Novidades em breve',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.open_in_full_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ],
                ),
              ),
              if (_hasVideo)
                Positioned(
                  top: 12,
                  left: 13,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AuvixTheme.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'NOVO',
                      style: TextStyle(
                        color: Color(0xFF00140F),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
