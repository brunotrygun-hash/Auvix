import 'package:supabase_flutter/supabase_flutter.dart';

class AmbuxVideosService {
  static final _client = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> loadPublishedVideos() async {
    final rows = await _client
        .from('ambux_videos')
        .select('youtube_id, title, description, published_at')
        .eq('is_published', true)
        .order('published_at', ascending: false);

    return rows.map((row) => Map<String, dynamic>.from(row)).toList();
  }
}
