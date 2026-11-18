import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço responsável exclusivamente pelas interações da Comunidade AUVIX.
/// Não utiliza nem altera as tabelas de comentários dos vídeos.
class CommunityService {
  static final SupabaseClient _client = Supabase.instance.client;

  static String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null || id.isEmpty) {
      throw StateError('Usuário não autenticado.');
    }
    return id;
  }

  static Map<String, dynamic> _map(dynamic row) =>
      Map<String, dynamic>.from(row as Map);

  static Future<Map<String, Map<String, dynamic>>> _loadProfiles(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return {};

    final rows = await _client
        .from('auvix_video_profiles')
        .select('user_id, display_name, avatar_index')
        .inFilter('user_id', userIds.toSet().toList());

    final result = <String, Map<String, dynamic>>{};

    for (final row in rows) {
      final profile = _map(row);
      result[profile['user_id'].toString()] = profile;
    }

    return result;
  }

  /// Carrega publicações próprias e de pessoas seguidas.
  static Future<List<Map<String, dynamic>>> loadFeed() async {
    final userId = _userId;

    final followRows = await _client
        .from('auvix_community_follows')
        .select('following_id')
        .eq('follower_id', userId);

    final userIds = <String>{
      userId,
      for (final row in followRows) _map(row)['following_id'].toString(),
    }.toList();

    final rows = await _client
        .from('auvix_community_posts')
        .select()
        .inFilter('user_id', userIds)
        .order('created_at', ascending: false);

    final posts = rows.map(_map).toList();
    if (posts.isEmpty) return [];

    final postIds = posts.map((post) => post['id'].toString()).toList();
    final authorIds = posts
        .map((post) => post['user_id'].toString())
        .toSet()
        .toList();

    final profiles = await _loadProfiles(authorIds);

    final likesRows = await _client
        .from('auvix_community_likes')
        .select('post_id, user_id')
        .inFilter('post_id', postIds);

    final commentsRows = await _client
        .from('auvix_community_comments')
        .select('post_id')
        .inFilter('post_id', postIds);

    final likes = likesRows.map(_map).toList();
    final comments = commentsRows.map(_map).toList();

    final likeCounts = <String, int>{};
    final likedByMe = <String>{};
    final commentCounts = <String, int>{};

    for (final like in likes) {
      final postId = like['post_id'].toString();
      likeCounts[postId] = (likeCounts[postId] ?? 0) + 1;

      if (like['user_id'].toString() == userId) {
        likedByMe.add(postId);
      }
    }

    for (final comment in comments) {
      final postId = comment['post_id'].toString();
      commentCounts[postId] = (commentCounts[postId] ?? 0) + 1;
    }

    for (final post in posts) {
      final id = post['id'].toString();
      final authorId = post['user_id'].toString();
      final profile = profiles[authorId];

      post['display_name'] = profile?['display_name'] ?? 'Investidor AUVIX';
      post['avatar_index'] = profile?['avatar_index'] ?? 0;
      post['like_count'] = likeCounts[id] ?? 0;
      post['liked_by_me'] = likedByMe.contains(id);
      post['comment_count'] = commentCounts[id] ?? 0;
      post['is_mine'] = authorId == userId;
    }

    return posts;
  }

  /// Lista outros perfis e informa se já são seguidos pelo usuário.
  static Future<List<Map<String, dynamic>>> loadPeople() async {
    final userId = _userId;

    final results = await Future.wait([
      _client
          .from('auvix_video_profiles')
          .select('user_id, display_name, avatar_index')
          .neq('user_id', userId)
          .order('display_name'),
      _client
          .from('auvix_community_follows')
          .select('follower_id, following_id'),
    ]);

    final profiles = (results[0] as List).map(_map).toList();
    final follows = (results[1] as List).map(_map).toList();

    final following = <String>{};
    final followerCounts = <String, int>{};

    for (final follow in follows) {
      final followerId = follow['follower_id'].toString();
      final followingId = follow['following_id'].toString();

      if (followerId == userId) {
        following.add(followingId);
      }

      followerCounts[followingId] = (followerCounts[followingId] ?? 0) + 1;
    }

    for (final profile in profiles) {
      final id = profile['user_id'].toString();
      profile['is_following'] = following.contains(id);
      profile['followers_count'] = followerCounts[id] ?? 0;
    }

    return profiles;
  }

  /// Cria uma publicação de texto.
  static Future<void> createPost(String content) async {
    final text = content.trim();

    if (text.isEmpty || text.length > 3000) {
      throw ArgumentError('A publicação deve ter entre 1 e 3000 caracteres.');
    }

    await _client.from('auvix_community_posts').insert({
      'user_id': _userId,
      'content': text,
    });
  }

  /// Exclui uma publicação própria.
  static Future<void> deletePost(String postId) async {
    await _client
        .from('auvix_community_posts')
        .delete()
        .eq('id', postId)
        .eq('user_id', _userId);
  }

  /// Carrega comentários de uma publicação com seus autores.
  static Future<List<Map<String, dynamic>>> loadComments(String postId) async {
    final rows = await _client
        .from('auvix_community_comments')
        .select()
        .eq('post_id', postId)
        .order('created_at');

    final comments = rows.map(_map).toList();
    if (comments.isEmpty) return [];

    final userIds = comments
        .map((comment) => comment['user_id'].toString())
        .toSet()
        .toList();

    final profiles = await _loadProfiles(userIds);
    final userId = _userId;

    for (final comment in comments) {
      final authorId = comment['user_id'].toString();
      final profile = profiles[authorId];

      comment['display_name'] = profile?['display_name'] ?? 'Investidor AUVIX';
      comment['avatar_index'] = profile?['avatar_index'] ?? 0;
      comment['is_mine'] = authorId == userId;
    }

    return comments;
  }

  /// Adiciona um comentário a uma publicação.
  static Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final text = content.trim();

    if (text.isEmpty || text.length > 2000) {
      throw ArgumentError('O comentário deve ter entre 1 e 2000 caracteres.');
    }

    await _client.from('auvix_community_comments').insert({
      'post_id': postId,
      'user_id': _userId,
      'content': text,
    });
  }

  /// Exclui um comentário próprio.
  static Future<void> deleteComment(String commentId) async {
    await _client
        .from('auvix_community_comments')
        .delete()
        .eq('id', commentId)
        .eq('user_id', _userId);
  }

  /// Curte ou remove a curtida de uma publicação.
  static Future<bool> toggleLike(String postId, bool currentlyLiked) async {
    final userId = _userId;

    if (currentlyLiked) {
      await _client
          .from('auvix_community_likes')
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);

      return false;
    }

    await _client.from('auvix_community_likes').insert({
      'post_id': postId,
      'user_id': userId,
    });

    return true;
  }

  /// Segue ou deixa de seguir outro usuário.
  static Future<bool> toggleFollow(
    String targetUserId,
    bool currentlyFollowing,
  ) async {
    final userId = _userId;

    if (targetUserId == userId) {
      throw ArgumentError('Não é possível seguir a própria conta.');
    }

    if (currentlyFollowing) {
      await _client
          .from('auvix_community_follows')
          .delete()
          .eq('follower_id', userId)
          .eq('following_id', targetUserId);

      return false;
    }

    await _client.from('auvix_community_follows').insert({
      'follower_id': userId,
      'following_id': targetUserId,
    });

    return true;
  }

  /// Carrega seguidores ou pessoas seguidas.
  /// Use following=true para a lista de quem o usuário segue.
  /// Use following=false para a lista de seguidores do usuário.
  static Future<List<Map<String, dynamic>>> loadFollowList({
    required bool following,
  }) async {
    final userId = _userId;

    final rows = following
        ? await _client
              .from('auvix_community_follows')
              .select('following_id')
              .eq('follower_id', userId)
        : await _client
              .from('auvix_community_follows')
              .select('follower_id')
              .eq('following_id', userId);

    final ids = rows.map((row) {
      final item = _map(row);
      return (following ? item['following_id'] : item['follower_id'])
          .toString();
    }).toList();

    if (ids.isEmpty) return [];

    final profiles = await _loadProfiles(ids);
    final result = <Map<String, dynamic>>[];

    for (final id in ids) {
      final profile = profiles[id];
      if (profile != null) {
        result.add(profile);
      }
    }

    return result;
  }
}
