class User {
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

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'username': username,
      'password_hash': passwordHash,
      'coins': coins,
      'total_score': totalScore,
      'max_lives': maxLives,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      coins: map['coins'] as int? ?? 0,
      totalScore: map['total_score'] as int? ?? 0,
      maxLives: map['max_lives'] as int? ?? 3,
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? username,
    String? passwordHash,
    int? coins,
    int? totalScore,
    int? maxLives,
    String? createdAt,
  }) {
    return User(
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
}
