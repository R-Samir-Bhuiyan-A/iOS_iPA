import 'package:flutter/material.dart';
import '../models/tournament.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  const TournamentCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    return Card(
      color: Colors.grey[850],
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tournament.title,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Entry Fee: ${tournament.entryFee} | Seats: ${tournament.maxSeats}',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tournament.status.toUpperCase(),
                  style: TextStyle(
                    color: tournament.status == 'upcoming'
                        ? Colors.orange
                        : (tournament.status == 'live' ? Colors.green : Colors.grey),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // TODO: Add Join button or other controls here
              ],
            ),

            // Room Reveal UI: Show room id and password only if tournament started and user joined
            if (tournament.status == 'started' && tournament.joinedUsers.contains(userId)) ...[
              SizedBox(height: 12),
              Divider(color: Colors.white38),
              SizedBox(height: 8),
              Text(
                "Room ID: ${tournament.roomId}",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              Text(
                "Password: ${tournament.roomPassword}",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
