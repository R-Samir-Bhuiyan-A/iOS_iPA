class Tournament {
  final String id;
  final String title;
  final int entryFee;
  final int maxSeats;
  final String status;
  final String? roomId;
  final String? roomPassword;
  final List<String> joinedUsers; // ✅ Add this line

  Tournament({
    required this.id,
    required this.title,
    required this.entryFee,
    required this.maxSeats,
    required this.status,
    this.roomId,
    this.roomPassword,
    required this.joinedUsers, // ✅ Add this
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'].toString(),
      title: json['title'],
      entryFee: int.parse(json['entry_fee'].toString()),
      maxSeats: int.parse(json['max_seats'].toString()),
      status: json['status'],
      roomId: json['room_id'],
      roomPassword: json['room_password'],
      joinedUsers: (json['joined_users'] as List<dynamic>).map((u) => u.toString()).toList(), // ✅ Add this
    );
  }
}
