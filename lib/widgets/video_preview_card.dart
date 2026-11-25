import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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
  late final YoutubePlayerController _controller;
  bool _restarting = false;
  late final StreamSubscription<YoutubePlayerValue> _playerSubscription;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: '5P0VoKseJjY',
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

    _playerSubscription = _controller.listen((value) {
      if (value.playerState == PlayerState.ended && widget.isActive) {
        _restartVideo();
      }
    });
  }

  Future<void> _restartVideo() async {
    if (_restarting || !mounted || !widget.isActive) return;

    _restarting = true;
    try {
      await _controller.seekTo(seconds: 0, allowSeekAhead: true);

      if (mounted && widget.isActive) {
        await _controller.playVideo();
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
      if (widget.isActive) {
        _controller.playVideo();
      } else {
        _controller.pauseVideo();
      }
    }
  }

  @override
  void dispose() {
    unawaited(_playerSubscription.cancel());
    _controller.close();
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
              YoutubePlayer(
                controller: _controller,
                aspectRatio: 16 / 9,
                controlsBuilder: (playerContext, isFullscreen) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onTap,
                    child: const SizedBox.expand(),
                  );
                },
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'AMBUX VÍDEOS',
                            style: TextStyle(
                              color: AuvixTheme.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Seu dinheiro parado perde valor?',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Toque para assistir agora',
                            style: TextStyle(
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
