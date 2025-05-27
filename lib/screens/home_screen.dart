import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'suggest_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  HomeScreen({required this.onLogout});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> feed = [];
  bool isLoading = true;
  String slangOfWeek = '';

  @override
  void initState() {
    super.initState();
    loadFeed();
    loadSlangOfWeek();
  }

  Future<void> loadFeed() async {
    setState(() => isLoading = true);
    final data = await ApiService.getFeed();
    setState(() {
      feed = data;
      isLoading = false;
    });
  }

  Future<void> loadSlangOfWeek() async {
    final data = await ApiService.getSlangOfTheWeek();
    if (data != null) {
      setState(() {
        slangOfWeek = data['text'] ?? '';
      });
    }
  }

  void onLogout() async {
    await ApiService.logout();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Shawa Feed', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfileScreen(onLogout: onLogout)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadFeed,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SuggestScreen()),
          );
          if (added == true) loadFeed();
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        tooltip: 'Suggest New Shawa',
      ),
      body: Column(
        children: [
          if (slangOfWeek.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.whatshot, color: Colors.orangeAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '🔥 Shawa of the Week:\n"$slangOfWeek"',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : RefreshIndicator(
                    onRefresh: loadFeed,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: feed.length,
                      itemBuilder: (_, index) => SlangCard(
                        slang: feed[index],
                        onRefresh: loadFeed,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class SlangCard extends StatefulWidget {
  final Map slang;
  final VoidCallback onRefresh;

  const SlangCard({required this.slang, required this.onRefresh});

  @override
  State<SlangCard> createState() => _SlangCardState();
}

class _SlangCardState extends State<SlangCard> {
  late bool liked;

  @override
  void initState() {
    super.initState();
    liked = widget.slang['liked'] ?? false;
  }

  void vote(String type) async {
    final err = await ApiService.voteSlang(widget.slang['id'], type);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      widget.onRefresh();
    }
  }

  void delete() async {
    final err = await ApiService.deleteSlang(widget.slang['id']);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      widget.onRefresh();
    }
  }

  void edit() {
    final controller = TextEditingController(text: widget.slang['text']);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Edit Slang', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter new slang',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final text = controller.text.trim();
              Navigator.pop(context);
              if (text.isEmpty) return;
              final err = await ApiService.editSlang(widget.slang['id'], text);
              if (err != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
              } else {
                widget.onRefresh();
              }
            },
            child: const Text('Save'),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slang = widget.slang;
    final likeCount = slang['likes'] ?? 0;
    final postedBy = slang['posted_by'] ?? 'Unknown';

    return Card(
      color: Colors.grey[850],
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              slang['text'] ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Posted by: $postedBy',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.redAccent : Colors.grey[400],
                  ),
                  onPressed: () {
                    vote(liked ? 'dislike' : 'like');
                    setState(() => liked = !liked);
                  },
                  tooltip: liked ? 'Unlike' : 'Like',
                ),
                Text(
                  '$likeCount',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'dislike':
                        vote('dislike');
                        break;
                      case 'edit':
                        edit();
                        break;
                      case 'delete':
                        delete();
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'dislike', child: Text('Dislike')),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
