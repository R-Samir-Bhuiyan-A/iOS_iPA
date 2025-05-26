import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/slang_tile.dart';
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

  void onClaimPoints() async {
    final error = await ApiService.claimPoints();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Points claimed!')));
    }
  }

  void onRefresh() => loadFeed();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Slang Feed'),
        actions: [
          IconButton(icon: Icon(Icons.person), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(onLogout: onLogout)));
          }),
          IconButton(icon: Icon(Icons.refresh), onPressed: onRefresh),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(context, MaterialPageRoute(builder: (_) => SuggestScreen()));
          if (added == true) loadFeed();
        },
        child: Icon(Icons.add),
        tooltip: 'Suggest New Slang',
      ),
      body: Column(
        children: [
          if (slangOfWeek.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Slang of the Week: $slangOfWeek',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ElevatedButton(onPressed: onClaimPoints, child: Text('Claim Points')),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: feed.length,
                    itemBuilder: (context, index) {
                      return SlangTile(
                        slang: feed[index],
                        onRefresh: loadFeed,
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
