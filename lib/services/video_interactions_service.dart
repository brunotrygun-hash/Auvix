import 'package:supabase_flutter/supabase_flutter.dart';

class VideoInteractionsService {
  static final _client = Supabase.instance.client;

  static String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Usuário não autenticado.');
    return id;
  }

  static Future<Map<String, bool>> loadVideoStatus(String videoId) async {
    final userId = _userId;

    final results = await Future.wait([
      _client
          .from('auvix_video_likes')
          .select('video_id')
          .eq('user_id', userId)
          .eq('video_id', videoId)
          .maybeSingle(),
      _client
          .from('auvix_saved_videos')
          .select('video_id')
          .eq('user_id', userId)
          .eq('video_id', videoId)
          .maybeSingle(),
    ]);

    return {'liked': results[0] != null, 'saved': results[1] != null};
  }

  static Future<bool> toggleVideoLike(
    String videoId,
    bool currentlyLiked,
  ) async {
    final userId = _userId;

    if (currentlyLiked) {
      await _client
          .from('auvix_video_likes')
          .delete()
          .eq('user_id', userId)
          .eq('video_id', videoId);
      return false;
    }

    await _client.from('auvix_video_likes').insert({
      'user_id': userId,
      'video_id': videoId,
    });

    return true;
  }

  static Future<bool> toggleSavedVideo(
    String videoId,
    bool currentlySaved,
  ) async {
    final userId = _userId;

    if (currentlySaved) {
      await _client
          .from('auvix_saved_videos')
          .delete()
          .eq('user_id', userId)
          .eq('video_id', videoId);
      return false;
    }

    await _client.from('auvix_saved_videos').insert({
      'user_id': userId,
      'video_id': videoId,
    });

    return true;
  }
}

class VideoCommentsService {
  static final _client = Supabase.instance.client;

  static String get _userId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('Usuário não autenticado.');
    return id;
  }

  static Future<List<Map<String, dynamic>>> loadComments(String videoId) async {
    final rows = await _client
        .from('auvix_video_comments')
        .select()
        .eq('video_id', videoId)
        .order('created_at');

    final comments = rows.map((row) => Map<String, dynamic>.from(row)).toList();

    if (comments.isEmpty) return [];

    final userIds = comments
        .map((item) => item['user_id'].toString())
        .toSet()
        .toList();

    final commentIds = comments.map((item) => item['id'].toString()).toList();

    final profiles = await _client
        .from('auvix_video_profiles')
        .select('user_id, display_name, avatar_index')
        .inFilter('user_id', userIds);

    final profileMap = <String, Map<String, dynamic>>{};

    for (final profile in profiles) {
      final item = Map<String, dynamic>.from(profile);
      profileMap[item['user_id'].toString()] = item;
    }

    final likes = await _client
        .from('auvix_video_comment_likes')
        .select('user_id, comment_id')
        .inFilter('comment_id', commentIds);

    final likeCounts = <String, int>{};
    final likedByMe = <String>{};

    for (final like in likes) {
      final item = Map<String, dynamic>.from(like);
      final id = item['comment_id'].toString();

      likeCounts[id] = (likeCounts[id] ?? 0) + 1;

      if (item['user_id'].toString() == _userId) {
        likedByMe.add(id);
      }
    }

    for (final comment in comments) {
      final id = comment['id'].toString();
      final profile = profileMap[comment['user_id'].toString()];

      comment['display_name'] = profile?['display_name'] ?? 'Investidor AMBUX';
      comment['avatar_index'] = profile?['avatar_index'] ?? 0;
      comment['like_count'] = likeCounts[id] ?? 0;
      comment['liked_by_me'] = likedByMe.contains(id);
      comment['is_mine'] = comment['user_id'].toString() == _userId;
    }

    return comments;
  }

  static Future<void> addComment({
    required String videoId,
    required String content,
    String? parentCommentId,
  }) async {
    await _client.from('auvix_video_comments').insert({
      'user_id': _userId,
      'video_id': videoId,
      'content': content.trim(),
      'parent_comment_id': parentCommentId,
    });
  }

  static Future<bool> toggleCommentLike(
    String commentId,
    bool currentlyLiked,
  ) async {
    if (currentlyLiked) {
      await _client
          .from('auvix_video_comment_likes')
          .delete()
          .eq('user_id', _userId)
          .eq('comment_id', commentId);

      return false;
    }

    await _client.from('auvix_video_comment_likes').insert({
      'user_id': _userId,
      'comment_id': commentId,
    });

    return true;
  }

  static Future<void> deleteComment(String commentId) async {
    await _client
        .from('auvix_video_comments')
        .delete()
        .eq('id', commentId)
        .eq('user_id', _userId);
  }

  static Future<void> reportComment({
    required String commentId,
    required String reason,
  }) async {
    await _client.from('auvix_video_comment_reports').insert({
      'reporter_user_id': _userId,
      'comment_id': commentId,
      'reason': reason.trim(),
    });
  }
}
