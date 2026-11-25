import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/video_interactions_service.dart';
import '../theme/auvix_theme.dart';

class VideoCommentsSheet extends StatefulWidget {
  const VideoCommentsSheet({super.key, required this.videoId});

  final String videoId;

  @override
  State<VideoCommentsSheet> createState() => _VideoCommentsSheetState();
}

class _VideoCommentsSheetState extends State<VideoCommentsSheet> {
  final _input = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  Map<String, dynamic>? _replyTo;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final result = await VideoCommentsService.loadComments(widget.videoId);

      if (!mounted) return;

      setState(() {
        _comments = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message('Não foi possível carregar os comentários.');
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AuvixTheme.surface2),
    );
  }

  Future<void> _send() async {
    final content = _input.text.trim();

    if (content.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      await VideoCommentsService.addComment(
        videoId: widget.videoId,
        content: content,
        parentCommentId: _replyTo?['id']?.toString(),
      );

      _input.clear();

      if (!mounted) return;

      setState(() => _replyTo = null);
      await _load();
    } catch (_) {
      if (mounted) {
        _message('Não foi possível enviar. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _like(Map<String, dynamic> comment) async {
    final id = comment['id'].toString();
    final oldLiked = comment['liked_by_me'] == true;

    try {
      final newLiked = await VideoCommentsService.toggleCommentLike(
        id,
        oldLiked,
      );

      if (!mounted) return;

      setState(() {
        comment['liked_by_me'] = newLiked;
        final count = comment['like_count'] as int? ?? 0;
        comment['like_count'] = count + (newLiked ? 1 : -1);
      });
    } catch (_) {
      _message('Não foi possível registrar a curtida.');
    }
  }

  Future<void> _delete(Map<String, dynamic> comment) async {
    try {
      await VideoCommentsService.deleteComment(comment['id'].toString());
      await _load();
    } catch (_) {
      _message('Não foi possível excluir o comentário.');
    }
  }

  Future<void> _report(Map<String, dynamic> comment) async {
    const reasons = [
      'Spam ou propaganda',
      'Ofensa ou assédio',
      'Conteúdo inadequado',
      'Informação enganosa',
      'Outro motivo',
    ];

    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        backgroundColor: AuvixTheme.surface,
        title: const Text('Denunciar comentário'),
        children: [
          for (final item in reasons)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, item),
              child: Text(item),
            ),
        ],
      ),
    );

    if (reason == null) return;

    try {
      await VideoCommentsService.reportComment(
        commentId: comment['id'].toString(),
        reason: reason,
      );

      if (mounted) _message('Denúncia enviada para análise.');
    } catch (_) {
      if (mounted) _message('Não foi possível enviar a denúncia.');
    }
  }

  Widget _avatar(int index) {
    final safeIndex = index >= 0 && index <= 11 ? index : 0;
    final number = (safeIndex + 1).toString().padLeft(2, '0');

    return Container(
      width: 37,
      height: 37,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AuvixTheme.accent, width: 1.3),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/avatars/avatar_$number.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person, color: AuvixTheme.accent),
        ),
      ),
    );
  }

  Widget _commentTile(Map<String, dynamic> comment, int depth) {
    final id = comment['id'].toString();
    final children = _comments
        .where((item) => item['parent_comment_id']?.toString() == id)
        .toList();

    final isMine = comment['is_mine'] == true;
    final liked = comment['liked_by_me'] == true;

    return Padding(
      padding: EdgeInsets.only(left: depth == 0 ? 0 : 22, top: 9, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(comment['avatar_index'] as int? ?? 0),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['display_name']?.toString() ?? 'Investidor AMBUX',
                      style: const TextStyle(
                        color: AuvixTheme.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      comment['content']?.toString() ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 17,
                      children: [
                        InkWell(
                          onTap: () => _like(comment),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                liked ? Icons.favorite : Icons.favorite_border,
                                color: liked
                                    ? Colors.pinkAccent
                                    : AuvixTheme.muted,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${comment['like_count'] ?? 0}',
                                style: const TextStyle(
                                  color: AuvixTheme.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _replyTo = comment;
                            });
                          },
                          child: const Text(
                            'Responder',
                            style: TextStyle(
                              color: AuvixTheme.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.more_horiz,
                            color: AuvixTheme.muted,
                            size: 19,
                          ),
                          color: AuvixTheme.surface2,
                          onSelected: (value) {
                            if (value == 'delete') _delete(comment);
                            if (value == 'report') _report(comment);
                          },
                          itemBuilder: (_) => [
                            if (isMine)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Excluir comentário'),
                              ),
                            if (!isMine)
                              const PopupMenuItem(
                                value: 'report',
                                child: Text('Denunciar'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          for (final child in children) _commentTile(child, depth + 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roots = _comments
        .where((item) => item['parent_comment_id'] == null)
        .toList();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 17, 12, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Comentários',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            const Divider(color: AuvixTheme.surface2, height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : roots.isEmpty
                  ? const Center(
                      child: Text(
                        'Ainda não há comentários.\nSeja o primeiro a comentar!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AuvixTheme.muted),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                      children: [
                        for (final comment in roots) _commentTile(comment, 0),
                      ],
                    ),
            ),
            if (_replyTo != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                color: AuvixTheme.surface2,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Respondendo a ${_replyTo!['display_name']}',
                        style: const TextStyle(
                          color: AuvixTheme.accent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _replyTo = null),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                14,
                10,
                14,
                MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Escreva um comentário...',
                        hintStyle: const TextStyle(color: AuvixTheme.muted),
                        filled: true,
                        fillColor: AuvixTheme.surface2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    style: IconButton.styleFrom(
                      backgroundColor: AuvixTheme.accent,
                      foregroundColor: const Color(0xFF00140F),
                    ),
                    icon: _sending
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
