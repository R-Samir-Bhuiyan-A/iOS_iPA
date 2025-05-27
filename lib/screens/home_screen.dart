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

  void onRefresh() => loadFeed();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Shawa Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProfileScreen(onLogout: onLogout)),
              );
            },
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
            tooltip: 'Refresh Feed',
          ),
        ],
        backgroundColor: Colors.deepPurple,
        elevation: 6,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(context, MaterialPageRoute(builder: (_) => SuggestScreen()));
          if (added == true) loadFeed();
        },
        child: const Icon(Icons.add),
        tooltip: 'Suggest New Shawa',
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          if (slangOfWeek.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.whatshot, color: Colors.deepPurple.shade400, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '🔥 shawa of the Week:\n"$slangOfWeek"',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.deepPurple.shade700,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async => loadFeed(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      itemCount: feed.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final slang = feed[index];
                        return _SlangCard(
                          slang: slang,
                          onRefresh: loadFeed,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SlangCard extends StatefulWidget {
  final dynamic slang;
  final VoidCallback onRefresh;

  const _SlangCard({required this.slang, required this.onRefresh});

  @override
  State<_SlangCard> createState() => _SlangCardState();
}

class _SlangCardState extends State<_SlangCard> with SingleTickerProviderStateMixin {
  late bool _liked;
  bool _isLiking = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _liked = widget.slang['liked'] ?? false;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.7,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    if (_isLiking) return;

    setState(() => _isLiking = true);

    await _animController.forward();
    await _animController.reverse();

    final action = _liked ? 'dislike' : 'like';
    final err = await ApiService.voteSlang(widget.slang['id'], action);

    if (err == null) {
      setState(() {
        _liked = !_liked;
      });
      widget.onRefresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $err')));
    }

    setState(() => _isLiking = false);
  }

  @override
  Widget build(BuildContext context) {
    final likesCount = widget.slang['likes'] ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.deepPurple.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.slang['text'] ?? '',
              style: const TextStyle(
                fontSize: 17,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: IconButton(
                    iconSize: 28,
                    icon: Icon(
                      _liked ? Icons.favorite : Icons.favorite_border,
                      color: _liked ? Colors.redAccent : Colors.grey.shade600,
                    ),
                    onPressed: _isLiking ? null : _toggleLike,
                    tooltip: _liked ? 'Unlike' : 'Like',
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$likesCount',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                  onSelected: (value) {
                    if (value == 'report') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reported. Thank you!')),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'report', child: Text('Report')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
