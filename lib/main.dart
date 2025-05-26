import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const ShawerApp());

class ShawerApp extends StatelessWidget {
  const ShawerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Shawer App',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final apiUrl = "http://103.151.60.203/slg/api.php";
  String username = '';
  String password = '';
  String session = '';
  int points = 0;
  String newSlang = '';
  List slangs = [];
  String message = '';
  bool isLoading = false;
  bool isLoggedIn = false;

  Future<void> auth(String action) async {
    setState(() => isLoading = true);
    final response = await http.post(Uri.parse(apiUrl), body: {
      'action': action,
      'username': username,
      'password': password,
    });

    final data = jsonDecode(response.body);
    if (data['success']) {
      setState(() {
        session = data['session'] ?? '';
        points = data['points'] ?? 0;
        isLoggedIn = true;
        message = 'Welcome, $username';
        loadSlangs();
      });
    } else {
      setState(() => message = data['error'] ?? 'Auth failed');
    }
    setState(() => isLoading = false);
  }

  Future<void> loadSlangs() async {
    final response = await http.post(Uri.parse(apiUrl), body: {
      'action': 'feed',
      'session': session,
    });

    final data = jsonDecode(response.body);
    setState(() {
      slangs = data['slangs'] ?? [];
      points = data['points'] ?? points;
    });
  }

  Future<void> submitSlang() async {
    if (newSlang.isEmpty) return;
    final response = await http.post(Uri.parse(apiUrl), body: {
      'action': 'submit',
      'session': session,
      'text': newSlang,
    });
    final data = jsonDecode(response.body);
    if (data['success']) {
      setState(() {
        newSlang = '';
        message = 'Slang submitted!';
        loadSlangs();
      });
    } else {
      setState(() => message = data['error'] ?? 'Submit failed');
    }
  }

  Future<void> voteSlang(String id, String voteType) async {
    final response = await http.post(Uri.parse(apiUrl), body: {
      'action': 'vote',
      'session': session,
      'id': id,
      'vote': voteType,
    });

    final data = jsonDecode(response.body);
    if (data['success']) {
      loadSlangs();
    }
  }

  Widget buildAuthScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Shawer App', style: TextStyle(fontSize: 30)),
        const SizedBox(height: 20),
        TextField(
          decoration: const InputDecoration(labelText: 'Username'),
          onChanged: (v) => username = v,
        ),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
          onChanged: (v) => password = v,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
            onPressed: () => auth('login'), child: const Text('Login')),
        ElevatedButton(
            onPressed: () => auth('register'), child: const Text('Register')),
        const SizedBox(height: 10),
        if (message.isNotEmpty)
          Text(message, style: const TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget buildMainScreen() {
    return RefreshIndicator(
      onRefresh: loadSlangs,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Hi $username 👋 – Points: $points', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(hintText: 'Write a new slang...'),
            onChanged: (v) => newSlang = v,
            onSubmitted: (_) => submitSlang(),
          ),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: submitSlang, child: const Text('Submit Slang')),
          const Divider(),
          const Text('Recent Slangs:', style: TextStyle(fontSize: 18)),
          for (var slang in slangs)
            Card(
              child: ListTile(
                title: Text(slang['text']),
                subtitle: Text("Votes: ${slang['votes']}"),
                trailing: Wrap(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.thumb_up),
                        onPressed: () => voteSlang(slang['id'], 'up')),
                    IconButton(
                        icon: const Icon(Icons.thumb_down),
                        onPressed: () => voteSlang(slang['id'], 'down')),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: isLoggedIn ? buildMainScreen() : buildAuthScreen(),
            ),
    );
  }
}
