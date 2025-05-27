import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tournament_provider.dart';
import '../../widgets/tournament_card.dart';

class TournamentListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TournamentProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Tournaments')),
      body: provider.loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.tournaments.length,
              itemBuilder: (context, index) {
                return TournamentCard(tournament: provider.tournaments[index]);
              },
            ),
    );
  }
}
