import 'dart:async';

import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../services/ambux_videos_service.dart';
import '../widgets/video_comments_sheet.dart';
import '../services/video_interactions_service.dart';
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
  final PageController _pageController = PageController();
  final List<YoutubePlayerController> _controllers = [];
  final List<StreamSubscription<YoutubePlayerValue>> _subscriptions = [];

  List<Map<String, dynamic>> _videos = [];
  int _currentIndex = 0;

  bool _loading = true;
  bool _restarting = false;
  bool _liked = false;
  bool _saved = false;
  bool _loadingInteractions = true;
  bool _likeBusy = false;
  bool _saveBusy = false;
  bool _playing = false;

  Map<String, dynamic>? get _currentVideo =>
      _videos.isEmpty ? null : _videos[_currentIndex];

  String get _currentVideoId => _currentVideo?['youtube_id']?.toString() ?? '';

  String get _videoUrl => 'https://youtube.com/shorts/$_currentVideoId';

  String get _videoTitle =>
      _currentVideo?['title']?.toString() ?? 'Vídeo AMBUX';

  String get _videoDescription =>
      _currentVideo?['description']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    _playing = widget.isActive;
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final videos = await AmbuxVideosService.loadPublishedVideos();

      if (!mounted) return;

      final validVideos = videos.where((video) {
        return (video['youtube_id']?.toString() ?? '').isNotEmpty;
      }).toList();

      if (validVideos.isEmpty) {
        setState(() {
          _videos = [];
          _loading = false;
        });
        return;
      }

      for (var i = 0; i < validVideos.length; i++) {
        final videoId = validVideos[i]['youtube_id'].toString();

        final controller = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: i == 0 && widget.isActive,
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

        _controllers.add(controller);

        _subscriptions.add(
          controller.listen((value) {
            if (value.playerState == PlayerState.ended &&
                i == _currentIndex &&
                widget.isActive) {
              _restartVideo(i);
            }
          }),
        );
      }

      setState(() {
        _videos = validVideos;
        _loading = false;
      });

      _loadInteractionStatus();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage('Não foi possível carregar os vídeos.');
    }
  }

  Future<void> _restartVideo(int index) async {
    if (_restarting ||
        !mounted ||
        !widget.isActive ||
        index != _currentIndex ||
        index >= _controllers.length) {
      return;
    }

    _restarting = true;
    try {
      final controller = _controllers[index];
      await controller.seekTo(seconds: 0, allowSeekAhead: true);

      if (mounted && widget.isActive && index == _currentIndex) {
        await controller.playVideo();
      }
    } catch (_) {
      // Evita interromper o feed se o player estiver indisponível.
    } finally {
      _restarting = false;
    }
  }

  final Map<int, Offset> _swipePointers = {};

  void _handleSwipePointerDown(PointerDownEvent event) {
    _swipePointers[event.pointer] = event.position;
  }

  void _handleSwipePointerUp(PointerUpEvent event) {
    final start = _swipePointers.remove(event.pointer);
    if (start == null || !_pageController.hasClients) return;

    final delta = event.position - start;

    if (delta.dy.abs() < 60 || delta.dy.abs() < delta.dx.abs()) {
      return;
    }

    final targetIndex = delta.dy < 0 ? _currentIndex + 1 : _currentIndex - 1;

    if (targetIndex < 0 || targetIndex >= _videos.length) return;

    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleSwipePointerCancel(PointerCancelEvent event) {
    _swipePointers.remove(event.pointer);
  }

  Future<void> _onPageChanged(int index) async {
    if (index < 0 || index >= _controllers.length) return;

    final previousIndex = _currentIndex;

    if (previousIndex < _controllers.length) {
      await _controllers[previousIndex].pauseVideo();
    }

    if (!mounted) return;

    setState(() {
      _currentIndex = index;
      _playing = widget.isActive;
      _liked = false;
      _saved = false;
      _loadingInteractions = true;
      _likeBusy = false;
      _saveBusy = false;
    });

    if (widget.isActive) {
      await _controllers[index].playVideo();
    }

    _loadInteractionStatus();
  }

  @override
  void didUpdateWidget(covariant VideosFeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive &&
        _currentIndex < _controllers.length) {
      if (widget.isActive) {
        _controllers[_currentIndex].playVideo();
        _playing = true;
      } else {
        _controllers[_currentIndex].pauseVideo();
        _playing = false;
      }
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }

    for (final controller in _controllers) {
      controller.close();
    }

    _pageController.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_currentIndex >= _controllers.length) return;

    final controller = _controllers[_currentIndex];
    final shouldPlay = !_playing;

    setState(() => _playing = shouldPlay);

    if (shouldPlay) {
      await controller.playVideo();
    } else {
      await controller.pauseVideo();
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
    if (_currentVideoId.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B1C27),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => VideoCommentsSheet(videoId: _currentVideoId),
    );
  }

  Future<void> _loadInteractionStatus() async {
    final videoId = _currentVideoId;
    if (videoId.isEmpty) return;

    try {
      final status = await VideoInteractionsService.loadVideoStatus(videoId);

      if (!mounted || videoId != _currentVideoId) return;

      setState(() {
        _liked = status['liked'] ?? false;
        _saved = status['saved'] ?? false;
        _loadingInteractions = false;
      });
    } catch (_) {
      if (!mounted || videoId != _currentVideoId) return;
      setState(() => _loadingInteractions = false);
      _showMessage('Não foi possível carregar suas interações.');
    }
  }

  Future<void> _toggleLike() async {
    if (_likeBusy || _loadingInteractions || _currentVideoId.isEmpty) return;

    final videoId = _currentVideoId;
    final previousLiked = _liked;

    setState(() => _likeBusy = true);

    try {
      final result = await VideoInteractionsService.toggleVideoLike(
        videoId,
        previousLiked,
      );

      if (!mounted || videoId != _currentVideoId) return;
      setState(() => _liked = result);
    } catch (_) {
      if (mounted && videoId == _currentVideoId) {
        _showMessage('Não foi possível registrar sua curtida.');
      }
    } finally {
      if (mounted && videoId == _currentVideoId) {
        setState(() => _likeBusy = false);
      }
    }
  }

  Future<void> _toggleSaved() async {
    if (_saveBusy || _loadingInteractions || _currentVideoId.isEmpty) return;

    final videoId = _currentVideoId;
    final previousSaved = _saved;

    setState(() => _saveBusy = true);

    try {
      final result = await VideoInteractionsService.toggleSavedVideo(
        videoId,
        previousSaved,
      );

      if (!mounted || videoId != _currentVideoId) return;

      setState(() => _saved = result);

      _showMessage(
        result
            ? 'Vídeo salvo na sua conta!'
            : 'Vídeo removido dos seus salvos.',
      );
    } catch (_) {
      if (mounted && videoId == _currentVideoId) {
        _showMessage('Não foi possível salvar o vídeo.');
      }
    } finally {
      if (mounted && videoId == _currentVideoId) {
        setState(() => _saveBusy = false);
      }
    }
  }

  Future<void> _shareVideo() async {
    final videoUrl = _videoUrl;
    if (_currentVideoId.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0B1C27),
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Compartilhar vídeo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Escolha onde deseja compartilhar',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _shareOption(
                        label: 'WhatsApp',
                        color: const Color(0xFF25D366),
                        icon: Icons.chat_rounded,
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          final text = Uri.encodeComponent(
                            'Confira este vídeo do AMBUX: $videoUrl',
                          );
                          await _openShareDestination(
                            'https://wa.me/?text=$text',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _shareOption(
                        label: 'Facebook',
                        color: const Color(0xFF1877F2),
                        icon: Icons.facebook_rounded,
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          final link = Uri.encodeComponent(videoUrl);
                          await _openShareDestination(
                            'https://www.facebook.com/sharer/sharer.php?u=$link',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _shareOption(
                        label: 'Copiar link',
                        color: AuvixTheme.accent,
                        icon: Icons.copy_rounded,
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: videoUrl),
                          );
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                          if (mounted) {
                            _showMessage('Link do vídeo copiado!');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shareOption({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF102A38),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.65)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openShareDestination(String destination) async {
    try {
      final uri = Uri.parse(destination);
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _showMessage('Não foi possível abrir o compartilhamento.');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Não foi possível abrir o compartilhamento.');
      }
    }
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

  Widget _buildVideoPage(int index) {
    final video = _videos[index];
    final isCurrent = index == _currentIndex;
    final title = video['title']?.toString() ?? 'Vídeo AMBUX';
    final description = video['description']?.toString() ?? '';

    return YoutubePlayer(
      controller: _controllers[index],
      aspectRatio: 9 / 16,
      enableFullScreenOnVerticalDrag: false,
      gestureRecognizers: const {},
      controlsBuilder: (playerContext, isFullscreen) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _handleSwipePointerDown,
                onPointerUp: _handleSwipePointerUp,
                onPointerCancel: _handleSwipePointerCancel,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: isCurrent ? _togglePlayback : null,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
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
                        'AMBUX',
                        style: TextStyle(
                          color: AuvixTheme.accent,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(color: AuvixTheme.accent, blurRadius: 12),
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
            if (isCurrent)
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
                      onTap: _toggleLike,
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
                      onTap: _toggleSaved,
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
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.35,
                        shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                      ),
                    ),
                  ],
                  if (isCurrent) ...[
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
                ],
              ),
            ),
            if (isCurrent && !_playing)
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF06121A),
        body: Center(
          child: CircularProgressIndicator(color: AuvixTheme.accent),
        ),
      );
    }

    if (_videos.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF06121A),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.video_library_outlined,
                  color: AuvixTheme.accent,
                  size: 58,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Ainda não há vídeos publicados',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: widget.onExit,
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF06121A),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _videos.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) => _buildVideoPage(index),
      ),
    );
  }
}
