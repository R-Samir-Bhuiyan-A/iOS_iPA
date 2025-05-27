import 'package:flutter/material.dart';
import '../models/tournament.dart';

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  const TournamentCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        title: Text(tournament.title, style: TextStyle(color: Colors.white)),
        subtitle: Text('Entry Fee: ${tournament.entryFee} | Seats: ${tournament.maxSeats}',
          style: TextStyle(color: Colors.white70)),
        trailing: Text(tournament.status.toUpperCase(),
            style: TextStyle(
                color: tournament.status == 'upcoming'
                    ? Colors.orange
                    : (tournament.status == 'live' ? Colors.green : Colors.grey))),
        onTap: () {
          // Navigate to tournament detail screen
        },
      ),
    );
  }
}
