class Tournament {
  final String id;
  final String title;
  final int maxSeats;
  final int entryFee;
  final String startTime;
  final String status;

  Tournament({
    required this.id,
    required this.title,
    required this.maxSeats,
    required this.entryFee,
    required this.startTime,
    required this.status,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      title: json['title'],
      maxSeats: json['max_seats'],
      entryFee: json['entry_fee'],
      startTime: json['start_time'],
      status: json['status'],
    );
  }
}
