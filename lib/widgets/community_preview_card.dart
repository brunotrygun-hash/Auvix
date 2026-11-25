import 'package:flutter/material.dart';

import '../screens/community_screen.dart';
import '../services/community_service.dart';
import '../theme/auvix_theme.dart';

class CommunityPreviewCard extends StatefulWidget {
  const CommunityPreviewCard({super.key});

  @override
  State<CommunityPreviewCard> createState() => _CommunityPreviewCardState();
}

class _CommunityPreviewCardState extends State<CommunityPreviewCard> {
  late Future<Map<String, dynamic>?> _preview;

  @override
  void initState() {
    super.initState();
    _preview = CommunityService.loadLatestPreview();
  }

  String _date(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (date == null) return 'Recentemente';

    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'Agora';
    if (difference.inHours < 1) return 'Há ${difference.inMinutes} min';
    if (difference.inDays < 1) return 'Há ${difference.inHours} h';
    if (difference.inDays == 1) return 'Ontem';
    return 'Há ${difference.inDays} dias';
  }

  void _openCommunity() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CommunityScreen()));
  }

  Widget _avatar(int index) {
    final safe = index >= 0 && index <= 11 ? index : 0;
    final number = (safe + 1).toString().padLeft(2, '0');

    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AuvixTheme.accent, width: 1.6),
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

  Widget _cardContent(Map<String, dynamic>? post) {
    if (post == null) {
      return const Text(
        'Seja um dos primeiros a compartilhar uma ideia com a comunidade.',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: AuvixTheme.muted, fontSize: 12),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _avatar(post['avatar_index'] as int? ?? 0),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['display_name']?.toString() ?? 'Investidor AMBUX',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _date(post['created_at']),
                    style: const TextStyle(
                      color: AuvixTheme.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.forum_outlined,
              color: AuvixTheme.accent,
              size: 19,
            ),
          ],
        ),
        const SizedBox(height: 11),
        Text(
          post['content']?.toString() ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, height: 1.35),
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            const Icon(
              Icons.favorite_border,
              color: AuvixTheme.accent,
              size: 16,
            ),
            const SizedBox(width: 5),
            Text(
              '${post['like_count'] ?? 0}',
              style: const TextStyle(color: AuvixTheme.muted, fontSize: 11),
            ),
            const SizedBox(width: 15),
            const Icon(
              Icons.chat_bubble_outline,
              color: AuvixTheme.accent,
              size: 15,
            ),
            const SizedBox(width: 5),
            Text(
              '${post['comment_count'] ?? 0}',
              style: const TextStyle(color: AuvixTheme.muted, fontSize: 11),
            ),
            const Spacer(),
            const Text(
              'Participar',
              style: TextStyle(
                color: AuvixTheme.accent,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward, color: AuvixTheme.accent, size: 15),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _preview,
      builder: (context, snapshot) {
        final post = snapshot.data;

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          child: InkWell(
            onTap: _openCommunity,
            borderRadius: BorderRadius.circular(17),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AuvixTheme.surface,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFF1B665E), width: 1.1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.groups_rounded,
                        color: AuvixTheme.accent,
                        size: 21,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Comunidade AMBUX',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const Text(
                        'VER TODAS',
                        style: TextStyle(
                          color: AuvixTheme.accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .5,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: AuvixTheme.accent,
                        size: 12,
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  const Divider(color: Color(0xFF1C3B4B), height: 1),
                  const SizedBox(height: 13),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          color: AuvixTheme.accent,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  else
                    _cardContent(post),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
