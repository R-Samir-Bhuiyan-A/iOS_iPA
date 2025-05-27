import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tournament_provider.dart';

class JoinTournamentScreen extends StatelessWidget {
  final String tournamentId;

  JoinTournamentScreen({required this.tournamentId});

  @override
  Widget build(BuildContext context) {
    final tournamentProvider = Provider.of<TournamentProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Join Tournament")),
      body: Center(
        child: ElevatedButton(
          child: Text("Confirm Join"),
          onPressed: () async {
            final success = await tournamentProvider.joinTournament(tournamentId);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(success ? "Joined Successfully!" : "Join Failed."),
            ));
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
