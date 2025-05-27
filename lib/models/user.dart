class User {
  final String id;
  final String username;
  final int balance;

  User({required this.id, required this.username, required this.balance});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      balance: json['balance'],
    );
  }
}
