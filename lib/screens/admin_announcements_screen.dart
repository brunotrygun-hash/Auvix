import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/auvix_theme.dart';

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() =>
      _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  final _client = Supabase.instance.client;

  bool _loading = true;
  bool _isAdmin = false;
  String? _error;
  List<Map<String, dynamic>> _announcements = [];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _client.rpc('is_auvix_admin');

      if (result != true) {
        if (!mounted) return;
        setState(() {
          _isAdmin = false;
          _loading = false;
        });
        return;
      }

      final rows = await _client
          .from('official_announcements')
          .select(
            'id, category, title, message, published_at, is_published, created_at',
          )
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _isAdmin = true;
        _announcements = rows
            .map((row) => Map<String, dynamic>.from(row))
            .toList();
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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openEditor({Map<String, dynamic>? announcement}) async {
    final titleController = TextEditingController(
      text: announcement?['title']?.toString() ?? '',
    );
    final messageController = TextEditingController(
      text: announcement?['message']?.toString() ?? '',
    );

    const categories = ['Novidade', 'Atualização', 'Aviso'];
    var category = announcement?['category']?.toString() ?? 'Novidade';
    if (!categories.contains(category)) category = 'Novidade';

    var saving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> save(bool publish) async {
              final title = titleController.text.trim();
              final message = messageController.text.trim();

              if (title.isEmpty || message.isEmpty) {
                _showMessage('Preencha o título e a mensagem.');
                return;
              }

              setDialogState(() => saving = true);

              try {
                final data = <String, dynamic>{
                  'category': category,
                  'title': title,
                  'message': message,
                  'is_published': publish,
                  'published_at': DateTime.now().toUtc().toIso8601String(),
                };

                if (announcement == null) {
                  await _client.from('official_announcements').insert(data);
                } else {
                  await _client
                      .from('official_announcements')
                      .update(data)
                      .eq('id', announcement['id'].toString());
                }

                if (!mounted) return;
                Navigator.of(dialogContext).pop();
                _showMessage(
                  publish ? 'Comunicado publicado!' : 'Rascunho salvo!',
                );
                await _loadAnnouncements();
              } catch (error) {
                setDialogState(() => saving = false);
                _showMessage('Não foi possível salvar: $error');
              }
            }

            return AlertDialog(
              backgroundColor: AuvixTheme.surface2,
              title: Text(
                announcement == null ? 'Novo comunicado' : 'Editar comunicado',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: categories
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: saving
                          ? null
                          : (value) {
                              if (value != null) {
                                setDialogState(() => category = value);
                              }
                            },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleController,
                      enabled: !saving,
                      maxLength: 90,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        hintText: 'Digite o título do comunicado',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: messageController,
                      enabled: !saving,
                      minLines: 4,
                      maxLines: 8,
                      maxLength: 1500,
                      decoration: const InputDecoration(
                        labelText: 'Mensagem',
                        hintText: 'Escreva o comunicado para os usuários',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: saving ? null : () => save(false),
                  child: const Text('Salvar rascunho'),
                ),
                ElevatedButton(
                  onPressed: saving ? null : () => save(true),
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Publicar'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    messageController.dispose();
  }

  Future<void> _changePublication(
    Map<String, dynamic> announcement,
    bool publish,
  ) async {
    try {
      await _client
          .from('official_announcements')
          .update({
            'is_published': publish,
            'published_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', announcement['id'].toString());

      _showMessage(
        publish ? 'Comunicado publicado!' : 'Comunicado retirado do ar.',
      );
      await _loadAnnouncements();
    } catch (error) {
      _showMessage('Não foi possível atualizar: $error');
    }
  }

  Future<void> _deleteAnnouncement(Map<String, dynamic> announcement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuvixTheme.surface2,
        title: const Text('Excluir comunicado?'),
        content: const Text(
          'Esta ação é permanente. O comunicado será removido.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: AuvixTheme.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _client
          .from('official_announcements')
          .delete()
          .eq('id', announcement['id'].toString());

      _showMessage('Comunicado excluído.');
      await _loadAnnouncements();
    } catch (error) {
      _showMessage('Não foi possível excluir: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração AUVIX'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadAnnouncements,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _openEditor(),
              backgroundColor: AuvixTheme.accent,
              foregroundColor: const Color(0xFF00140F),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo comunicado'),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_isAdmin
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Acesso restrito à administração do AUVIX.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Erro ao carregar comunicados:\n$_error',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadAnnouncements,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            )
          : _announcements.isEmpty
          ? const Center(child: Text('Nenhum comunicado cadastrado.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: _announcements.length,
              itemBuilder: (context, index) {
                final item = _announcements[index];
                final published = item['is_published'] == true;

                return Card(
                  color: AuvixTheme.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['category']?.toString() ?? 'Novidade',
                                style: const TextStyle(
                                  color: AuvixTheme.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              published ? 'PUBLICADO' : 'RASCUNHO',
                              style: TextStyle(
                                color: published
                                    ? AuvixTheme.accent
                                    : AuvixTheme.muted,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['title']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['message']?.toString() ?? '',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AuvixTheme.muted),
                        ),
                        const Divider(height: 22),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            TextButton.icon(
                              onPressed: () => _openEditor(announcement: item),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Editar'),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  _changePublication(item, !published),
                              icon: Icon(
                                published
                                    ? Icons.visibility_off_outlined
                                    : Icons.publish_rounded,
                                size: 18,
                              ),
                              label: Text(published ? 'Retirar' : 'Publicar'),
                            ),
                            TextButton.icon(
                              onPressed: () => _deleteAnnouncement(item),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: AuvixTheme.danger,
                              ),
                              label: const Text(
                                'Excluir',
                                style: TextStyle(color: AuvixTheme.danger),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
