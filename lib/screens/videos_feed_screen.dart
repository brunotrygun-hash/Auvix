import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../theme/auvix_theme.dart';

class VideosFeedScreen extends StatefulWidget {
  const VideosFeedScreen({
    super.key,
    required this.isActive,
    required this.onExit,
  });

  final bool isActive;
  final VoidCallback onExit;

  @override
  State<VideosFeedScreen> createState() => _VideosFeedScreenState();
}

class _VideosFeedScreenState extends State<VideosFeedScreen> {
  late final YoutubePlayerController _controller;
  bool _restarting = false;
  late final StreamSubscription<YoutubePlayerValue> _playerSubscription;

  bool _liked = false;
  bool _saved = false;
  bool _playing = false;

  static const String _videoUrl = 'https://youtube.com/shorts/5P0VoKseJjY';

  @override
  void initState() {
    super.initState();

    _playing = widget.isActive;

    _controller = YoutubePlayerController.fromVideoId(
      videoId: '5P0VoKseJjY',
      autoPlay: widget.isActive,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: false,
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
  void didUpdateWidget(covariant VideosFeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _controller.playVideo();
        _playing = true;
      } else {
        _controller.pauseVideo();
        _playing = false;
      }
    }
  }

  @override
  void dispose() {
    unawaited(_playerSubscription.cancel());
    _controller.close();
    super.dispose();
  }

  void _togglePlayback() async {
    if (_playing) {
      await _controller.pauseVideo();
    } else {
      await _controller.playVideo();
    }

    if (mounted) {
      setState(() => _playing = !_playing);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AuvixTheme.surface2,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showComments() {
    final input = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B1C27),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            22,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Comentários',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: input,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Escreva seu comentário...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF102A38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AuvixTheme.accent),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AuvixTheme.accent,
                    foregroundColor: const Color(0xFF00140F),
                  ),
                  onPressed: () {
                    if (input.text.trim().isEmpty) return;
                    Navigator.pop(sheetContext);
                    _showMessage(
                      'Comentário demonstrativo. A gravação será integrada ao Supabase.',
                    );
                  },
                  child: const Text('Enviar comentário'),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(input.dispose);
  }

  void _shareVideo() {
    Clipboard.setData(const ClipboardData(text: _videoUrl));
    _showMessage('Link do vídeo copiado para compartilhar.');
  }

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 23),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 49,
              height: 49,
              decoration: BoxDecoration(
                color: const Color(0xDD06121A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: active
                      ? AuvixTheme.accent
                      : AuvixTheme.accent.withValues(alpha: 0.75),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AuvixTheme.accent.withValues(
                      alpha: active ? 0.48 : 0.20,
                    ),
                    blurRadius: active ? 15 : 8,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: active ? AuvixTheme.accent : Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                shadows: [Shadow(color: Colors.black, blurRadius: 5)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06121A),
      body: SizedBox.expand(
        child: YoutubePlayer(
          controller: _controller,
          aspectRatio: 9 / 16,
          controlsBuilder: (playerContext, isFullscreen) {
            return Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.48),
                          Colors.transparent,
                          Colors.transparent,
                          const Color(0xE606121A),
                        ],
                        stops: const [0, 0.22, 0.58, 1],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          _roundButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: widget.onExit,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'AUVIX',
                            style: TextStyle(
                              color: AuvixTheme.accent,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                              shadows: [
                                Shadow(
                                  color: AuvixTheme.accent,
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'VÍDEOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 13,
                  bottom: 155,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _action(
                        icon: _liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        label: 'Curtir',
                        active: _liked,
                        onTap: () => setState(() => _liked = !_liked),
                      ),
                      _action(
                        icon: Icons.mode_comment_outlined,
                        label: 'Comentar',
                        onTap: _showComments,
                      ),
                      _action(
                        icon: _saved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        label: 'Salvar',
                        active: _saved,
                        onTap: () {
                          setState(() => _saved = !_saved);
                          _showMessage(
                            _saved
                                ? 'Vídeo salvo nesta sessão.'
                                : 'Vídeo removido dos salvos nesta sessão.',
                          );
                        },
                      ),
                      _action(
                        icon: Icons.share_outlined,
                        label: 'Enviar',
                        onTap: _shareVideo,
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 20,
                  right: 88,
                  bottom: 35,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AuvixTheme.accent.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AuvixTheme.accent.withValues(alpha: 0.75),
                          ),
                        ),
                        child: const Text(
                          'EDUCAÇÃO FINANCEIRA',
                          style: TextStyle(
                            color: AuvixTheme.accent,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Seu dinheiro parado perde valor?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Aprenda a investir e faça seu dinheiro trabalhar por você.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.35,
                          shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                        ),
                      ),
                      const SizedBox(height: 17),
                      OutlinedButton.icon(
                        onPressed: _togglePlayback,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AuvixTheme.accent,
                          side: const BorderSide(
                            color: AuvixTheme.accent,
                            width: 1.3,
                          ),
                          backgroundColor: const Color(0xCC06121A),
                        ),
                        icon: Icon(
                          _playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(_playing ? 'Pausar vídeo' : 'Continuar'),
                      ),
                    ],
                  ),
                ),

                if (!_playing)
                  Center(
                    child: _roundButton(
                      icon: Icons.play_arrow_rounded,
                      size: 68,
                      onTap: _togglePlayback,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 46,
  }) {
    return Material(
      color: const Color(0xDD06121A),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AuvixTheme.accent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AuvixTheme.accent.withValues(alpha: 0.30),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(icon, color: AuvixTheme.accent, size: size * 0.55),
        ),
      ),
    );
  }
}
