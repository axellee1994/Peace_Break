import '../database/orm.dart';

class User implements Model {
  @override
  final int? id;
  final String email;
  final String username;
  final String passwordHash;
  final int coins;
  final int totalScore;
  final int maxLives;
  final String createdAt;

  const User({
    this.id,
    required this.email,
    required this.username,
    required this.passwordHash,
    this.coins = 0,
    this.totalScore = 0,
    this.maxLives = 3,
    required this.createdAt,
  });

  @override
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'email': email,
        'username': username,
        'password_hash': passwordHash,
        'coins': coins,
        'total_score': totalScore,
        'max_lives': maxLives,
        'created_at': createdAt,
      };

  factory User.fromMap(Map<String, dynamic> m) => User(
        id: m['id'] as int?,
        email: m['email'] as String,
        username: m['username'] as String,
        passwordHash: m['password_hash'] as String,
        coins: m['coins'] as int? ?? 0,
        totalScore: m['total_score'] as int? ?? 0,
        maxLives: m['max_lives'] as int? ?? 3,
        createdAt: m['created_at'] as String? ?? '',
      );

  User copyWith({
    int? id,
    String? email,
    String? username,
    String? passwordHash,
    int? coins,
    int? totalScore,
    int? maxLives,
    String? createdAt,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        username: username ?? this.username,
        passwordHash: passwordHash ?? this.passwordHash,
        coins: coins ?? this.coins,
        totalScore: totalScore ?? this.totalScore,
        maxLives: maxLives ?? this.maxLives,
        createdAt: createdAt ?? this.createdAt,
      );
}
