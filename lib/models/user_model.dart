class UserModel {
  final String id;
  final String name;
  final String email;
  final int points;
  final double balance;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.points,
    required this.balance,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'points': points,
      'balance': balance,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      points: json['points'] ?? 0,
      balance: (json['balance'] ?? 0.0).toDouble(),
    );
  }
}
