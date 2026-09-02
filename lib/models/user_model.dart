class UserModel {
  final String uid;
  final String email;
  final int points;

  UserModel({
    required this.uid,
    required this.email,
    this.points = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'points': points,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      points: map['points'] ?? 0,
    );
  }
}
