import 'package:flutter/material.dart';
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
  bool _liked = false;
  bool _saved = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'lZNX0fUOKcU',
      autoPlay: widget.isActive,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: false,
        mute: false,
        playsInline: true,
        privacyEnhancedMode: true,
      ),
    );
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
    _controller.close();
    super.dispose();
  }

  void _notice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AuvixTheme.surface2),
    );
  }

  Widget _action({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 29),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
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
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final videoWidth =
              constraints.maxWidth < constraints.maxHeight * 9 / 16
              ? constraints.maxWidth
              : constraints.maxHeight * 9 / 16;

          return Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: SizedBox(
                  width: videoWidth,
                  height: constraints.maxHeight,
                  child: YoutubePlayer(
                    controller: _controller,
                    aspectRatio: 9 / 16,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 14,
                child: SafeArea(
                  child: IconButton(
                    onPressed: widget.onExit,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 13,
                bottom: 34,
                child: Column(
                  children: [
                    _action(
                      icon: _liked ? Icons.favorite : Icons.favorite_border,
                      label: 'Curtir',
                      color: _liked ? Colors.redAccent : Colors.white,
                      onTap: () {
                        setState(() => _liked = !_liked);
                        _notice('Curtidas serão conectadas ao Supabase.');
                      },
                    ),
                    _action(
                      icon: Icons.mode_comment_outlined,
                      label: 'Comentar',
                      onTap: () =>
                          _notice('Comentários serão conectados ao Supabase.'),
                    ),
                    _action(
                      icon: _saved ? Icons.bookmark : Icons.bookmark_border,
                      label: 'Salvar',
                      color: _saved ? AuvixTheme.accent : Colors.white,
                      onTap: () {
                        setState(() => _saved = !_saved);
                        _notice(
                          'Favoritos por conta serão conectados ao Supabase.',
                        );
                      },
                    ),
                    _action(
                      icon: Icons.share_outlined,
                      label: 'Compartilhar',
                      onTap: () => _notice(
                        'Compartilhamento AUVIX será integrado na próxima etapa.',
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 18,
                right: 88,
                bottom: 27,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AUVIX',
                      style: TextStyle(
                        color: AuvixTheme.accent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Seu dinheiro parado perde valor?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Aprenda a investir e faça seu dinheiro trabalhar por você.',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        if (_playing) {
                          await _controller.pauseVideo();
                        } else {
                          await _controller.playVideo();
                        }
                        if (mounted) {
                          setState(() => _playing = !_playing);
                        }
                      },
                      icon: Icon(
                        _playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(_playing ? 'Pausar' : 'Assistir'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
