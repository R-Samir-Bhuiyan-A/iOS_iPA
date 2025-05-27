import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../models/tournament.dart';

class TournamentProvider extends ChangeNotifier {
  List<Tournament> _tournaments = [];
  bool loading = false;

  List<Tournament> get tournaments => _tournaments;

  Future<void> fetchTournaments(String token) async {
    loading = true;
    notifyListeners();

    final response = await ApiService.get('modules/tournament/list.php', token: token);

    if (response['status'] == 'success') {
      _tournaments = (response['data'] as List)
          .map((json) => Tournament.fromJson(json))
          .toList();
    }

    loading = false;
    notifyListeners();
  }
}
