import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SlangTile extends StatelessWidget {
  final Map slang;
  final VoidCallback onRefresh;

  SlangTile({required this.slang, required this.onRefresh});

  void vote(BuildContext context, String voteType) async {
    final err = await ApiService.voteSlang(slang['id'], voteType);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      onRefresh();
    }
  }

  void deleteSlang(BuildContext context) async {
    final err = await ApiService.deleteSlang(slang['id']);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      onRefresh();
    }
  }

  void editSlang(BuildContext context) {
    final _controller = TextEditingController(text: slang['text']);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Slang'),
        content: TextField(controller: _controller, decoration: InputDecoration(hintText: 'New slang text')),
        actions: [
          TextButton(
            onPressed: () async {
              final newText = _controller.text.trim();
              if (newText.isEmpty) return;
              final err = await ApiService.editSlang(slang['id'], newText);
              Navigator.pop(context);
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
              } else {
                onRefresh();
              }
            },
            child: Text('Submit'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(slang['text'] ?? ''),
        subtitle: Text('By: ${slang['author'] ?? 'unknown'}  Likes: ${slang['likes'] ?? 0}  Dislikes: ${slang['dislikes'] ?? 0}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'like':
                vote(context, 'like');
                break;
              case 'dislike':
                vote(context, 'dislike');
                break;
              case 'edit':
                editSlang(context);
                break;
              case 'delete':
                deleteSlang(context);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'like', child: Text('Like')),
            PopupMenuItem(value: 'dislike', child: Text('Dislike')),
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
