import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/auvix_theme.dart';

class AdminVideosScreen extends StatefulWidget {
  const AdminVideosScreen({super.key});

  @override
  State<AdminVideosScreen> createState() => _AdminVideosScreenState();
}

class _AdminVideosScreenState extends State<AdminVideosScreen> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _videos = [];
  bool _loading = true;
  bool _isAdmin = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final admin = await _client.rpc('is_auvix_admin');

      if (admin != true) {
        if (!mounted) return;
        setState(() {
          _isAdmin = false;
          _loading = false;
        });
        return;
      }

      final rows = await _client
          .from('ambux_videos')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _isAdmin = true;
        _videos = rows.map((row) => Map<String, dynamic>.from(row)).toList();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  String? _youtubeId(String value) {
    final input = value.trim();

    final match = RegExp(
      r'(?:youtube\.com/shorts/|youtu\.be/|youtube\.com/watch\?v=|youtube\.com/embed/)([A-Za-z0-9_-]{6,20})',
    ).firstMatch(input);

    return match?.group(1);
  }

  Future<void> _openEditor({Map<String, dynamic>? video}) async {
    final urlController = TextEditingController(
      text: video == null
          ? ''
          : 'https://youtube.com/shorts/${video['youtube_id']}',
    );
    final titleController = TextEditingController(
      text: video?['title']?.toString() ?? '',
    );
    final descriptionController = TextEditingController(
      text: video?['description']?.toString() ?? '',
    );

    var published = video?['is_published'] == true;
    var saving = false;
    String? previewId = video?['youtube_id']?.toString();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> save() async {
              final id = _youtubeId(urlController.text);
              final title = titleController.text.trim();

              if (id == null) {
                _message('Cole um link válido do YouTube Shorts.');
                return;
              }

              if (title.isEmpty) {
                _message('Informe o título do vídeo.');
                return;
              }

              setDialogState(() => saving = true);

              try {
                await _client.from('ambux_videos').upsert({
                  'youtube_id': id,
                  'title': title,
                  'description': descriptionController.text.trim(),
                  'is_published': published,
                  'published_at': published
                      ? (video?['published_at'] ??
                            DateTime.now().toUtc().toIso8601String())
                      : null,
                  'updated_at': DateTime.now().toUtc().toIso8601String(),
                });

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                await _loadVideos();
                _message('Vídeo salvo com sucesso!');
              } catch (error) {
                setDialogState(() => saving = false);
                _message('Não foi possível salvar: $error');
              }
            }

            return AlertDialog(
              backgroundColor: AuvixTheme.surface,
              title: Text(video == null ? 'Novo vídeo' : 'Editar vídeo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: urlController,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Link do YouTube Shorts',
                        hintText: 'https://youtube.com/shorts/...',
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          previewId = _youtubeId(value);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (previewId != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://img.youtube.com/vi/$previewId/hqdefault.jpg',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(
                            height: 80,
                            child: Center(child: Text('Prévia indisponível')),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      maxLength: 150,
                      decoration: const InputDecoration(
                        labelText: 'Título do vídeo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Publicar no AMBUX'),
                      value: published,
                      activeThumbColor: AuvixTheme.accent,
                      onChanged: (value) {
                        setDialogState(() => published = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: Text(saving ? 'Salvando...' : 'Salvar vídeo'),
                ),
              ],
            );
          },
        );
      },
    );

    urlController.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }

  Future<void> _deleteVideo(Map<String, dynamic> video) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir vídeo?'),
        content: Text('Deseja excluir "${video['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _client
          .from('ambux_videos')
          .delete()
          .eq('youtube_id', video['youtube_id'].toString());

      await _loadVideos();
      _message('Vídeo excluído.');
    } catch (error) {
      _message('Não foi possível excluir: $error');
    }
  }

  Future<void> _togglePublished(Map<String, dynamic> video) async {
    final publish = video['is_published'] != true;

    try {
      await _client
          .from('ambux_videos')
          .update({
            'is_published': publish,
            'published_at': publish
                ? DateTime.now().toUtc().toIso8601String()
                : null,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('youtube_id', video['youtube_id'].toString());

      await _loadVideos();
      _message(publish ? 'Vídeo publicado!' : 'Vídeo ocultado.');
    } catch (error) {
      _message('Não foi possível atualizar: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar vídeos'),
        actions: [
          IconButton(
            onPressed: _loadVideos,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _openEditor(),
              backgroundColor: AuvixTheme.accent,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo vídeo'),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_isAdmin
          ? const Center(
              child: Text('Acesso restrito à administração do AMBUX.'),
            )
          : _error != null
          ? Center(
              child: Text(
                'Erro ao carregar vídeos:\n$_error',
                textAlign: TextAlign.center,
              ),
            )
          : _videos.isEmpty
          ? const Center(child: Text('Nenhum vídeo cadastrado ainda.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                final video = _videos[index];
                final id = video['youtube_id'].toString();
                final isPublished = video['is_published'] == true;

                return Card(
                  color: AuvixTheme.surface,
                  margin: const EdgeInsets.only(bottom: 14),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        'https://img.youtube.com/vi/$id/hqdefault.jpg',
                        width: double.infinity,
                        height: 175,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox(
                          height: 100,
                          child: Center(child: Icon(Icons.video_library)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video['title']?.toString() ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if ((video['description'] ?? '')
                                .toString()
                                .isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                video['description'].toString(),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: AuvixTheme.muted),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  isPublished
                                      ? Icons.public
                                      : Icons.visibility_off,
                                  size: 18,
                                  color: isPublished
                                      ? AuvixTheme.accent
                                      : AuvixTheme.muted,
                                ),
                                const SizedBox(width: 6),
                                Text(isPublished ? 'Publicado' : 'Oculto'),
                                const Spacer(),
                                IconButton(
                                  tooltip: isPublished ? 'Ocultar' : 'Publicar',
                                  onPressed: () => _togglePublished(video),
                                  icon: Icon(
                                    isPublished
                                        ? Icons.visibility_off
                                        : Icons.publish,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Editar',
                                  onPressed: () => _openEditor(video: video),
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  tooltip: 'Excluir',
                                  onPressed: () => _deleteVideo(video),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
