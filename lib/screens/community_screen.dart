import 'package:flutter/material.dart';

import '../services/community_service.dart';
import '../theme/auvix_theme.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _people = [];
  List<Map<String, dynamic>> _followList = [];

  int _peopleView = 0;
  bool _loadingFollowList = false;

  bool _loadingFeed = true;
  bool _loadingPeople = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadFeed();
    _loadPeople();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value), backgroundColor: AuvixTheme.surface2),
    );
  }

  Future<void> _loadFeed() async {
    if (mounted) setState(() => _loadingFeed = true);

    try {
      final result = await CommunityService.loadFeed();
      if (!mounted) return;
      setState(() {
        _posts = result;
        _loadingFeed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingFeed = false);
      _message('Não foi possível carregar as publicações.');
    }
  }

  Future<void> _loadPeople() async {
    if (mounted) setState(() => _loadingPeople = true);

    try {
      final result = await CommunityService.loadPeople();
      if (!mounted) return;
      setState(() {
        _people = result;
        _loadingPeople = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingPeople = false);
      _message('Não foi possível carregar os participantes.');
    }
  }

  Future<void> _compose() async {
    final controller = TextEditingController();

    final content = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AuvixTheme.surface,
        title: const Text('Nova publicação'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 6,
          maxLength: 3000,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Compartilhe uma experiência ou ideia sobre finanças...',
            alignLabelWithHint: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Publicar'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (content == null || content.trim().isEmpty || !mounted) return;

    setState(() => _sending = true);

    try {
      await CommunityService.createPost(content);
      await _loadFeed();
      _message('Publicação compartilhada!');
    } catch (_) {
      _message('Não foi possível publicar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _like(Map<String, dynamic> post) async {
    final id = post['id'].toString();
    final oldLiked = post['liked_by_me'] == true;

    try {
      final newLiked = await CommunityService.toggleLike(id, oldLiked);
      if (!mounted) return;

      setState(() {
        post['liked_by_me'] = newLiked;
        final count = post['like_count'] as int? ?? 0;
        post['like_count'] = count + (newLiked ? 1 : -1);
      });
    } catch (_) {
      _message('Não foi possível registrar a curtida.');
    }
  }

  Future<void> _deletePost(Map<String, dynamic> post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AuvixTheme.surface,
        title: const Text('Excluir publicação?'),
        content: const Text(
          'Essa ação também removerá os comentários e curtidas dessa publicação.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await CommunityService.deletePost(post['id'].toString());
      if (!mounted) return;
      setState(
        () => _posts.removeWhere(
          (item) => item['id'].toString() == post['id'].toString(),
        ),
      );
      _message('Publicação excluída.');
    } catch (_) {
      _message('Não foi possível excluir a publicação.');
    }
  }

  Future<void> _openComments(Map<String, dynamic> post) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AuvixTheme.surface,
      builder: (_) => CommunityCommentsSheet(postId: post['id'].toString()),
    );

    if (!mounted) return;
    await _loadFeed();
  }

  Future<void> _toggleFollow(Map<String, dynamic> person) async {
    final id = person['user_id'].toString();
    final oldValue = person['is_following'] == true;

    try {
      final newValue = await CommunityService.toggleFollow(id, oldValue);
      if (!mounted) return;

      setState(() {
        person['is_following'] = newValue;
        final count = person['followers_count'] as int? ?? 0;
        person['followers_count'] = count + (newValue ? 1 : -1);
      });

      await _loadFeed();
    } catch (_) {
      _message('Não foi possível atualizar esse relacionamento.');
    }
  }

  Widget _avatar(int index, {double size = 42}) {
    final safeIndex = index >= 0 && index <= 11 ? index : 0;
    final number = (safeIndex + 1).toString().padLeft(2, '0');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AuvixTheme.accent, width: 1.3),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/avatars/avatar_$number.png',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.person, color: AuvixTheme.accent),
        ),
      ),
    );
  }

  Widget _postCard(Map<String, dynamic> post) {
    final liked = post['liked_by_me'] == true;
    final isMine = post['is_mine'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AuvixTheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFF1C3B4B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _avatar(post['avatar_index'] as int? ?? 0),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['display_name']?.toString() ?? 'Investidor AUVIX',
                      style: const TextStyle(
                        color: AuvixTheme.accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _date(post['created_at']),
                      style: const TextStyle(
                        color: AuvixTheme.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMine)
                PopupMenuButton<String>(
                  color: AuvixTheme.surface2,
                  onSelected: (value) {
                    if (value == 'delete') _deletePost(post);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('Excluir publicação'),
                    ),
                  ],
                  icon: const Icon(Icons.more_horiz, color: AuvixTheme.muted),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            post['content']?.toString() ?? '',
            style: const TextStyle(
              color: AuvixTheme.text,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 15),
          const Divider(color: Color(0xFF1C3B4B), height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: () => _like(post),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 7,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? AuvixTheme.danger : AuvixTheme.muted,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post['like_count'] ?? 0}',
                        style: const TextStyle(color: AuvixTheme.muted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              InkWell(
                onTap: () => _openComments(post),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 7,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.mode_comment_outlined,
                        color: AuvixTheme.muted,
                        size: 19,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post['comment_count'] ?? 0}',
                        style: const TextStyle(color: AuvixTheme.muted),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'AUVIX',
                style: TextStyle(
                  color: AuvixTheme.muted,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _date(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (date == null) return '';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} às $hour:$minute';
  }

  Widget _feed() {
    if (_loadingFeed) {
      return const Center(
        child: CircularProgressIndicator(color: AuvixTheme.accent),
      );
    }

    return RefreshIndicator(
      color: AuvixTheme.accent,
      onRefresh: _loadFeed,
      child: _posts.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                Icon(Icons.forum_outlined, color: AuvixTheme.muted, size: 48),
                SizedBox(height: 15),
                Center(
                  child: Text(
                    'Sua comunidade começa aqui.',
                    style: TextStyle(
                      color: AuvixTheme.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    'Siga participantes ou compartilhe sua primeira ideia.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AuvixTheme.muted),
                  ),
                ),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 100),
              itemCount: _posts.length,
              itemBuilder: (_, index) => _postCard(_posts[index]),
            ),
    );
  }

  Future<void> _showPeopleView(int mode) async {
    if (_peopleView == mode) return;

    setState(() {
      _peopleView = mode;
      _followList = [];
    });

    if (mode == 0) {
      await _loadPeople();
      return;
    }

    await _loadFollowList(mode == 2);
  }

  Future<void> _loadFollowList(bool following) async {
    if (mounted) {
      setState(() => _loadingFollowList = true);
    }

    try {
      final result = await CommunityService.loadFollowList(
        following: following,
      );

      if (!mounted) return;

      setState(() {
        _followList = result;
        _loadingFollowList = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _loadingFollowList = false);
      _message(
        following
            ? 'Não foi possível carregar quem você segue.'
            : 'Não foi possível carregar seus seguidores.',
      );
    }
  }

  Widget _discover() {
    final loading = _peopleView == 0 ? _loadingPeople : _loadingFollowList;

    final people = _peopleView == 0 ? _people : _followList;

    final emptyMessage = switch (_peopleView) {
      1 => 'Você ainda não tem seguidores.',
      2 => 'Você ainda não segue ninguém.',
      _ => 'Ainda não há outros participantes para mostrar.',
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 7,
            runSpacing: 7,
            children: [
              ChoiceChip(
                label: const Text('Descobrir'),
                selected: _peopleView == 0,
                onSelected: (_) => _showPeopleView(0),
                selectedColor: AuvixTheme.surface2,
                labelStyle: TextStyle(
                  color: _peopleView == 0
                      ? AuvixTheme.accent
                      : AuvixTheme.muted,
                ),
                side: BorderSide(
                  color: _peopleView == 0
                      ? AuvixTheme.accent
                      : const Color(0xFF1C3B4B),
                ),
              ),
              ChoiceChip(
                label: const Text('Seguidores'),
                selected: _peopleView == 1,
                onSelected: (_) => _showPeopleView(1),
                selectedColor: AuvixTheme.surface2,
                labelStyle: TextStyle(
                  color: _peopleView == 1
                      ? AuvixTheme.accent
                      : AuvixTheme.muted,
                ),
                side: BorderSide(
                  color: _peopleView == 1
                      ? AuvixTheme.accent
                      : const Color(0xFF1C3B4B),
                ),
              ),
              ChoiceChip(
                label: const Text('Seguindo'),
                selected: _peopleView == 2,
                onSelected: (_) => _showPeopleView(2),
                selectedColor: AuvixTheme.surface2,
                labelStyle: TextStyle(
                  color: _peopleView == 2
                      ? AuvixTheme.accent
                      : AuvixTheme.muted,
                ),
                side: BorderSide(
                  color: _peopleView == 2
                      ? AuvixTheme.accent
                      : const Color(0xFF1C3B4B),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(color: AuvixTheme.accent),
                )
              : RefreshIndicator(
                  color: AuvixTheme.accent,
                  onRefresh: () => _peopleView == 0
                      ? _loadPeople()
                      : _loadFollowList(_peopleView == 2),
                  child: people.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 100),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  emptyMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AuvixTheme.muted,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(15, 15, 15, 30),
                          itemCount: people.length,
                          separatorBuilder: (_, _) => const Divider(
                            color: Color(0xFF1C3B4B),
                            height: 20,
                          ),
                          itemBuilder: (_, index) {
                            final person = people[index];
                            final following = person['is_following'] == true;

                            return Row(
                              children: [
                                _avatar(person['avatar_index'] as int? ?? 0),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        person['display_name']?.toString() ??
                                            'Investidor AUVIX',
                                        style: const TextStyle(
                                          color: AuvixTheme.text,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (_peopleView == 0) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          '${person['followers_count'] ?? 0} seguidores',
                                          style: const TextStyle(
                                            color: AuvixTheme.muted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (_peopleView == 0)
                                  OutlinedButton(
                                    onPressed: () => _toggleFollow(person),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: following
                                          ? AuvixTheme.muted
                                          : AuvixTheme.accent,
                                      side: BorderSide(
                                        color: following
                                            ? AuvixTheme.muted
                                            : AuvixTheme.accent,
                                      ),
                                    ),
                                    child: Text(
                                      following ? 'Seguindo' : 'Seguir',
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuvixTheme.background,
      appBar: AppBar(
        title: const Text(
          'Comunidade',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AuvixTheme.accent,
          labelColor: AuvixTheme.accent,
          unselectedLabelColor: AuvixTheme.muted,
          tabs: const [
            Tab(text: 'Publicações'),
            Tab(text: 'Descobrir pessoas'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sending ? null : _compose,
        backgroundColor: AuvixTheme.accent,
        foregroundColor: const Color(0xFF00140F),
        child: _sending
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.edit_rounded),
      ),
      body: TabBarView(controller: _tabs, children: [_feed(), _discover()]),
    );
  }
}

class CommunityCommentsSheet extends StatefulWidget {
  const CommunityCommentsSheet({super.key, required this.postId});

  final String postId;

  @override
  State<CommunityCommentsSheet> createState() => _CommunityCommentsSheetState();
}

class _CommunityCommentsSheetState extends State<CommunityCommentsSheet> {
  final _input = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
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

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value), backgroundColor: AuvixTheme.surface2),
    );
  }

  Future<void> _load() async {
    try {
      final result = await CommunityService.loadComments(widget.postId);
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

  Future<void> _send() async {
    final content = _input.text.trim();
    if (content.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      await CommunityService.addComment(
        postId: widget.postId,
        content: content,
      );
      _input.clear();
      await _load();
    } catch (_) {
      _message('Não foi possível enviar o comentário.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _delete(Map<String, dynamic> comment) async {
    try {
      await CommunityService.deleteComment(comment['id'].toString());
      await _load();
    } catch (_) {
      _message('Não foi possível excluir o comentário.');
    }
  }

  Widget _avatar(int index) {
    final safeIndex = index >= 0 && index <= 11 ? index : 0;
    final number = (safeIndex + 1).toString().padLeft(2, '0');

    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AuvixTheme.accent, width: 1.3),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/avatars/avatar_$number.png',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.person, color: AuvixTheme.accent),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Comentários',
                      style: TextStyle(
                        color: AuvixTheme.text,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1C3B4B), height: 1),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AuvixTheme.accent,
                      ),
                    )
                  : _comments.isEmpty
                  ? const Center(
                      child: Text(
                        'Seja o primeiro a comentar.',
                        style: TextStyle(color: AuvixTheme.muted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: _comments.length,
                      itemBuilder: (_, index) {
                        final comment = _comments[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 17),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _avatar(comment['avatar_index'] as int? ?? 0),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment['display_name']?.toString() ??
                                          'Investidor AUVIX',
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
                                        color: AuvixTheme.text,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (comment['is_mine'] == true)
                                IconButton(
                                  onPressed: () => _delete(comment),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AuvixTheme.muted,
                                    size: 19,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(color: Color(0xFF1C3B4B), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 2000,
                      decoration: const InputDecoration(
                        hintText: 'Escreva um comentário...',
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AuvixTheme.accent,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: AuvixTheme.accent,
                          ),
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
